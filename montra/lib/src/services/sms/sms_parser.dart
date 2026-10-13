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
  // SENDER WHITELIST
  // Only SMS from these known Indian bank/payment-app sender IDs are parsed.
  // Indian sender IDs follow the format: XX-SENDERID (e.g. AD-HDFCBK)
  // so a contains() check on the lowercased sender is sufficient.
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
    'amazon', 'amazonpay',
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
    // Fintech UPI apps
    'mobikwik', 'freecharge', 'airpay', 'razorpay',
    'jupiter', 'niyo', 'indmoney',
    // Generic fallback — 'bnk' catches abbreviated IDs like XX-HDFCBNK.
    // 'wallet' and 'upi' are precise enough to be safe.
    'bnk', 'wallet', 'upi', 'nbfc',
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // DEBIT DETECTION — RegExp patterns with word boundaries (\b)
  //
  // Using RegExp instead of simple string.contains() gives us:
  //   • Word boundaries: \bcharged\b won't match "recharged"
  //   • \bsent\b won't match "consent"
  //   • Qualified matches: "paid to/at/Rs." won't match bare "paid"
  //
  // The amount-extraction step (Step 3) acts as a second safety filter —
  // if no valid Rs./INR/₹ amount is found, the SMS is rejected anyway.
  // ─────────────────────────────────────────────────────────────────────────
  static final List<RegExp> _debitPatterns = [
    // ── Standard bank debit words ──────────────────────────────────────────
    RegExp(r'\bdebited\b', caseSensitive: false),
    RegExp(r'\bspent\b', caseSensitive: false),
    RegExp(r'\bwithdrawn\b', caseSensitive: false),
    // "charged" but NOT "recharged" — word boundary prevents the false match
    RegExp(r'\bcharged\b', caseSensitive: false),
    // "purchase" or "purchased"
    RegExp(r'\bpurchased?\b', caseSensitive: false),

    // ── "Paid" variants ────────────────────────────────────────────────────
    // Must be followed by to/at/for/currency to avoid "paid attention" etc.
    RegExp(r'\bpaid\s+(to|at|for|rs\.?|inr|₹|\d)', caseSensitive: false),

    // ── "Payment" variants ─────────────────────────────────────────────────
    RegExp(r'\bpayment\s+(of|for|done|success)', caseSensitive: false),

    // ── "Sent" variants ────────────────────────────────────────────────────
    // "Sent Rs.60.00" → matches 'sent rs'
    // "sent to merchant@upi" → matches 'sent to <word>'
    // "sent ₹500" → matches 'sent ₹'
    // Avoids: "OTP sent to your" → "sent to your" — 'your' is a word but
    //   the amount check in Step 3 will reject it (no Rs./INR/₹ amount).
    RegExp(r'\bsent\s+(rs\.?|inr|₹|\d|to\s+\w)', caseSensitive: false),
    RegExp(r'\bsuccessfully\s+sent\b', caseSensitive: false),

    // ── "Transferred/Transfer" variants ────────────────────────────────────
    // Covers NEFT, IMPS, UPI transfers
    RegExp(r'\btransferr?ed?\s+(to|of|rs\.?|inr|₹|\d)', caseSensitive: false),
    RegExp(r'\btransfer\s+(to|of)\b', caseSensitive: false),

    // ── Transaction / Txn ──────────────────────────────────────────────────
    RegExp(r'\b(transaction|txn)\s+(of|amt)\b', caseSensitive: false),

    // ── "Used at/for" — credit/debit card POS ──────────────────────────────
    RegExp(r'\bused\s+(at|for)\b', caseSensitive: false),

    // ── Auto-debit / EMI / NACH ────────────────────────────────────────────
    RegExp(r'\bauto[- ]?debit\b', caseSensitive: false),
    RegExp(r'\bemi\s+(of|for|deducted|paid)\b', caseSensitive: false),
    RegExp(r'\bnach\s+debit\b', caseSensitive: false),

    // ── UPI-specific ───────────────────────────────────────────────────────
    RegExp(r'\bupi\s+debit\b', caseSensitive: false),
  ];

  // NOTE: Credit-only SMS (credited/received/refunded) are automatically
  // rejected because none of the _debitPatterns will match them.
  // No separate credit-keyword list is needed.

  // ─────────────────────────────────────────────────────────────────────────
  // AMOUNT REGEX
  // Handles all common Indian bank amount formats:
  //   Rs.500  Rs. 500  Rs500  INR 500  ₹500  ₹ 500
  //   Amt Rs.500  Amt: Rs.500
  //   Rs.1,500.00  ₹1,50,000
  // ─────────────────────────────────────────────────────────────────────────
  static final RegExp _amountPrefixRegex = RegExp(
    r'(?:(?:amt\.?\s*)?(?:rs\.?\s*|inr\s*)|₹\s*)([\d,]+\.?\d*)',
    caseSensitive: false,
  );
  static final RegExp _amountSuffixRegex = RegExp(
    r'([\d,]+\.?\d*)\s*(?:rs\.?|inr)',
    caseSensitive: false,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // MERCHANT EXTRACTION PATTERNS
  // Tried in order — first match wins.
  // ─────────────────────────────────────────────────────────────────────────

  // 1. VPA address: capture the full VPA address as mentioned in SMS
  //    e.g. "To rajeshrajeshk120@yes" → "rajeshrajeshk120@yes"
  //         "to zomato@upi" → "zomato@upi"
  static final RegExp _vpaMerchantRegex = RegExp(
    r'(?:to|at)\s+([A-Za-z0-9][A-Za-z0-9.\-_]{1,40}@[A-Za-z0-9.\-_]{2,})',
    caseSensitive: false,
  );

  // 2. Info field: "Info: IMPS/P2M/123456/MerchantName" or "Info*IMPS/.../Merchant"
  //    Common in SBI and other public sector bank SMS
  static final RegExp _infoFieldMerchantRegex = RegExp(
    r'info[:\*\-\s]+(?:imps|neft|upi|rtgs|p2p|p2m)/[^/\n]*/[^/\n]*/([^/\n,\.]{2,30})',
    caseSensitive: false,
  );

  // 3. Standard "at MERCHANT" or "to MERCHANT" — captures full merchant/person name
  //    e.g. "at ZOMATO on" / "to Ramesh Kumar via" / "at Amazon.in Ref"
  static final RegExp _standardMerchantRegex = RegExp(
    r'(?:at|to)\s+([A-Za-z0-9][A-Za-z0-9\s\-&.]{1,40}?)(?:\s+on\b|\s+via\b|\s+using\b|\s+ref\b|\s+avl\b|\s+bal\b|\s+a\/c\b|\.|\,|\n|$)',
    caseSensitive: false,
  );

  // 4. "for MERCHANT" — some HDFC/ICICI SMS use "for" before merchant name
  //    e.g. "charged for NETFLIX" / "debited for SWIGGY"
  static final RegExp _forMerchantRegex = RegExp(
    r'\bfor\s+([A-Za-z][A-Za-z0-9\s\-&.]{1,30}?)(?:\s+on\b|\s+via\b|\s+ref\b|\s+avl\b|\.|\,|\n|$)',
    caseSensitive: false,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // MAIN PARSE METHOD
  // ─────────────────────────────────────────────────────────────────────────
  static SmsParsedResult? parseSms(String sender, String body) {
    final lowerBody = body.toLowerCase();
    final lowerSender = sender.toLowerCase();

    // ── Step 1: Sender must be a known bank / payment app ──────────────────
    final bool isFinancialSender = _bankSenderPatterns.any(
      (p) => lowerSender.contains(p),
    );
    if (!isFinancialSender) return null;

    // ── Step 2: Must match a debit pattern (RegExp, word-boundary safe) ────
    final bool hasDebitKeyword = _debitPatterns.any(
      (pattern) => pattern.hasMatch(lowerBody),
    );
    if (!hasDebitKeyword) return null;

    // ── Step 3: Extract amount ─────────────────────────────────────────────
    // Primary: currency prefix (Rs./INR/₹ before the number)
    Match? amountMatch = _amountPrefixRegex.firstMatch(body);

    // Fallback: currency suffix (number before Rs/INR)
    amountMatch ??= _amountSuffixRegex.firstMatch(body);

    if (amountMatch == null) return null;

    final String amountStr = amountMatch.group(1)!.replaceAll(',', '');
    final double? amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) return null;

    // ── Step 4: Extract merchant (multi-strategy) ──────────────────────────
    final String merchant = _extractMerchant(body, sender);

    // ── Step 5: Categorise ─────────────────────────────────────────────────
    final String category = categorizeMerchant(merchant);

    // ── Step 6: Payment method ─────────────────────────────────────────────
    final bool isCard =
        lowerBody.contains('credit card') ||
        lowerBody.contains('debit card') ||
        RegExp(
          r'\bcard\s+(?:xx|ending|no\.?)\s*\d',
          caseSensitive: false,
        ).hasMatch(lowerBody);

    final bool isAtm =
        lowerBody.contains('atm') ||
        lowerBody.contains('cash withdrawal') ||
        lowerBody.contains('withdrawn cash');

    final bool isBankTransfer =
        lowerBody.contains('neft') ||
        lowerBody.contains('rtgs') ||
        lowerBody.contains('imps');

    // Detect UPI: explicit keyword, VPA (@), app names, UPI ref, or "Sent/Paid Rs... to..." templates
    final bool isUpi =
        lowerBody.contains('upi') ||
        lowerBody.contains('@') || // VPA address present
        lowerBody.contains('phonepe') ||
        lowerBody.contains('gpay') ||
        lowerBody.contains('google pay') ||
        lowerBody.contains('paytm') ||
        lowerBody.contains('bhim') ||
        lowerBody.contains('vpa') ||
        lowerBody.contains('cred') ||
        lowerBody.contains('amazon pay') ||
        RegExp(r'\bsent\s+(?:rs\.?|inr|₹)', caseSensitive: false).hasMatch(body) ||
        RegExp(r'\bpaid\s+(?:rs\.?|inr|₹)', caseSensitive: false).hasMatch(body) ||
        RegExp(r'upi\s*ref', caseSensitive: false).hasMatch(body);

    String paymentMethod;
    if (isAtm) {
      paymentMethod = 'Cash';
    } else if (isCard) {
      paymentMethod = 'Card';
    } else if (isUpi) {
      paymentMethod = 'UPI';
    } else if (isBankTransfer) {
      paymentMethod = 'Bank Transfer';
    } else {
      // Default for bank debit notifications from SMS is UPI
      paymentMethod = 'UPI';
    }

    return SmsParsedResult(
      amount: amount,
      type: 'Expense',
      merchant: merchant,
      category: category,
      paymentMethod: paymentMethod,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MERCHANT EXTRACTION — tries multiple strategies in order
  // ─────────────────────────────────────────────────────────────────────────
  static String _extractMerchant(String body, String sender) {
    // Strategy 1: VPA address (to/at name@handle)
    final Match? vpaMatch = _vpaMerchantRegex.firstMatch(body);
    if (vpaMatch != null) {
      final String m = vpaMatch.group(1)!.trim();
      if (m.isNotEmpty) return _cleanMerchantName(m);
    }

    // Strategy 2: Info field (SBI, PNB format — Info: IMPS/P2M/ref/Merchant)
    final Match? infoMatch = _infoFieldMerchantRegex.firstMatch(body);
    if (infoMatch != null) {
      final String m = infoMatch.group(1)!.trim();
      if (m.isNotEmpty && m.length > 2) return _cleanMerchantName(m);
    }

    // Strategy 3: "at MERCHANT" or "to MERCHANT"
    final Match? stdMatch = _standardMerchantRegex.firstMatch(body);
    if (stdMatch != null) {
      final String m = stdMatch.group(1)!.trim();
      // Reject if it looks like a bank/account phrase
      if (m.isNotEmpty && !_isBankPhrase(m)) return _cleanMerchantName(m);
    }

    // Strategy 4: "for MERCHANT" (HDFC/ICICI card SMS)
    final Match? forMatch = _forMerchantRegex.firstMatch(body);
    if (forMatch != null) {
      final String m = forMatch.group(1)!.trim();
      if (m.isNotEmpty && !_isBankPhrase(m)) return _cleanMerchantName(m);
    }

    // Fallback: use sender ID as merchant name (clean it up)
    return _cleanSenderName(sender);
  }

  // Reject matches that look like bank account phrases rather than merchants
  static bool _isBankPhrase(String m) {
    final lower = m.toLowerCase();
    return lower.contains('hdfc') ||
        lower.contains('icici') ||
        lower.contains('axis') ||
        lower.contains('sbi') ||
        lower.contains('bank') ||
        lower.contains('a/c') ||
        lower.contains('acct') ||
        lower.contains('account') ||
        lower.contains('saving') ||
        lower.contains('current') ||
        lower.startsWith('xx') ||
        RegExp(r'^\*+\d').hasMatch(m); // starts with "**1234"
  }

  // Clean up a matched merchant string
  static String _cleanMerchantName(String raw) {
    // Remove trailing punctuation and whitespace
    String cleaned = raw.trim().replaceAll(RegExp(r'[.,\-\s]+$'), '').trim();
    // Only title-case if it's all uppercase and NOT a VPA/email (contains '@')
    if (!cleaned.contains('@') && cleaned.length > 2 && cleaned == cleaned.toUpperCase()) {
      cleaned = cleaned[0].toUpperCase() + cleaned.substring(1).toLowerCase();
    }
    return cleaned.isEmpty ? raw.trim() : cleaned;
  }

  // Derive a readable name from the SMS sender ID (e.g. "AD-HDFCBK" → "HDFC")
  static String _cleanSenderName(String sender) {
    // Strip the 2-letter prefix if present (e.g. "AD-HDFCBK" → "HDFCBK")
    final cleaned = sender.replaceAll(RegExp(r'^[A-Z]{2}[-_]'), '').trim();
    return cleaned.isEmpty ? sender : cleaned;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MERCHANT CATEGORISATION
  // ─────────────────────────────────────────────────────────────────────────
  static String categorizeMerchant(String merchant) {
    final String ml = merchant.toLowerCase();

    const foodKeywords = [
      'starbucks',
      'zomato',
      'swiggy',
      'mcdonalds',
      'kfc',
      'restaurant',
      'cafe',
      'food',
      'blinkit',
      'bigbasket',
      'grofers',
      'dunzo',
      'dominos',
      'pizza',
      'burger',
      'dineout',
      'eatsure',
      'zepto',
      'instamart',
    ];
    const transportKeywords = [
      'uber',
      'ola',
      'irctc',
      'petrol',
      'fuel',
      'hpcl',
      'ioc',
      'bpcl',
      'metro',
      'rapido',
      'bus',
      'train',
      'flight',
      'airport',
      'indigo',
      'spicejet',
      'airindia',
      'makemytrip',
      'redbus',
    ];
    const shoppingKeywords = [
      'amazon',
      'flipkart',
      'myntra',
      'nykaa',
      'supermarket',
      'dmart',
      'reliance',
      'meesho',
      'ajio',
      'tata',
      'croma',
      'snapdeal',
      'shopsy',
      'jiomart',
    ];
    const utilitiesKeywords = [
      'airtel',
      'jio',
      'vi ',
      'bsnl',
      'bescom',
      'electricity',
      'water',
      'broadband',
      'recharge',
      'gas',
      'lpg',
      'postpaid',
      'tata power',
      'msedcl',
      'tneb',
      'wbsedcl',
    ];
    const entertainmentKeywords = [
      'netflix',
      'spotify',
      'prime',
      'hotstar',
      'pvr',
      'bookmyshow',
      'disney',
      'zee5',
      'sonyliv',
      'jiocinema',
      'youtube',
      'apple music',
      'gaana',
    ];
    const healthKeywords = [
      'pharmacy',
      'hospital',
      'apollo',
      'medplus',
      'clinic',
      'pharma',
      'medic',
      'health',
      'netmeds',
      '1mg',
      'practo',
      'tata 1mg',
      'cult.fit',
      'docprime',
    ];
    const educationKeywords = [
      'byju',
      'unacademy',
      'coursera',
      'udemy',
      'skill',
      'vedantu',
      'topper',
      'whitehat',
      'school',
      'college',
      'university',
      'exam',
    ];

    if (foodKeywords.any((k) => ml.contains(k))) return 'Food';
    if (transportKeywords.any((k) => ml.contains(k))) return 'Transportation';
    if (shoppingKeywords.any((k) => ml.contains(k))) return 'Shopping';
    if (utilitiesKeywords.any((k) => ml.contains(k))) return 'Utilities';
    if (entertainmentKeywords.any((k) => ml.contains(k))) return 'Entertainment';
    if (healthKeywords.any((k) => ml.contains(k))) return 'Health';
    if (educationKeywords.any((k) => ml.contains(k))) return 'Education';

    return 'Others';
  }
}
