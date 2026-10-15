class SmsParsedResult {
  final double amount;
  final String type;
  final String merchant;
  final String category;
  final String paymentMethod;
  final String? account;
  final double? availableBalance;
  final String? referenceNumber;

  SmsParsedResult({
    required this.amount,
    required this.type,
    required this.merchant,
    required this.category,
    required this.paymentMethod,
    this.account,
    this.availableBalance,
    this.referenceNumber,
  });
}

class SmsParser {
  // ─────────────────────────────────────────────────────────────────────────
  // SENDER WHITELIST & RECOGNITION
  // Covers all major Indian public & private banks, small finance banks,
  // payment banks, credit card issuers, and fintech UPI/wallets.
  // ─────────────────────────────────────────────────────────────────────────
  static const _bankSenderPatterns = [
    // Major Indian Banks
    'sbi', 'sbiinb', 'sbicrd', 'sbipsg', 'sbipay', 'sbiupi', 'sbin',
    'hdfc', 'hdfcbk', 'hdfcbn', 'hdfcba',
    'icici', 'icicib', 'icicip', 'icicic',
    'axis', 'axisbk', 'axisbn', 'axisbank', 'axismb',
    'kotak', 'kotakb', 'kmbl',
    'indus', 'indusb', 'indusind', 'indusbk', 'induslnd', // IndusInd Bank (covers all variations)
    'pnb', 'pnbsms', 'pnbup',
    'bob', 'bobsms', 'bobtxn', 'baroda',
    'canara', 'canarab', 'cnrbnk', 'canbnk',
    'idbi', 'idbibnk',
    'federal', 'fedbk', 'federalbnk',
    'union', 'unionbk', 'uboi',
    'yes', 'yesbnk', 'yesbank',
    'rbl', 'rblbnk', 'rblbank',
    'idfc', 'idfcfb', 'idfcbk',
    'uco', 'ucobk',
    'boi', 'boisms', 'boitxn',
    'cbi', 'cbin', 'centbk',
    'indbnk', 'indianb', 'indianbank',
    'iob', 'iobsms',
    'psb', 'psbsms',
    'bandhan', 'bdnbnk',
    'aubank',
    'equitas', 'eqtbk',
    'ujjivan', 'ujjvnb',
    'south', 'sib', 'sibbk',
    'ktk', 'ktkbnk', 'kbl',
    'kvb', 'kvbank',
    'cub', 'cubank',
    'dcb', 'dcbbnk',
    'scb', 'scbank', 'scbnk', 'stanchart',
    'hsbc', 'hsbcbk',
    'citi', 'citibnk', 'citibank',
    'dbs', 'dbsbnk',
    'amex', 'amx',
    // Wallets & UPI / Fintech
    'paytm', 'phonepe', 'gpay', 'google', 'amazon', 'amazonpay',
    'cred', 'credapp', 'slice', 'sliceit', 'onecard',
    'jupiter', 'niyo', 'fi', 'indmoney', 'mobikwik', 'freecharge',
    'airtel', 'airtelpb', 'airpay', 'razorpay', 'cashfree', 'payu',
    'bhim', 'tataneu', 'bajaj', 'bajajfin', 'nsdlpb',
    // Generic Financial Indicators in Sender Header
    'bnk', 'bank', 'wallet', 'upi', 'nbfc', 'pay',
  ];

  // Bank names and indicators that appear directly in SMS body signatures
  static const _bankBodyPatterns = [
    'indusind', 'hdfc', 'sbi', 'state bank', 'icici', 'axis', 'kotak',
    'pnb', 'punjab national', 'bank of baroda', 'canara', 'idbi',
    'federal bank', 'union bank', 'yes bank', 'rbl bank', 'idfc',
    'uco bank', 'bank of india', 'central bank', 'indian bank',
    'indian overseas', 'punjab & sind', 'bandhan', 'au small',
    'equitas', 'ujjivan', 'south indian bank', 'karnataka bank',
    'karur vysya', 'city union bank', 'standard chartered', 'hsbc',
    'citibank', 'dbs bank', 'american express', 'paytm payments',
    'airtel payments', 'bank',
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // DEBIT DETECTION PATTERNS
  // ─────────────────────────────────────────────────────────────────────────
  static final List<RegExp> _debitPatterns = [
    // Standard bank debit words
    RegExp(r'\bdebited\b', caseSensitive: false),
    RegExp(r'\bdebit\b', caseSensitive: false),
    RegExp(r'\bspent\b', caseSensitive: false),
    RegExp(r'\bwithdrawn\b', caseSensitive: false),
    RegExp(r'\bwithdrawal\b', caseSensitive: false),
    RegExp(r'\bcharged\b', caseSensitive: false),
    RegExp(r'\bpurchased?\b', caseSensitive: false),
    RegExp(r'\bdeducted\b', caseSensitive: false),

    // "Paid" variants
    RegExp(r'\bpaid\b', caseSensitive: false),
    RegExp(r'\bpayment\s+(?:of|for|to|done|success|made)', caseSensitive: false),

    // "Sent" variants
    RegExp(r'\bsent\s+(?:rs\.?|inr|₹|\d|to\s+\w)', caseSensitive: false),
    RegExp(r'\bsuccessfully\s+sent\b', caseSensitive: false),
    RegExp(r'\bmoney\s+sent\b', caseSensitive: false),

    // "Transferred/Transfer" variants
    RegExp(r'\btransferr?ed?\s+(?:to|of|rs\.?|inr|₹|\d)', caseSensitive: false),
    RegExp(r'\btransfer\s+(?:to|of)\b', caseSensitive: false),
    RegExp(r'\bby\s+transfer\s+to\b', caseSensitive: false),

    // Transaction / Txn
    RegExp(r'\b(?:transaction|txn)\s+(?:of|amt|done)\b', caseSensitive: false),

    // Card POS
    RegExp(r'\bused\s+(?:at|for|on)\b', caseSensitive: false),

    // Auto-debit / EMI / NACH
    RegExp(r'\bauto[- ]?debit\b', caseSensitive: false),
    RegExp(r'\bemi\s+(?:of|for|deducted|paid)\b', caseSensitive: false),
    RegExp(r'\bnach\s+debit\b', caseSensitive: false),

    // UPI-specific
    RegExp(r'\bupi\s+debit\b', caseSensitive: false),
    RegExp(r'\bupi\s+txn\b', caseSensitive: false),
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // FINANCIAL MESSAGE VALIDATION
  // Validates if sender or body represents a financial institution or alert
  // ─────────────────────────────────────────────────────────────────────────
  static bool isFinancialMessage(String sender, String body) {
    final lowerSender = sender.toLowerCase();
    // 1. Sender contains known financial entity ID
    if (_bankSenderPatterns.any((p) => lowerSender.contains(p))) {
      return true;
    }

    final lowerBody = body.toLowerCase();
    // 2. Body explicitly indicates a bank name in the footer or text
    if (_bankBodyPatterns.any((b) => lowerBody.contains(b))) {
      return true;
    }

    // 3. Structural financial pattern: has account/card reference + balance/ref/rrn
    final hasAccountOrCard = RegExp(
      r'\b(?:a\/c|acct|account|card)\b',
      caseSensitive: false,
    ).hasMatch(lowerBody);
    final hasFinancialRef = RegExp(
      r'\b(?:avl\s*bal|balance|bal\b|rrn|upi\s*ref|ref\s*(?:no)?|txn\s*(?:id)?)\b',
      caseSensitive: false,
    ).hasMatch(lowerBody);

    if (hasAccountOrCard && hasFinancialRef) {
      return true;
    }

    return false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MAIN PARSE METHOD
  // ─────────────────────────────────────────────────────────────────────────
  static SmsParsedResult? parseSms(String sender, String body) {
    final lowerBody = body.toLowerCase();

    // ── Step 1: Must be a financial message (sender or body check) ─────────
    if (!isFinancialMessage(sender, body)) return null;

    // ── Step 2: Must match a debit pattern ─────────────────────────────────
    final bool hasDebitKeyword = _debitPatterns.any(
      (pattern) => pattern.hasMatch(lowerBody),
    );
    if (!hasDebitKeyword) return null;

    // Reject pure credit/deposit messages (e.g. "INR 5000 credited to your account")
    final isPureCredit = RegExp(
          r'\b(?:credited|deposited|refund\s+received)\b',
          caseSensitive: false,
        ).hasMatch(lowerBody) &&
        !RegExp(
          r'\b(?:debited|spent|paid|withdrawn|charged|purchase|sent)\b',
          caseSensitive: false,
        ).hasMatch(lowerBody);
    if (isPureCredit) return null;

    // ── Step 3: Extract amount (prioritizing transaction amount over balances) ──
    final double? amount = _extractAmount(body);
    if (amount == null || amount <= 0) return null;

    // ── Step 4: Extract merchant / payee ───────────────────────────────────
    final String merchant = _extractMerchant(body, sender);

    // ── Step 5: Categorise ─────────────────────────────────────────────────
    final String category = categorizeMerchant(merchant);

    // ── Step 6: Payment method ─────────────────────────────────────────────
    final String paymentMethod = _extractPaymentMethod(body);

    // ── Step 7: Optional metadata ──────────────────────────────────────────
    final String? account = _extractAccount(body);
    final double? availableBalance = _extractAvailableBalance(body);
    final String? referenceNumber = _extractReferenceNumber(body);

    return SmsParsedResult(
      amount: amount,
      type: 'Expense',
      merchant: merchant,
      category: category,
      paymentMethod: paymentMethod,
      account: account,
      availableBalance: availableBalance,
      referenceNumber: referenceNumber,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AMOUNT EXTRACTION
  // Reliably isolates the debited/spent amount and avoids picking account
  // balance or phone numbers.
  // ─────────────────────────────────────────────────────────────────────────
  static double? _extractAmount(String body) {
    // Strategy 1: Look for amounts directly following debit action keywords.
    // E.g. "debited by Rs 1250.00", "debited by 250.0", "debited for Rs. 500",
    // "spent Rs 1,200", "paid Rs. 1,299", "sent Rs.1.00", "debited with INR 2,100.00"
    final directActionRegex = RegExp(
      r'(?:debited\s+(?:by|for|with|of)?|spent|paid|sent|withdrawn|transferred|deducted|charged|purchase\s+of|txn\s+of|payment\s+of)\s*(?:(?:amt\.?\s*)?(?:rs\.?|inr|₹)\s*)?([\d,]+\.?\d*)',
      caseSensitive: false,
    );
    final directActionMatch = directActionRegex.firstMatch(body);
    if (directActionMatch != null) {
      final valStr = directActionMatch.group(1)?.replaceAll(',', '');
      final val = double.tryParse(valStr ?? '');
      if (val != null && val > 0) return val;
    }

    // Strategy 2: Look for amounts immediately preceding debit action.
    // E.g. "Rs 450.00 debited", "INR 1,000.00 debited", "Rs. 1,200 spent", "₹500 paid"
    final reverseActionRegex = RegExp(
      r'(?:(?:amt\.?\s*)?(?:rs\.?|inr|₹)\s*)([\d,]+\.?\d*)\s*(?:debited|spent|withdrawn|transferred|paid|deducted|was\s+spent|done)',
      caseSensitive: false,
    );
    final reverseActionMatch = reverseActionRegex.firstMatch(body);
    if (reverseActionMatch != null) {
      final valStr = reverseActionMatch.group(1)?.replaceAll(',', '');
      final val = double.tryParse(valStr ?? '');
      if (val != null && val > 0) return val;
    }

    // Strategy 3: Scan all currency-prefixed amounts, skipping any balance amounts
    final allAmountMatches = RegExp(
      r'(?:(?:amt\.?\s*)?(?:rs\.?\s*|inr\s*)|₹\s*)([\d,]+\.?\d*)',
      caseSensitive: false,
    ).allMatches(body);

    for (final match in allAmountMatches) {
      final startIndex = match.start;
      final precedingText = body
          .substring(startIndex > 30 ? startIndex - 30 : 0, startIndex)
          .toLowerCase();

      // If preceded by bal / balance / limit / avl, skip it
      if (RegExp(
            r'\b(?:avl\s*bal|balance|bal|limit|total\s*bal)\s*[:\-is]?\s*$',
            caseSensitive: false,
          ).hasMatch(precedingText) ||
          precedingText.contains('bal') ||
          precedingText.contains('limit')) {
        continue;
      }

      final valStr = match.group(1)?.replaceAll(',', '');
      final val = double.tryParse(valStr ?? '');
      if (val != null && val > 0) return val;
    }

    // Strategy 4: Suffix currency format fallback: "1,250.00 Rs" or "500 INR"
    final suffixMatch = RegExp(
      r'([\d,]+\.?\d*)\s*(?:rs\.?|inr)',
      caseSensitive: false,
    ).firstMatch(body);
    if (suffixMatch != null) {
      final valStr = suffixMatch.group(1)?.replaceAll(',', '');
      final val = double.tryParse(valStr ?? '');
      if (val != null && val > 0) return val;
    }

    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MERCHANT / PAYEE EXTRACTION
  // Tries multiple strategies to identify the recipient or merchant
  // ─────────────────────────────────────────────────────────────────────────
  static String _extractMerchant(String body, String sender) {
    final lower = body.toLowerCase();

    // 0. ATM / Cash withdrawal check
    final isAtm = lower.contains('atm') ||
        lower.contains('cash withdrawal') ||
        lower.contains('withdrawn cash') ||
        lower.contains('atm wdl') ||
        lower.contains('cash wdl');
    if (isAtm) {
      return 'ATM Cash';
    }

    // 1. Explicit VPA address (e.g. "towards payee@bank", "to user@upi", "vpa abc@okhdfc")
    final vpaMatch = RegExp(
      r'(?:towards|to|at|vpa|in\s+favo(?:u)?r\s+of|favo(?:u)?ring|credited\s+to|transfer\s+to|sent\s+to|paid\s+to)\s+([A-Za-z0-9][A-Za-z0-9.\-_]{1,40}@[A-Za-z0-9.\-_]{2,})',
      caseSensitive: false,
    ).firstMatch(body);
    if (vpaMatch != null) {
      final m = vpaMatch.group(1)!.trim();
      if (m.isNotEmpty) return _cleanMerchantName(m);
    }

    // 1b. Standalone VPA in SMS
    final anyVpaMatch = RegExp(
      r'\b([A-Za-z0-9][A-Za-z0-9.\-_]{1,40}@[A-Za-z0-9.\-_]{2,})\b',
      caseSensitive: false,
    ).firstMatch(body);
    if (anyVpaMatch != null) {
      final m = anyVpaMatch.group(1)!.trim();
      if (!m.contains('support@') && !m.contains('help@') && !m.contains('care@')) {
        return _cleanMerchantName(m);
      }
    }

    // 2. Info field patterns
    // ICICI Info: "Info: UPI*Zomato*zomato@icici*123456" or "Info: BIL*123456*Netflix"
    final iciciInfoMatch = RegExp(
      r'info[:\*\-\s]+(?:upi|bil|imps)\*([^\n\.]*)',
      caseSensitive: false,
    ).firstMatch(body);
    if (iciciInfoMatch != null) {
      final parts = iciciInfoMatch.group(1)!.split('*');
      for (final part in parts) {
        final candidate = part.trim();
        if (candidate.isNotEmpty &&
            !RegExp(r'^\d+$').hasMatch(candidate) &&
            !_isBankPhrase(candidate)) {
          return _cleanMerchantName(candidate);
        }
      }
    }

    // SBI / PNB Info: "Info: IMPS/P2M/123456/Merchant" or "Info: UPI/3284729182/Merchant"
    final infoMatch = RegExp(
      r'info[:\*\-\s]+(?:imps|neft|upi|rtgs|p2p|p2m|bil)/[^/\n]*/[^/\n]*/([^/\n,\.]{2,30})',
      caseSensitive: false,
    ).firstMatch(body);
    if (infoMatch != null) {
      final m = infoMatch.group(1)!.trim();
      if (m.isNotEmpty && m.length > 2 && !_isBankPhrase(m)) return _cleanMerchantName(m);
    }

    // Short Info: "Info: UPI/ref/Merchant"
    final shortInfoMatch = RegExp(
      r'info[:\*\-\s]+upi/[^/\n]*/([^/\n,\.]{2,30})',
      caseSensitive: false,
    ).firstMatch(body);
    if (shortInfoMatch != null) {
      final m = shortInfoMatch.group(1)!.trim();
      if (m.isNotEmpty && m.length > 2 && !_isBankPhrase(m)) return _cleanMerchantName(m);
    }

    // 3. "towards MERCHANT" — common in IndusInd, Axis, SBI, ICICI
    // E.g. "towards yashawantrangrej-2@xis. RRN:6227103" or "towards Swiggy."
    final towardsMatch = RegExp(
      r'\btowards\s+([A-Za-z0-9][A-Za-z0-9\s\-&.@]{1,40}?)(?:\s+on\b|\s+via\b|\s+using\b|\s+ref\b|\s+rrn\b|\s+avl\b|\s+bal\b|\s+a\/c\b|\.|\,|\n|$)',
      caseSensitive: false,
    ).firstMatch(body);
    if (towardsMatch != null) {
      final m = towardsMatch.group(1)!.trim();
      if (m.isNotEmpty && !_isBankPhrase(m)) return _cleanMerchantName(m);
    }

    // 4. "in favour of / favouring MERCHANT" — common in Canara, PNB, BOB, Union
    final favourMatch = RegExp(
      r'\b(?:in\s+favo(?:u)?r\s+of|favo(?:u)?ring)\s+([A-Za-z0-9][A-Za-z0-9\s\-&.@]{1,40}?)(?:\s+on\b|\s+via\b|\s+using\b|\s+ref\b|\s+rrn\b|\s+avl\b|\s+bal\b|\s+a\/c\b|\.|\,|\n|$)',
      caseSensitive: false,
    ).firstMatch(body);
    if (favourMatch != null) {
      final m = favourMatch.group(1)!.trim();
      if (m.isNotEmpty && !_isBankPhrase(m)) return _cleanMerchantName(m);
    }

    // 5. "transfer to / by transfer to MERCHANT" — common in SBI, HDFC
    final transferMatch = RegExp(
      r'\b(?:by\s+transfer\s+to|transfer\s+to|transferr?ed\s+to)\s+([A-Za-z0-9][A-Za-z0-9\s\-&.@]{1,40}?)(?:\s*\((?:upi\s*)?ref|\s+on\b|\s+via\b|\s+using\b|\s+ref\b|\s+rrn\b|\s+avl\b|\s+bal\b|\s+a\/c\b|\.|\,|\n|$)',
      caseSensitive: false,
    ).firstMatch(body);
    if (transferMatch != null) {
      final m = transferMatch.group(1)!.trim();
      if (m.isNotEmpty && !_isBankPhrase(m)) return _cleanMerchantName(m);
    }

    // 6. "at MERCHANT" or "to MERCHANT" or "sent to" or "paid to"
    // E.g. "at Starbucks via UPI" / "to Yashawant janardhanasa ra on 13-10-26" / "at AMAZON on"
    final stdMatch = RegExp(
      r'\b(?:at|to|sent\s+to|paid\s+to)\s+([A-Za-z0-9][A-Za-z0-9\s\-&.@]{1,40}?)(?:\s+on\b|\s+via\b|\s+using\b|\s+from\b|\s+ref\b|\s+rrn\b|\s+avl\b|\s+bal\b|\s+a\/c\b|\.|\,|\n|$)',
      caseSensitive: false,
    ).firstMatch(body);
    if (stdMatch != null) {
      final m = stdMatch.group(1)!.trim();
      if (m.isNotEmpty && !_isBankPhrase(m)) return _cleanMerchantName(m);
    }

    // 7. "for MERCHANT" — e.g. "charged for NETFLIX"
    final forMatch = RegExp(
      r'\b(?:charged\s+for|debited\s+for|used\s+for|payment\s+for)\s+([A-Za-z0-9][A-Za-z0-9\s\-&.@]{1,30}?)(?:\s+on\b|\s+via\b|\s+using\b|\s+ref\b|\s+rrn\b|\s+avl\b|\s+bal\b|\.|\,|\n|$)',
      caseSensitive: false,
    ).firstMatch(body);
    if (forMatch != null) {
      final m = forMatch.group(1)!.trim();
      if (m.isNotEmpty && !_isBankPhrase(m)) return _cleanMerchantName(m);
    }

    // Fallback: derive sender name
    final cleanedSender = _cleanSenderName(sender);
    if (cleanedSender.isNotEmpty && cleanedSender != 'UNKNOWN') {
      return cleanedSender;
    }

    // Try finding bank name in footer (e.g. "- IndusInd bank" -> "IndusInd Bank")
    final bankInBodyMatch = RegExp(
      r'[\-\s]+([A-Za-z]+(?:\s+bank)?)\s*$',
      caseSensitive: false,
    ).firstMatch(body);
    if (bankInBodyMatch != null) {
      final bName = bankInBodyMatch.group(1)!.trim();
      if (bName.length > 2) return _cleanMerchantName(bName);
    }

    return 'Bank Transaction';
  }

  // Reject matches that look like bank account phrases rather than merchants
  static bool _isBankPhrase(String m) {
    if (m.contains('@')) return false; // VPAs are valid merchant handles
    final lower = m.toLowerCase().trim();
    if (RegExp(r'\b(?:a\/c|acct|account|saving|current)\b').hasMatch(lower)) {
      return true;
    }
    if (lower.startsWith('xx') || RegExp(r'^\*+\d').hasMatch(lower)) {
      return true;
    }
    if (RegExp(
      r'\b(?:bank|hdfc|icici|axis|sbi|kotak|pnb|bob|canara|indusind)\s+(?:a\/c|acct|account|branch)\b',
    ).hasMatch(lower)) {
      return true;
    }
    return false;
  }

  // Clean up a matched merchant string
  static String _cleanMerchantName(String raw) {
    String cleaned = raw.trim().replaceAll(RegExp(r'[.,\-\s]+$'), '').trim();
    if (cleaned.toLowerCase().startsWith('vpa:')) {
      cleaned = cleaned.substring(4).trim();
    } else if (cleaned.toLowerCase().startsWith('vpa ')) {
      cleaned = cleaned.substring(4).trim();
    }
    // Only title-case if it's all uppercase and NOT a VPA/email (contains '@')
    if (!cleaned.contains('@') &&
        cleaned.length > 2 &&
        cleaned == cleaned.toUpperCase()) {
      cleaned = cleaned[0].toUpperCase() + cleaned.substring(1).toLowerCase();
    }
    return cleaned.isEmpty ? raw.trim() : cleaned;
  }

  // Derive a readable name from the SMS sender ID (e.g. "AD-HDFCBK" → "HDFCBK")
  static String _cleanSenderName(String sender) {
    final cleaned = sender.replaceAll(RegExp(r'^[A-Z]{2}[-_]'), '').trim();
    return cleaned.isEmpty ? sender : cleaned;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PAYMENT METHOD DETECTION
  // ─────────────────────────────────────────────────────────────────────────
  static String _extractPaymentMethod(String body) {
    final lowerBody = body.toLowerCase();

    final bool isAtm = lowerBody.contains('atm') ||
        lowerBody.contains('cash withdrawal') ||
        lowerBody.contains('withdrawn cash') ||
        lowerBody.contains('atm wdl') ||
        lowerBody.contains('cash wdl');

    final bool isCard = lowerBody.contains('credit card') ||
        lowerBody.contains('debit card') ||
        RegExp(
          r'\b(?:card\s+(?:xx|ending|no\.?)|card\s*purchase|pos\s*txn)\b',
          caseSensitive: false,
        ).hasMatch(lowerBody);

    final bool isBankTransfer = lowerBody.contains('neft') ||
        lowerBody.contains('rtgs') ||
        lowerBody.contains('imps') ||
        lowerBody.contains('netbanking') ||
        lowerBody.contains('internet banking');

    final bool isUpi = lowerBody.contains('upi') ||
        lowerBody.contains('@') ||
        lowerBody.contains('phonepe') ||
        lowerBody.contains('gpay') ||
        lowerBody.contains('google pay') ||
        lowerBody.contains('paytm') ||
        lowerBody.contains('bhim') ||
        lowerBody.contains('vpa') ||
        lowerBody.contains('cred') ||
        lowerBody.contains('amazon pay') ||
        lowerBody.contains('rrn') ||
        RegExp(r'\bsent\s+(?:rs\.?|inr|₹)', caseSensitive: false).hasMatch(body) ||
        RegExp(r'\bpaid\s+(?:rs\.?|inr|₹)', caseSensitive: false).hasMatch(body) ||
        RegExp(r'upi\s*ref', caseSensitive: false).hasMatch(body);

    if (isAtm) return 'Cash';
    if (isCard) return 'Card';
    if (isUpi) return 'UPI';
    if (isBankTransfer) return 'Bank Transfer';
    return 'UPI';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // METADATA EXTRACTION (Account, Available Balance, Reference Number)
  // ─────────────────────────────────────────────────────────────────────────
  static double? _extractAvailableBalance(String body) {
    final balMatch = RegExp(
      r'(?:avl\s*bal|available\s*balance|total\s*bal|bal|balance)\s*(?:is|:|\-)?\s*(?:rs\.?|inr|₹)?\s*([\d,]+\.?\d*)',
      caseSensitive: false,
    ).firstMatch(body);
    if (balMatch != null) {
      final valStr = balMatch.group(1)?.replaceAll(',', '');
      return double.tryParse(valStr ?? '');
    }
    return null;
  }

  static String? _extractReferenceNumber(String body) {
    final refMatch = RegExp(
      r'\b(?:rrn|upi\s*ref(?:\s*no)?|ref(?:\s*no)?|txn\s*(?:id|no)?)\s*[:\-]?\s*([A-Za-z0-9]+)',
      caseSensitive: false,
    ).firstMatch(body);
    return refMatch?.group(1);
  }

  static String? _extractAccount(String body) {
    final accMatch = RegExp(
      r'\b(?:a\/c|acct|account|card)\s*(?:no\.?)?\s*[:\-]?\s*[*xX\d]*([*xX\d]{4,})\b',
      caseSensitive: false,
    ).firstMatch(body);
    return accMatch?.group(1);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MERCHANT CATEGORISATION
  // ─────────────────────────────────────────────────────────────────────────
  static String categorizeMerchant(String merchant) {
    final String ml = merchant.toLowerCase();

    const foodKeywords = [
      'starbucks', 'zomato', 'swiggy', 'mcdonalds', 'kfc', 'restaurant',
      'cafe', 'food', 'blinkit', 'bigbasket', 'grofers', 'dunzo',
      'dominos', 'pizza', 'burger', 'dineout', 'eatsure', 'zepto',
      'instamart', 'chaayos', 'chai', 'coffee', 'bakery', 'hotel', 'dhaba',
    ];
    const transportKeywords = [
      'uber', 'ola', 'irctc', 'petrol', 'fuel', 'hpcl', 'ioc', 'bpcl',
      'metro', 'rapido', 'bus', 'train', 'flight', 'airport', 'indigo',
      'spicejet', 'airindia', 'makemytrip', 'redbus', 'toll', 'fastag',
      'parking', 'auto', 'cab',
    ];
    const shoppingKeywords = [
      'amazon', 'flipkart', 'myntra', 'nykaa', 'supermarket', 'dmart',
      'reliance', 'meesho', 'ajio', 'tata', 'croma', 'snapdeal', 'shopsy',
      'jiomart', 'retail', 'store', 'mall', 'mart', 'clothes', 'fashion',
    ];
    const utilitiesKeywords = [
      'airtel', 'jio', 'vi ', 'bsnl', 'bescom', 'electricity', 'water',
      'broadband', 'recharge', 'gas', 'lpg', 'postpaid', 'tata power',
      'msedcl', 'tneb', 'wbsedcl', 'billdesk', 'bbps', 'dth', 'tata sky',
      'dish tv', 'act fibernet', 'wifi',
    ];
    const entertainmentKeywords = [
      'netflix', 'spotify', 'prime', 'hotstar', 'pvr', 'bookmyshow',
      'disney', 'zee5', 'sonyliv', 'jiocinema', 'youtube', 'apple music',
      'gaana', 'cinema', 'movie', 'theatre', 'gaming', 'steam',
    ];
    const healthKeywords = [
      'pharmacy', 'hospital', 'apollo', 'medplus', 'clinic', 'pharma',
      'medic', 'health', 'netmeds', '1mg', 'practo', 'tata 1mg',
      'cult.fit', 'docprime', 'dental', 'diagnostic', 'pathology',
      'lab', 'wellness',
    ];
    const educationKeywords = [
      'byju', 'unacademy', 'coursera', 'udemy', 'skill', 'vedantu',
      'topper', 'whitehat', 'school', 'college', 'university', 'exam',
      'fee', 'fees', 'tuition', 'coaching', 'classes', 'academy',
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
