class SmsParsedResult {
  final double amount;
  final String type;
  final String merchant;
  final String category;
  final String paymentMethod;

  SmsParsedResult({
    required this.amount,
    required this.type,
    required this.merchant,
    required this.category,
    required this.paymentMethod,
  });
}

class SmsParser {
  // ─────────────────────────────────────────────────────────────────────────
  // FIX #1: Known Indian bank / payment-app sender IDs (case-insensitive).
  // Only SMS from these senders are processed → stops unwanted SMS detection.
  // ─────────────────────────────────────────────────────────────────────────
  static const _bankSenderPatterns = [
    // SBI
    'sbi', 'sbiinb', 'sbicrd', 'sbipsg',
    // HDFC
    'hdfc', 'hdfcbk', 'hdfcbn',
    // ICICI
    'icici', 'icicib',
    // Axis
    'axisbk', 'axisbn', 'axisbank',
    // Kotak
    'kotak', 'kotakb',
    // YES Bank
    'yesbnk', 'yesbank',
    // PNB
    'pnbsms', 'pnb',
    // BOB
    'bobsms', 'bobtxn',
    // Canara
    'canarab', 'cnrbnk',
    // IDBI
    'idbibnk',
    // IndusInd
    'indusb', 'induslnd',
    // Federal
    'fedbk', 'federalbnk',
    // UCO
    'ucobk',
    // Union
    'unionbk',
    // PayTM
    'paytm',
    // PhonePe
    'phonepe',
    // Google Pay
    'gpay',
    // Amazon Pay
    'amazon',
    // CRED
    'credapp',
    // Slice
    'sliceit',
    // OneCard
    'onecard',
    // NSDL Payments
    'nsdlpb',
    // RBL
    'rblbnk', 'rblbank',
    // Standard Chartered
    'scbank', 'scbnk',
    // HSBC
    'hsbc',
    // Citibank
    'citibnk', 'citibank',
    // IDFC
    'idfcfb', 'idfc',
    // Bajaj Finserv
    'bajajfin',
    // Generic fallback keywords
    'bank', 'wallet', 'upi', 'nbfc',
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // FIX #2: At least one debit keyword must be present → stops credit-only
  // SMS being logged as expenses AND stops valid debit SMS being dropped
  // when they happen to also contain words like "credited".
  //
  // ⚠ PRECISION RULES (to avoid false positives):
  //   • "debited" not "debit" → avoids "debit card PIN" info SMS
  //   • "paid to/at/for" not bare "paid" → avoids generic "paid attention" matches
  //   • "payment of/for" not bare "payment" → avoids "payment due reminder" info SMS
  // ─────────────────────────────────────────────────────────────────────────
  static const _debitKeywords = [
    'debited',
    'spent',
    'paid to',
    'paid at',
    'paid for',
    'paid rs',
    'paid inr',
    'paid ₹',
    'payment of',
    'payment for',
    'withdrawn',
    'purchase',
    'charged',
    'transaction of',
    'txn of',
    'used at',
    'used for',
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // Credit-only signals: if ONLY these are present (no debit keyword) skip.
  // Also: if a credit keyword appears WITHOUT any debit keyword, it's an
  // incoming credit SMS — we don't log those as expenses.
  // ─────────────────────────────────────────────────────────────────────────
  static const _creditOnlyKeywords = [
    'credited',
    'received',
    'refunded',
    'deposited',
    'cashback',
    'reward',
  ];

  static SmsParsedResult? parseSms(String sender, String body) {
    final lowerBody = body.toLowerCase();
    final lowerSender = sender.toLowerCase();

    // ── Step 1: Sender must be a known bank / payment app ──────────────────
    final bool isFinancialSender = _bankSenderPatterns.any(
      (p) => lowerSender.contains(p),
    );
    if (!isFinancialSender) return null;

    // ── Step 2: Must contain a debit keyword ──────────────────────────────
    final bool hasDebitKeyword = _debitKeywords.any(
      (kw) => lowerBody.contains(kw),
    );

    if (!hasDebitKeyword) {
      // No debit keyword → could be a credit/info SMS, skip it.
      return null;
    }

    // ── Step 3: Extract amount ─────────────────────────────────────────────
    // FIX #3: Improved regex handles Rs., INR, ₹ with optional spaces.
    // Primary: currency prefix → "Rs. 500", "INR 1,234.56", "₹500"
    RegExp amountRegex = RegExp(
      r'(?:rs\.?\s*|inr\s*|usd\s*|\$\s*|₹\s*)([\d,]+\.?\d*)',
      caseSensitive: false,
    );
    Match? amountMatch = amountRegex.firstMatch(body);

    // Fallback: currency suffix → "500 INR", "1234 Rs"
    if (amountMatch == null) {
      RegExp suffixRegex = RegExp(
        r'([\d,]+\.?\d*)\s*(?:rs\.?|inr|usd)',
        caseSensitive: false,
      );
      amountMatch = suffixRegex.firstMatch(body);
    }

    if (amountMatch == null) return null;

    final String amountStr = amountMatch.group(1)!.replaceAll(',', '');
    final double? amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) return null;

    // ── Step 4: Extract merchant ───────────────────────────────────────────
    String merchant = sender;
    final RegExp merchantRegex = RegExp(
      r'(?:at|to|info[\*:\-])\s+([A-Za-z0-9][A-Za-z0-9\s\-&.]{1,40}?)(?:\s+on\b|\s+via\b|\s+using\b|\s+ref\b|\s+avl\b|\s+val\b|\s+balance\b|\.|\,|$)',
      caseSensitive: false,
    );
    final Match? merchantMatch = merchantRegex.firstMatch(body);
    if (merchantMatch != null) {
      final String m = merchantMatch.group(1)!.trim();
      if (m.isNotEmpty) merchant = m;
    }

    // ── Step 5: Categorise ─────────────────────────────────────────────────
    final String category = categorizeMerchant(merchant);

    // ── Step 6: Payment method ─────────────────────────────────────────────
    // Detect UPI by multiple signals: explicit keyword, VPA address (@),
    // app names (PhonePe / GPay / Paytm / BHIM), or UPI ref patterns.
    final bool isUpi = lowerBody.contains('upi') ||
        RegExp(r'\b\w+@\w+\b').hasMatch(lowerBody) || // VPA e.g. name@oksbi
        lowerBody.contains('phonepe') ||
        lowerBody.contains('gpay') ||
        lowerBody.contains('google pay') ||
        lowerBody.contains('paytm') ||
        lowerBody.contains('bhim') ||
        lowerBody.contains('vpa') ||
        RegExp(r'upi\s*ref', caseSensitive: false).hasMatch(body);

    final bool isCard = lowerBody.contains('credit card') ||
        lowerBody.contains('debit card') ||
        lowerBody.contains(' card ');

    String paymentMethod;
    if (isUpi) {
      paymentMethod = 'UPI';
    } else if (isCard) {
      paymentMethod = 'Card';
    } else {
      paymentMethod = 'Bank Transfer';
    }

    return SmsParsedResult(
      amount: amount,
      type: 'Expense',
      merchant: merchant,
      category: category,
      paymentMethod: paymentMethod,
    );
  }

  static String categorizeMerchant(String merchant) {
    final String ml = merchant.toLowerCase();

    final foodKeywords = [
      'starbucks', 'zomato', 'swiggy', 'mcdonalds', 'kfc',
      'restaurant', 'cafe', 'food', 'blinkit', 'bigbasket',
      'grofers', 'dunzo', 'dominos', 'pizza',
    ];
    final transportKeywords = [
      'uber', 'ola', 'irctc', 'petrol', 'fuel', 'hpcl', 'ioc',
      'bpcl', 'metro', 'rapido', 'bus', 'train', 'flight', 'airport',
    ];
    final shoppingKeywords = [
      'amazon', 'flipkart', 'myntra', 'nykaa', 'supermarket',
      'dmart', 'reliance', 'meesho', 'ajio', 'tata', 'croma',
    ];
    final utilitiesKeywords = [
      'airtel', 'jio', 'vi ', 'bsnl', 'bescom', 'electricity',
      'water', 'broadband', 'recharge', 'gas', 'lpg',
    ];
    final entertainmentKeywords = [
      'netflix', 'spotify', 'prime', 'hotstar', 'pvr',
      'bookmyshow', 'disney', 'zee5', 'sonyliv',
    ];
    final healthKeywords = [
      'pharmacy', 'hospital', 'apollo', 'medplus', 'clinic',
      'pharma', 'medic', 'health', 'netmeds', '1mg',
    ];

    if (foodKeywords.any((k) => ml.contains(k))) return 'Food';
    if (transportKeywords.any((k) => ml.contains(k))) return 'Transportation';
    if (shoppingKeywords.any((k) => ml.contains(k))) return 'Shopping';
    if (utilitiesKeywords.any((k) => ml.contains(k))) return 'Utilities';
    if (entertainmentKeywords.any((k) => ml.contains(k))) return 'Entertainment';
    if (healthKeywords.any((k) => ml.contains(k))) return 'Health';

    return 'Others';
  }
}
