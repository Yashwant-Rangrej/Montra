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
    'sbi', 'sbiinb', 'sbicrd', 'sbipsg', 'sbipay', 'sbiupi', 'sbin', 'sbcard', 'sbism',
    'hdfc', 'hdfcbk', 'hdfcbn', 'hdfcba', 'hdfccc', 'hdfcup', 'hdfcsm', 'hdfcal', 'hdfclt', 'hdfcad', 'hdfclife',
    'icici', 'icicib', 'icicip', 'icicic', 'icicim', 'icicik',
    'axis', 'axisbk', 'axisbn', 'axisbank', 'axismb', 'axismp', 'axispg',
    'kotak', 'kotakb', 'kmbl', 'kotakm',
    'indus', 'indusb', 'indusind', 'indusbk', 'induslnd', 'indusm',
    'pnb', 'pnbsms', 'pnbup', 'pnbmb',
    'bob', 'bobsms', 'bobtxn', 'bobtrn', 'baroda', 'bobup', 'bobibk',
    'canara', 'canarab', 'cnrbnk', 'canbnk', 'canup',
    'idbi', 'idbibnk', 'idbimb',
    'federal', 'fedbk', 'federalbnk', 'fedbnk',
    'union', 'unionbk', 'uboi', 'ubisms', 'unionb',
    'yes', 'yesbnk', 'yesbank', 'yesup',
    'rbl', 'rblbnk', 'rblbank', 'rblcrd',
    'idfc', 'idfcfb', 'idfcbk', 'idfcbn',
    'uco', 'ucobk', 'ucosms',
    'boi', 'boisms', 'boitxn', 'boimb',
    'cbi', 'cbin', 'centbk', 'cbisms',
    'indbnk', 'indianb', 'indianbank', 'indbk',
    'iob', 'iobsms', 'iobnet',
    'psb', 'psbsms',
    'bandhan', 'bdnbnk', 'bdnbk',
    'aubank', 'ausfb', 'ausfbn',
    'equitas', 'eqtbk', 'eqsfbn',
    'ujjivan', 'ujjvnb', 'ujsfbn',
    'janasf', 'janabk', 'janasfb',
    'suryod', 'utkarsh', 'esaf', 'fincare', 'shivalik',
    'south', 'sib', 'sibbk', 'sibbnk',
    'ktk', 'ktkbnk', 'kbl', 'kblsms',
    'kvb', 'kvbank', 'kvbbnk',
    'cub', 'cubank', 'cubbnk',
    'dcb', 'dcbbnk',
    'scb', 'scbank', 'scbnk', 'stanchart',
    'hsbc', 'hsbcbk', 'hsbcin',
    'citi', 'citibnk', 'citibank',
    'dbs', 'dbsbnk', 'dbssin',
    'amex', 'amx', 'amexin',
    // Wallets, UPI & Fintech
    'paytm', 'phonepe', 'gpay', 'google', 'amazon', 'amazonpay',
    'cred', 'credapp', 'slice', 'sliceit', 'onecard',
    'jupiter', 'niyo', 'fi', 'fimoney', 'indmoney', 'mobikwik', 'freecharge',
    'airtel', 'airtelpb', 'airpay', 'razorpay', 'cashfree', 'payu',
    'bhim', 'tataneu', 'bajaj', 'bajajfin', 'nsdlpb', 'ippb', 'postpe',
    'scapia', 'uni', 'unicard', 'simpl', 'lazypay', 'olamoney', 'fampay',
    'npci', 'npciup',
    // Generic Financial Indicators in Sender Header
    'bnk', 'bank', 'wallet', 'upi', 'nbfc', 'pay', 'crd', 'card',
    'alert', 'alerts', 'trans', 'txn', 'fin', 'stmt',
  ];

  // Bank names and indicators that appear directly in SMS body signatures
  static const _bankBodyPatterns = [
    'indusind',
    'hdfc',
    'sbi',
    'state bank',
    'icici',
    'axis',
    'kotak',
    'pnb',
    'punjab national',
    'bank of baroda',
    'canara',
    'idbi',
    'federal bank',
    'union bank',
    'yes bank',
    'rbl bank',
    'idfc',
    'uco bank',
    'bank of india',
    'central bank',
    'indian bank',
    'indian overseas',
    'punjab & sind',
    'bandhan',
    'au small',
    'equitas',
    'ujjivan',
    'jana small',
    'south indian bank',
    'karnataka bank',
    'karur vysya',
    'city union bank',
    'standard chartered',
    'hsbc',
    'citibank',
    'dbs bank',
    'american express',
    'paytm',
    'phonepe',
    'google pay',
    'gpay',
    'amazon pay',
    'cred',
    'bhim',
    'onecard',
    'slice',
    'scapia',
    'jupiter',
    'fi money',
    'airtel payments',
    'fampay',
    'mobikwik',
    'freecharge',
    'postpe',
    'simpl',
    'lazypay',
    'bank',
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // SPAM & NON-TRANSACTION REJECTION PATTERNS
  // Immediately filters out OTPs, promotional loan offers, declined txns, etc.
  // ─────────────────────────────────────────────────────────────────────────
  static final List<RegExp> _ignorePatterns = [
    // OTP & Verification codes
    RegExp(r'\b(?:otp|one\s+time\s+password|verification\s+code|security\s+code|login\s+code|auth\s+code|secret\s+code|passcode)\b', caseSensitive: false),
    RegExp(r'\b(?:do\s+not\s+share|never\s+share\s+your\s+otp|valid\s+for\s+\d+\s*(?:mins?|minutes?)|use\s+this\s+code)\b', caseSensitive: false),

    // Promotional & Loan offers
    RegExp(r'\b(?:pre[- ]?approved|apply\s+for|apply\s+now|get\s+instant\s+loan|congratulations!\s+you\s+are\s+eligible|claim\s+your|avail\s+now|limited\s+period\s+offer|zero\s+interest|win\s+cash|lottery)\b', caseSensitive: false),

    // Payment Requests / Mandates / Collect requests (not yet paid)
    RegExp(r'\b(?:has\s+requested|requesting\s+(?:rs\.?|inr|₹|\d)|collect\s+request|mandate\s+request|approval\s+request|pay\s+or\s+decline|is\s+requesting\s+a\s+payment|autopay\s+request)\b', caseSensitive: false),

    // Transaction Declined / Failed / Reversed
    RegExp(r'\b(?:transaction\s+declined|payment\s+declined|txn\s+declined|declined\s+due\s+to|failed\s+due\s+to|transaction\s+failed|payment\s+failed|insufficient\s+funds|unsuccessful|cancelled\b|could\s+not\s+be\s+processed)\b', caseSensitive: false),

    // Pure balance inquiry without any transaction
    RegExp(r'\b(?:mini\s+statement|statement\s+for\s+the\s+period|uncleared\s+balance)\b', caseSensitive: false),
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // DEBIT DETECTION PATTERNS
  // Comprehensive patterns matching all known Indian debit / payment formats
  // ─────────────────────────────────────────────────────────────────────────
  static final List<RegExp> _debitPatterns = [
    // Standard bank debit words (handles 00debited concatenation edge case)
    RegExp(r'(?:\b|\d)debited\b', caseSensitive: false),
    RegExp(r'\bdebit\b', caseSensitive: false),
    RegExp(r'\bdr\.?\b', caseSensitive: false),
    RegExp(r'\bspent\b', caseSensitive: false),
    RegExp(r'\bspending\b', caseSensitive: false),
    RegExp(r'\bwithdrawn\b', caseSensitive: false),
    RegExp(r'\bwithdrawal\b', caseSensitive: false),
    RegExp(r'\bwithdrew\b', caseSensitive: false),
    RegExp(r'\bcharged\b', caseSensitive: false),
    RegExp(r'\bpurchased?\b', caseSensitive: false),
    RegExp(r'\bdeducted\b', caseSensitive: false),

    // Hindi debit words
    RegExp(r'(?:काटे\s*गए|निकाले\s*गए)', caseSensitive: false),

    // "Paid" variants
    RegExp(r'\bpaid\b', caseSensitive: false),
    RegExp(r'\bpayment\s+(?:of|for|to|done|success|successful|made)', caseSensitive: false),

    // "Sent" variants
    RegExp(r'\bsent\s+(?:rs\.?|inr|₹|\$|\d|to\s+\w)', caseSensitive: false),
    RegExp(r'\bsent\b', caseSensitive: false),
    RegExp(r'\bsuccessfully\s+sent\b', caseSensitive: false),
    RegExp(r'\bmoney\s+sent\b', caseSensitive: false),

    // "Transferred/Transfer" variants
    RegExp(r'\btransferr?ed?\b', caseSensitive: false),
    RegExp(r'\btransfer\s+(?:to|of|from)\b', caseSensitive: false),
    RegExp(r'\bby\s+transfer\s+to\b', caseSensitive: false),
    RegExp(r'\bfunds?\s+transferred\b', caseSensitive: false),

    // NEFT / IMPS / RTGS transfers from account
    RegExp(r'\b(?:neft|imps|rtgs)\s+(?:of|trn|txn|transfer|from|:)\b', caseSensitive: false),

    // Transaction / Txn / Trnsctn
    RegExp(r'\b(?:transaction|txn|trnsctn)\s+(?:of|amt|done|at|successful)\b', caseSensitive: false),
    RegExp(r'\b(?:transaction|txn)\s+has\s+been\s+made\b', caseSensitive: false),

    // Card POS / Usage
    RegExp(r'\bused\s+(?:at|for|on)\b', caseSensitive: false),
    RegExp(r'\bcard\s+purchase\b', caseSensitive: false),
    RegExp(r'\bpos\s+(?:txn|purchase|transaction)\b', caseSensitive: false),

    // Auto-debit / Standing instruction / EMI / NACH / Fees
    RegExp(r'\bauto[- ]?debit\b', caseSensitive: false),
    RegExp(r'\bstanding\s+instruction\b', caseSensitive: false),
    RegExp(r'\bsi\s+debit\b', caseSensitive: false),
    RegExp(r'\bemi\s+(?:of|for|deducted|paid)\b', caseSensitive: false),
    RegExp(r'\bnach\s+debit\b', caseSensitive: false),
    RegExp(r'\becs\s+debit\b', caseSensitive: false),
    RegExp(r'\b(?:service\s+fee|service\s+charge|alert\s+fee|charges\s+for)\b', caseSensitive: false),

    // UPI-specific
    RegExp(r'\bupi\s+(?:debit|txn|transaction|payment)\b', caseSensitive: false),
    RegExp(r'\bvia\s+upi\b', caseSensitive: false),
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // FINANCIAL MESSAGE VALIDATION
  // Validates if sender or body represents a financial institution or alert
  // ─────────────────────────────────────────────────────────────────────────
  static bool isFinancialMessage(String sender, String body) {
    final lowerSender = sender.toLowerCase();
    final lowerBody = body.toLowerCase();

    // 1. Sender contains known financial entity ID
    if (_bankSenderPatterns.any((p) => lowerSender.contains(p))) {
      return true;
    }

    // 2. Body explicitly indicates a bank or payment entity
    if (_bankBodyPatterns.any((b) => lowerBody.contains(b))) {
      return true;
    }

    // 3. Structural financial pattern: has account/card/wallet + ref/balance/txn/rrn/upi
    final hasAccountOrCard = RegExp(
      r'(?:\b(?:a\/?c(?:count)?|acct|ac|card|wallet|vpa|chq|cheque)\b|onecard)',
      caseSensitive: false,
    ).hasMatch(lowerBody);
    final hasFinancialRef = RegExp(
      r'\b(?:avl\s*bal|balance|bal\b|rrn|upi\s*ref|ref\s*(?:no)?|refno|txn\s*(?:id|no)?|trans\s*id|utr|imps|neft|rtgs|cr\.?|dr\.?)\b',
      caseSensitive: false,
    ).hasMatch(lowerBody);
    final hasCurrencyAmount = RegExp(
      r'(?:(?:rs\.?:?|inr|₹|rupees|\$|usd|eur|gbp)\s*[\d,]+|[\d,]+\.?\d*\s*(?:rs\.?:?|inr|rupees|\$|usd|eur|gbp))',
      caseSensitive: false,
    ).hasMatch(lowerBody);

    if (hasAccountOrCard && (hasFinancialRef || hasCurrencyAmount)) {
      return true;
    }

    // 4. Action + Currency + Context keyword (handles messages with unlisted sender IDs)
    final hasDebitAction = _debitPatterns.any((p) => p.hasMatch(lowerBody));
    final hasTransactionContext = RegExp(
      r'\b(?:upi|ref|rrn|vpa|a\/c|account|card|wallet|bal|balance|bank|merchant|payee|towards|at|to|via|using|from)\b',
      caseSensitive: false,
    ).hasMatch(lowerBody);

    if (hasDebitAction && hasCurrencyAmount && hasTransactionContext) {
      return true;
    }

    return false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MAIN PARSE METHOD
  // ─────────────────────────────────────────────────────────────────────────
  static SmsParsedResult? parseSms(String sender, String body) {
    final lowerBody = body.toLowerCase();

    // ── Step 1: Reject Spam / OTP / Requests / Declined messages ───────────
    if (_ignorePatterns.any((p) => p.hasMatch(lowerBody))) {
      return null;
    }

    // ── Step 2: Must be a financial message (sender or body check) ─────────
    if (!isFinancialMessage(sender, body)) return null;

    // ── Step 3: Must match a debit pattern ─────────────────────────────────
    final bool hasDebitKeyword = _debitPatterns.any(
      (pattern) => pattern.hasMatch(lowerBody),
    );
    if (!hasDebitKeyword) return null;

    // Reject pure credit/deposit messages (e.g. "INR 5000 credited to your account")
    final isPureCredit =
        RegExp(
          r'\b(?:credited|deposited|refund\s+received|cashback\s+of|salary\s+credited)\b',
          caseSensitive: false,
        ).hasMatch(lowerBody) &&
        !RegExp(
          r'(?:\b|\d)(?:debited|spent|paid|withdrawn|charged|purchase|sent|dr\.?|काटे\s*गए)\b',
          caseSensitive: false,
        ).hasMatch(lowerBody);
    if (isPureCredit) return null;

    // ── Step 4: Extract amount (prioritizing transaction amount over balances) ──
    final double? amount = _extractAmount(body);
    if (amount == null || amount <= 0) return null;

    // ── Step 5: Extract merchant / payee ───────────────────────────────────
    final String merchant = _extractMerchant(body, sender);

    // ── Step 6: Categorise ─────────────────────────────────────────────────
    final String category = categorizeMerchant(merchant);

    // ── Step 7: Payment method ─────────────────────────────────────────────
    final String paymentMethod = _extractPaymentMethod(body);

    // ── Step 8: Optional metadata ──────────────────────────────────────────
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
  // balance, phone numbers, reference numbers, or limits.
  // ─────────────────────────────────────────────────────────────────────────
  static double? _extractAmount(String body) {
    // Strategy 1: Look for amounts directly following debit action keywords.
    // E.g. "debited by Rs 1250.00", "debited by 250.0", "debited for Rs. 500",
    // "spent Rs 1,200", "paid Rs. 1,299", "sent Rs.200.00", "debited with INR 2,100.00",
    // "fee: Rs 15", "charges for: Rs 100", "trnsctn of ₹41681", "NEFT of Rs.404,768.00"
    final directActionRegex = RegExp(
      r'(?:debited\s*(?:by|for|with|of)?|spent|spending\s+of|paid|sent|withdrawn|transferred\s*(?:from|to)?|deducted|charged|purchase\s+of|txn\s+of|transaction\s+of|trnsctn\s+of|payment\s+of|neft\s+of|imps\s+of|rtgs\s+of|fee[:\s]|charges?\s+for|emi\s+of)\s*(?:(?:amt\.?\s*|amount\s*[:\-]?\s*)?(?:rs\.?:?|inr|₹|rupees|\$|usd|eur|gbp)\s*)?([\d,]+\.?\d*)',
      caseSensitive: false,
    );
    final directActionMatch = directActionRegex.firstMatch(body);
    if (directActionMatch != null) {
      final valStr = directActionMatch.group(1)?.replaceAll(',', '');
      final val = double.tryParse(valStr ?? '');
      if (val != null && val > 0 && val < 100000000) return val;
    }

    // Strategy 2: Look for amounts immediately preceding debit action.
    // E.g. "Rs 450.00 debited", "INR 1,000.00 debited", "Rs. 1,200 spent", "₹500 paid", "EMI of 61741.00 debited"
    final reverseActionRegex = RegExp(
      r'(?:(?:(?:amt\.?\s*|amount\s*[:\-]?\s*)?(?:rs\.?:?|inr|₹|rupees|\$|usd|eur|gbp)\s*)|\bemi\s+of\s+)([\d,]+\.?\d*)\s*(?:debited|dr\.?|spent|withdrawn|transferred|paid|deducted|was\s+spent|done|successful|काटे\s*गए|निकाले\s*गए)',
      caseSensitive: false,
    );
    final reverseActionMatch = reverseActionRegex.firstMatch(body);
    if (reverseActionMatch != null) {
      final valStr = reverseActionMatch.group(1)?.replaceAll(',', '');
      final val = double.tryParse(valStr ?? '');
      if (val != null && val > 0 && val < 100000000) return val;
    }

    // Strategy 3: Scan all currency-prefixed amounts, skipping any balance amounts
    final allAmountMatches = RegExp(
      r'(?:(?:amt\.?\s*|amount\s*[:\-]?\s*)?(?:rs\.?:?\s*|inr\s*|rupees\s*|\$\s*|usd\s*|eur\s*|gbp\s*)|₹\s*)([\d,]+\.?\d*)',
      caseSensitive: false,
    ).allMatches(body);

    for (final match in allAmountMatches) {
      final startIndex = match.start;
      final precedingText = body
          .substring(startIndex > 35 ? startIndex - 35 : 0, startIndex)
          .toLowerCase();

      // If preceded by bal / balance / limit / avl / total / remaining, skip it
      if (RegExp(
            r'\b(?:avl\s*bal|balance|bal|limit|total\s*bal|tot\s*bal|remaining|rem\s*bal)\s*[:\-is]?\s*$',
            caseSensitive: false,
          ).hasMatch(precedingText) ||
          precedingText.contains('bal') ||
          precedingText.contains('limit') ||
          precedingText.contains('remaining')) {
        continue;
      }

      final valStr = match.group(1)?.replaceAll(',', '');
      final val = double.tryParse(valStr ?? '');
      if (val != null && val > 0 && val < 100000000) return val;
    }

    // Strategy 4: Direct debit amount without currency symbol (SBI format: "debited by 250.0 on...")
    final noCurrencyMatch = RegExp(
      r'(?:\bdebited\s+by\s+|\bemi\s+of\s+)([\d,]+\.?\d*)\b',
      caseSensitive: false,
    ).firstMatch(body);
    if (noCurrencyMatch != null) {
      final valStr = noCurrencyMatch.group(1)?.replaceAll(',', '');
      final val = double.tryParse(valStr ?? '');
      if (val != null && val > 0 && val < 100000000) return val;
    }

    // Strategy 5: Suffix currency format fallback: "1,250.00 Rs" or "500 INR"
    final suffixMatch = RegExp(
      r'([\d,]+\.?\d*)\s*(?:rs\.?:?|inr|rupees)',
      caseSensitive: false,
    ).firstMatch(body);
    if (suffixMatch != null) {
      final valStr = suffixMatch.group(1)?.replaceAll(',', '');
      final val = double.tryParse(valStr ?? '');
      if (val != null && val > 0 && val < 100000000) return val;
    }

    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SECURITY FOOTER STRIPPING
  // Strips helpline, fraud warning, and block instructions so they don't leak
  // into merchant names or reference numbers
  // ─────────────────────────────────────────────────────────────────────────
  static String _stripSecurityFooter(String body) {
    final footerRegex = RegExp(
      r'(?:\r?\n\s*)?(?:Not\s+You\??|If\s+not\s+(?:you|done|your)|In\s+case\s+of\s+dispute|To\s+block|SMS\s+BLOCK|Call\s+(?:1800|1860|\d{10})|Dispute\??|Never\s+share|Do\s+not\s+share|Queries\??|Helpline).*$',
      caseSensitive: false,
      dotAll: true,
    );
    return body.replaceFirst(footerRegex, '').trim();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MERCHANT / PAYEE EXTRACTION
  // Tries multiple strategies to identify the recipient or merchant
  // ─────────────────────────────────────────────────────────────────────────
  static String _extractMerchant(String rawBody, String sender) {
    final body = _stripSecurityFooter(rawBody);
    final lower = body.toLowerCase();

    // 0. ATM / Cash withdrawal check
    final isAtm =
        lower.contains('atm') ||
        lower.contains('cash withdrawal') ||
        lower.contains('withdrawn cash') ||
        lower.contains('atm wdl') ||
        lower.contains('cash wdl');
    if (isAtm) {
      return 'ATM Cash';
    }

    // 0b. Fee / Service charge check
    if (lower.contains('service fee') ||
        lower.contains('service charge') ||
        lower.contains('consolidated charges') ||
        lower.contains('alert fee')) {
      return 'Bank Charges';
    }

    // 0c. Dual debit / credit ICICI pattern: "debited ... ; <PAYEE> credited"
    final creditedMatch = RegExp(
      r';\s*([-A-Za-z0-9\s&.@]{1,40}?)\s+credited\b',
      caseSensitive: false,
    ).firstMatch(body);
    if (creditedMatch != null) {
      final m = creditedMatch.group(1)!.trim();
      if (_isValidMerchant(m)) return _cleanMerchantName(m);
    }

    // 0d. Dr / Cr pattern: "Dr. from A/C ... and Cr. to <PAYEE>"
    final crToMatch = RegExp(
      r'\b(?:and\s+)?cr\.?\s+to\s+([-A-Za-z0-9\s&.@]{1,40}?)(?:\s+on\b|\s+ref\b|\s+avl\b|\.|\,|\n|$)',
      caseSensitive: false,
    ).firstMatch(body);
    if (crToMatch != null) {
      final m = crToMatch.group(1)!.trim();
      if (_isValidMerchant(m)) return _cleanMerchantName(m);
    }

    // 0e. Hindi format: "<PAYEE> को UPI द्वारा ... काटे गए"
    final hindiKoMatch = RegExp(
      r'[\d,.]+\s+([-A-Za-z0-9\s&.@]{1,40}?)\s+को\s+(?:upi|द्वारा)',
      caseSensitive: false,
    ).firstMatch(body);
    if (hindiKoMatch != null) {
      final m = hindiKoMatch.group(1)!.trim();
      if (_isValidMerchant(m)) return _cleanMerchantName(m);
    }

    // 1. Bank structured Info field patterns
    final iciciInfoMatch = RegExp(
      r'info[:\*\-\s]+(?:upi|bil|imps)\*([^\n\.]*)',
      caseSensitive: false,
    ).firstMatch(body);
    if (iciciInfoMatch != null) {
      final parts = iciciInfoMatch.group(1)!.split('*');
      for (final part in parts) {
        final candidate = part.trim();
        if (candidate.isNotEmpty &&
            !candidate.contains('@') &&
            !RegExp(r'^\d+$').hasMatch(candidate) &&
            _isValidMerchant(candidate)) {
          return _cleanMerchantName(candidate);
        }
      }
    }

    final infoSlashMatch = RegExp(
      r'(?:info[:\*\-\s]+|through\s+|towards\s+)(?:imps|neft|upi|rtgs|p2p|p2m|bil|dr)/([^\n\.]*)',
      caseSensitive: false,
    ).firstMatch(body);
    if (infoSlashMatch != null) {
      final parts = infoSlashMatch.group(1)!.split('/');
      for (final part in parts) {
        final candidate = part.trim().replaceAll(RegExp(r'[.,\)\(]+$'), '');
        if (candidate.isNotEmpty &&
            candidate.length > 2 &&
            !RegExp(r'^\d+$').hasMatch(candidate) &&
            !RegExp(r'^[A-Z0-9]{10,}$').hasMatch(candidate) &&
            _isValidMerchant(candidate)) {
          return _cleanMerchantName(candidate);
        }
      }
    }

    final infoHyphenMatch = RegExp(
      r'info[:\*\-\s]+(?:upi|imps)[-]([A-Za-z0-9][A-Za-z0-9\s\-&.@]{2,30}?)(?:[-]\d+|\.|\,|\n|$)',
      caseSensitive: false,
    ).firstMatch(body);
    if (infoHyphenMatch != null) {
      final m = infoHyphenMatch.group(1)!.trim();
      if (_isValidMerchant(m)) return _cleanMerchantName(m);
    }

    // 2. Explicit merchant labels: "Merchant: Zomato", "Payee: Ramesh", "Store: Starbucks"
    final explicitMerchantMatch = RegExp(
      r'\b(?:merchant(?:\s*name)?|payee(?:\s*name)?|beneficiary(?:\s*name)?|receiver)\s*[:\-]\s*([A-Za-z0-9][A-Za-z0-9\s&.@-]{1,40}?)(?:\s+on\b|\s+via\b|\s+ref\b|\s+rrn\b|\s+avl\b|\s+bal\b|\.|\,|\n|$)',
      caseSensitive: false,
    ).firstMatch(body);
    if (explicitMerchantMatch != null) {
      final m = explicitMerchantMatch.group(1)!.trim();
      if (_isValidMerchant(m)) return _cleanMerchantName(m);
    }

    // 3. "towards MERCHANT"
    final towardsMatch = RegExp(
      r'\btowards\s+([-A-Za-z0-9\s&.@]{1,40}?)(?:\s+on\b|\s+via\b|\s+using\b|\s+ref\b|\s+rrn\b|\s+avl\b|\s+bal\b|\s+a\/c\b|\.|\,|\n|$)',
      caseSensitive: false,
    ).firstMatch(body);
    if (towardsMatch != null) {
      final m = towardsMatch.group(1)!.trim();
      if (_isValidMerchant(m)) {
        return _cleanMerchantName(m);
      }
    }

    // 4. "in favour of / favouring MERCHANT"
    final favourMatch = RegExp(
      r'\b(?:in\s+favo(?:u)?r\s+of|favo(?:u)?ring)\s+([-A-Za-z0-9\s&.@]{1,40}?)(?:\s+on\b|\s+via\b|\s+using\b|\s+ref\b|\s+rrn\b|\s+avl\b|\s+bal\b|\s+a\/c\b|\.|\,|\n|$)',
      caseSensitive: false,
    ).firstMatch(body);
    if (favourMatch != null) {
      final m = favourMatch.group(1)!.trim();
      if (_isValidMerchant(m)) return _cleanMerchantName(m);
    }

    // 5. "transfer to / by transfer to MERCHANT"
    final transferMatch = RegExp(
      r'\b(?:by\s+transfer\s+to|transfer\s+to|transferr?ed\s+to)\s+([-A-Za-z0-9\s&.@]{1,40}?)(?:\s*\((?:upi\s*)?ref|\s+on\b|\s+via\b|\s+using\b|\s+ref\b|\s+rrn\b|\s+avl\b|\s+bal\b|\s+a\/c\b|\.|\,|\n|$)',
      caseSensitive: false,
    ).firstMatch(body);
    if (transferMatch != null) {
      final m = transferMatch.group(1)!.trim();
      if (_isValidMerchant(m)) return _cleanMerchantName(m);
    }

    // 6. "for order at MERCHANT" or "order at MERCHANT"
    final orderAtMatch = RegExp(
      r'\b(?:for\s+order\s+at|order\s+at|order\s+on)\s+([-A-Za-z0-9\s&.@]{1,40}?)(?:\s+on\b|\s+via\b|\s+using\b|\s+ref\b|\s+rrn\b|\s+avl\b|\s+bal\b|\.|\,|\n|$)',
      caseSensitive: false,
    ).firstMatch(body);
    if (orderAtMatch != null) {
      final m = orderAtMatch.group(1)!.trim();
      if (_isValidMerchant(m)) return _cleanMerchantName(m);
    }

    // 7. "at MERCHANT"
    final atMatch = RegExp(
      r'\bat\s+([-A-Za-z0-9\s&.@]{1,40}?)(?:\s+on\b|\s+via\b|\s+using\b|\s+from\b|\s+ref\b|\s+rrn\b|\s+avl\b|\s+bal\b|\s+a\/c\b|\.(?:\s+|$)|,|\n|$)',
      caseSensitive: false,
    ).firstMatch(body);
    if (atMatch != null) {
      final m = atMatch.group(1)!.trim();
      if (_isValidMerchant(m)) return _cleanMerchantName(m);
    }

    // 8. "to MERCHANT" or "sent to" or "paid to"
    final toMatches = RegExp(
      r'\b(?:sent\s+to|paid\s+to|payment\s+to|to)\s+([-A-Za-z0-9\s&.@]{1,40}?)(?:\s+on\b|\s+via\b|\s+using\b|\s+from\b|\s+ref\b|\s+rrn\b|\s+avl\b|\s+bal\b|\s+a\/c\b|\.(?:\s+|$)|,|\n|$)',
      caseSensitive: false,
    ).allMatches(body);

    for (final match in toMatches) {
      final m = match.group(1)!.trim();
      if (_isValidMerchant(m)) {
        return _cleanMerchantName(m);
      }
    }

    // 9. Explicit VPA address: "vpa abc@okhdfc", "user@upi"
    final vpaMatch = RegExp(
      r'(?:^|[\s:])([-A-Za-z0-9._]{1,40}@[-A-Za-z0-9._]{2,})',
      caseSensitive: false,
    ).firstMatch(body);
    if (vpaMatch != null) {
      final m = vpaMatch.group(1)!.trim();
      if (!m.contains('support@') &&
          !m.contains('help@') &&
          !m.contains('care@') &&
          !m.contains('nodal@')) {
        return _cleanMerchantName(m);
      }
    }

    // 10. "charged for MERCHANT" or "payment for MERCHANT"
    final forMatch = RegExp(
      r'\b(?:charged\s+for|debited\s+for|used\s+for|spent\s+on)\s+([-A-Za-z0-9\s&.@]{1,30}?)(?:\s+on\b|\s+via\b|\s+using\b|\s+ref\b|\s+rrn\b|\s+avl\b|\s+bal\b|\.|\,|\n|$)',
      caseSensitive: false,
    ).firstMatch(body);
    if (forMatch != null) {
      final m = forMatch.group(1)!.trim();
      if (_isValidMerchant(m)) return _cleanMerchantName(m);
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

  // Validates if candidate string is a real merchant/payee and not an account, number, or stop phrase
  static bool _isValidMerchant(String m) {
    if (m.isEmpty) return false;
    final lower = m.toLowerCase().trim();

    // VPAs are valid merchant handles
    if (m.contains('@')) return true;

    // Pure numbers or phone numbers are not merchants
    if (RegExp(r'^\+?\d+$').hasMatch(lower)) return false;
    if (RegExp(r'^(?:1800|1860|\+91)?\d{6,12}$').hasMatch(lower)) return false;

    // Customer service / Fraud warning phrases
    if (lower.contains('block upi') ||
        lower.contains('call 1800') ||
        lower.contains('call 1860') ||
        lower.contains('not you') ||
        lower.contains('customer care') ||
        lower.contains('helpline')) {
      return false;
    }

    // Bank account phrases
    if (RegExp(r'\b(?:a\/c|acct|account|saving|savings|current|branch)\b').hasMatch(lower)) {
      return false;
    }
    if (lower.startsWith('xx') || RegExp(r'^\*+\d').hasMatch(lower)) {
      return false;
    }
    if (RegExp(
      r'\b(?:bank|hdfc|icici|axis|sbi|kotak|pnb|bob|canara|indusind)\s+(?:a\/c|acct|account|branch)\b',
    ).hasMatch(lower)) {
      return false;
    }

    // Generic words
    if (lower == 'upi' ||
        lower == 'imps' ||
        lower == 'neft' ||
        lower == 'rtgs' ||
        lower == 'card' ||
        lower == 'debit card' ||
        lower == 'credit card' ||
        lower == 'bank' ||
        lower == 'your account' ||
        lower == 'your a/c') {
      return false;
    }

    return true;
  }

  // Clean up a matched merchant string with proper Title Case
  static String _cleanMerchantName(String raw) {
    String cleaned = raw.trim().replaceAll(RegExp(r'[.,\-\s]+$'), '').trim();
    if (cleaned.toLowerCase().startsWith('vpa:')) {
      cleaned = cleaned.substring(4).trim();
    } else if (cleaned.toLowerCase().startsWith('vpa ')) {
      cleaned = cleaned.substring(4).trim();
    }

    // Only title-case words if it's not a VPA/email (contains '@')
    if (!cleaned.contains('@') && cleaned.length > 2) {
      if (cleaned == cleaned.toUpperCase()) {
        cleaned = cleaned.split(' ').map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        }).join(' ');
      }
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

    final bool isAtm =
        lowerBody.contains('atm') ||
        lowerBody.contains('cash withdrawal') ||
        lowerBody.contains('withdrawn cash') ||
        lowerBody.contains('atm wdl') ||
        lowerBody.contains('cash wdl');

    final bool isCard =
        lowerBody.contains('credit card') ||
        lowerBody.contains('debit card') ||
        lowerBody.contains('onecard') ||
        lowerBody.contains('pos purchase') ||
        lowerBody.contains('pos txn') ||
        RegExp(
          r'(?:\b(?:card\s+(?:xx|ending|no\.?|spent)|card\s*purchase|pos\s*txn|spent\s+on\s+card|card\s+\d+|credit\s+card|debit\s+card)\b|onecard)',
          caseSensitive: false,
        ).hasMatch(lowerBody);

    final bool isBankTransfer =
        lowerBody.contains('neft') ||
        lowerBody.contains('rtgs') ||
        lowerBody.contains('imps') ||
        lowerBody.contains('inb') ||
        lowerBody.contains('netbanking') ||
        lowerBody.contains('internet banking') ||
        lowerBody.contains('fund transfer') ||
        lowerBody.contains('by transfer') ||
        lowerBody.contains('mob bk') ||
        lowerBody.contains('standing instruction') ||
        lowerBody.contains('emi') ||
        lowerBody.contains('nach') ||
        lowerBody.contains('ecs');

    final bool isUpi =
        lowerBody.contains('upi') ||
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
        lowerBody.contains('block upi') ||
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
      r'(?:avl\s*bal|available\s*balance|total\s*bal|tot\s*bal|net\s*bal|bal|balance|avl\s*limit|available\s*limit|bal\s*limit|शेष)\s*(?:is|:|\-)?\s*(?:rs\.?:?|inr|₹|rupees|\$|usd)?\s*([\d,]+\.?\d*)',
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
      r'\b(?:rrn|upi\s*ref(?:\s*no\.?)?|ref(?:\s*no\.?)?|refno\.?|txn\s*(?:id|no\.?)?|trans\s*id|utr(?:\s*no\.?)?|mob\s*bk\s*ref\s*no|upi\s*(?:transaction|txn)\s*id|imps\s*ref(?:\s*no\.?)?)\s*[:\-\s]?\s*([A-Za-z0-9]+)',
      caseSensitive: false,
    ).firstMatch(body);
    if (refMatch != null) {
      return refMatch.group(1);
    }
    // Also match "IMPS: <digits>"
    final impsMatch = RegExp(r'\bimps\s*[:\-]\s*(\d+)', caseSensitive: false).firstMatch(body);
    if (impsMatch != null) {
      return impsMatch.group(1);
    }
    // Fallback: check UPI path e.g. "UPI/P2M/123456789012/..."
    final upiPathMatch = RegExp(
      r'upi\/(?:p2[am]|dr)\/(\d{6,14})',
      caseSensitive: false,
    ).firstMatch(body);
    if (upiPathMatch != null) {
      return upiPathMatch.group(1);
    }
    return null;
  }

  static String? _extractAccount(String body) {
    final accMatch = RegExp(
      r'(?:\b(?:a\/?c(?:count)?|acct|ac|card)\b|onecard)\.?\s*(?:no\.?|ending(?:\s+(?:with|in))?)?\s*[:\-]?\s*[*xX\.\s]*(\d{3,6})\b',
      caseSensitive: false,
    ).firstMatch(body);
    if (accMatch != null) {
      return accMatch.group(1);
    }
    // Fallback: standalone masked account like "A/C *1234", "A/C ...7059", "A/c1234"
    final fallbackMatch = RegExp(
      r'\ba\/?c[:\-]?\s*[*xX\.]*(\d{3,6})\b',
      caseSensitive: false,
    ).firstMatch(body);
    if (fallbackMatch != null) {
      return fallbackMatch.group(1);
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MERCHANT CATEGORISATION
  // Comprehensive mapping of hundreds of merchants, chains, and service keywords
  // ─────────────────────────────────────────────────────────────────────────
  static String categorizeMerchant(String merchant) {
    final String ml = merchant.toLowerCase();

    const foodKeywords = [
      'starbucks', 'zomato', 'swiggy', 'mcdonalds', 'kfc', 'burger king',
      'subway', 'pizza hut', 'dominos', 'pizza', 'burger', 'dineout',
      'eatsure', 'blinkit', 'bigbasket', 'grofers', 'dunzo', 'zepto',
      'instamart', 'chaayos', 'chai', 'coffee', 'bakery', 'hotel', 'dhaba',
      'restaurant', 'cafe', 'food', 'biryani', 'kitchen', 'sweets', 'bakes',
      'juice', 'tea', 'haldiram', 'barbeque nation', 'behrouz', 'faasos',
      'ccd', 'cafe coffee day', 'bar', 'pub', 'dining',
    ];
    const transportKeywords = [
      'uber', 'ola', 'irctc', 'petrol', 'fuel', 'hpcl', 'iocl', 'ioc',
      'bpcl', 'shell', 'metro', 'rapido', 'bus', 'train', 'flight',
      'airport', 'indigo', 'spicejet', 'airindia', 'air india', 'akasa',
      'vistara', 'makemytrip', 'goibibo', 'yatra', 'easemytrip', 'redbus',
      'abhibus', 'cleartrip', 'toll', 'fastag', 'parking', 'auto', 'cab',
      'taxi', 'rail', 'transport',
    ];
    const shoppingKeywords = [
      'amazon', 'flipkart', 'myntra', 'nykaa', 'supermarket', 'dmart',
      'd-mart', 'reliance', 'meesho', 'ajio', 'tata', 'tata cliq', 'croma',
      'vijay sales', 'snapdeal', 'shopsy', 'jiomart', 'retail', 'store',
      'mall', 'mart', 'clothes', 'fashion', 'zara', 'h&m', 'uniqlo',
      'max', 'westside', 'pantaloons', 'lifestyle', 'decathlon',
      'shoppers stop', 'lenskart', 'tanishq', 'titan', 'caratlane',
      'electronics',
    ];
    const utilitiesKeywords = [
      'airtel', 'jio', 'vi ', 'bsnl', 'bescom', 'electricity', 'water',
      'broadband', 'recharge', 'gas', 'lpg', 'postpaid', 'tata power',
      'adani electricity', 'msedcl', 'tneb', 'wbsedcl', 'billdesk', 'bbps',
      'dth', 'tata sky', 'tata play', 'dish tv', 'sun direct', 'act fibernet',
      'hathway', 'wifi', 'utility', 'municipal', 'igl', 'mgl', 'indane',
    ];
    const entertainmentKeywords = [
      'netflix', 'spotify', 'prime', 'hotstar', 'pvr', 'inox', 'cinepolis',
      'bookmyshow', 'disney', 'zee5', 'sonyliv', 'jiocinema', 'youtube',
      'apple music', 'gaana', 'wynk', 'cinema', 'movie', 'theatre',
      'gaming', 'steam', 'playstation', 'xbox', 'subscription',
    ];
    const healthKeywords = [
      'pharmacy', 'hospital', 'apollo', 'medplus', 'clinic', 'pharma',
      'medic', 'health', 'netmeds', '1mg', 'practo', 'tata 1mg', 'cult.fit',
      'cultfit', 'docprime', 'dental', 'diagnostic', 'pathology', 'lab',
      'wellness', 'pharmeasy', 'medicos', 'care',
    ];
    const educationKeywords = [
      'byju', 'unacademy', 'coursera', 'udemy', 'skill', 'vedantu',
      'topper', 'whitehat', 'school', 'college', 'university', 'exam',
      'fee', 'fees', 'tuition', 'coaching', 'classes', 'academy',
      'upgrad', 'simplilearn', 'institute', 'learning',
    ];
    const investmentKeywords = [
      'zerodha', 'groww', 'upstox', 'angel one', 'coin', 'indmoney',
      'kuvera', 'smallcase', 'mutual fund', 'amc', 'sip', 'lic',
      'hdfc life', 'max life', 'icici pru', 'sbi life', 'star health',
      'insurance',
    ];

    if (foodKeywords.any((k) => ml.contains(k))) return 'Food';
    if (transportKeywords.any((k) => ml.contains(k))) return 'Transportation';
    if (shoppingKeywords.any((k) => ml.contains(k))) return 'Shopping';
    if (utilitiesKeywords.any((k) => ml.contains(k))) return 'Utilities';
    if (entertainmentKeywords.any((k) => ml.contains(k))) return 'Entertainment';
    if (healthKeywords.any((k) => ml.contains(k))) return 'Health';
    if (educationKeywords.any((k) => ml.contains(k))) return 'Education';
    if (investmentKeywords.any((k) => ml.contains(k))) return 'Investment';

    return 'Others';
  }
}
