class SmsParsedResult {
  final double amount;
  final String type;
  final String merchant;
  final String category;

  SmsParsedResult({
    required this.amount,
    required this.type,
    required this.merchant,
    required this.category,
  });
}

class SmsParser {
  static SmsParsedResult? parseSms(String sender, String body) {
    // Extract amount
    RegExp amountRegex = RegExp(r'(?:rs\.?|inr|usd|\$)\s*([\d,]+\.?\d*)', caseSensitive: false);
    Match? amountMatch = amountRegex.firstMatch(body);
    
    if (amountMatch == null) {
      RegExp fallbackRegex = RegExp(r'(?:debited|credited|spent).*?(?:rs\.?|inr|usd|\$)\s*([\d,]+\.?\d*)', caseSensitive: false);
      amountMatch = fallbackRegex.firstMatch(body);
    }
    
    if (amountMatch == null) return null;
    
    String amountStr = amountMatch.group(1)!.replaceAll(',', '');
    double? amount = double.tryParse(amountStr);
    if (amount == null) return null;
    
    String transactionType = "expense";
    
    // Extract merchant
    String merchant = sender; // Default to sender
    RegExp merchantRegex = RegExp(r'(?:at|to|info[\*:-])\s+([A-Za-z0-9\s]+?)(?:on|ref|avl|val|balance|$)', caseSensitive: false);
    Match? merchantMatch = merchantRegex.firstMatch(body);
    if (merchantMatch != null && merchantMatch.group(1) != null) {
      merchant = merchantMatch.group(1)!.trim();
      if (merchant.isEmpty) {
        merchant = sender;
      }
    }
    
    // Categorize
    String category = categorizeMerchant(merchant);
    
    return SmsParsedResult(
      amount: amount,
      type: transactionType,
      merchant: merchant,
      category: category,
    );
  }
  
  static String categorizeMerchant(String merchant) {
    String merchantLower = merchant.toLowerCase();
    
    final foodKeywords = ['starbucks', 'zomato', 'swiggy', 'mcdonalds', 'kfc', 'restaurant', 'cafe', 'food'];
    final transportKeywords = ['uber', 'ola', 'irctc', 'petrol', 'fuel', 'hpcl', 'ioc', 'bpcl', 'metro'];
    final shoppingKeywords = ['amazon', 'flipkart', 'myntra', 'nykaa', 'supermarket', 'dmart', 'reliance'];
    final utilitiesKeywords = ['airtel', 'jio', 'vi', 'bescom', 'electricity', 'water', 'broadband', 'recharge'];
    final entertainmentKeywords = ['netflix', 'spotify', 'prime', 'hotstar', 'pvr', 'bookmyshow'];
    final healthKeywords = ['pharmacy', 'hospital', 'apollo', 'medplus', 'clinic'];
    
    if (foodKeywords.any((k) => merchantLower.contains(k))) return "Food";
    if (transportKeywords.any((k) => merchantLower.contains(k))) return "Transportation";
    if (shoppingKeywords.any((k) => merchantLower.contains(k))) return "Shopping";
    if (utilitiesKeywords.any((k) => merchantLower.contains(k))) return "Utilities";
    if (entertainmentKeywords.any((k) => merchantLower.contains(k))) return "Entertainment";
    if (healthKeywords.any((k) => merchantLower.contains(k))) return "Health";
    
    return "Others";
  }
}
