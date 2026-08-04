class CategorizationEngine {
  static const Map<String, List<String>> _categoryKeywords = {
    'Food': ['swiggy', 'zomato', 'mcdonalds', 'kfc', 'dominos', 'pizzahut', 'starbucks', 'restaurant', 'cafe', 'baker', 'eats'],
    'Transport': ['uber', 'ola', 'rapido', 'irctc', 'redbus', 'metro', 'makemytrip', 'flight', 'ticket', 'indigo'],
    'Shopping': ['amazon', 'flipkart', 'myntra', 'ajio', 'meesho', 'nykaa', 'blinkit', 'zepto', 'instamart', 'bigbasket', 'grofers', 'reliance', 'd-mart'],
    'Fuel': ['petrol', 'diesel', 'bharat petroleum', 'indian oil', 'hpcl', 'shell'],
    'Bills': ['electricity', 'water', 'gas', 'bescom', 'bses', 'mahavitaran', 'recharge', 'jio', 'airtel', 'vi', 'broadband', 'act', 'hathway'],
    'Entertainment': ['bookmyshow', 'netflix', 'amazon prime', 'hotstar', 'spotify', 'pvr', 'inox'],
    'Health': ['pharmacy', 'apollo', 'practo', '1mg', 'hospital', 'clinic', 'medical'],
  };

  /// Returns the category name based on merchant name keywords.
  /// Returns 'Others' if no match is found.
  static String getCategory(String merchant) {
    final lowerMerchant = merchant.toLowerCase();
    
    for (final entry in _categoryKeywords.entries) {
      for (final keyword in entry.value) {
        if (lowerMerchant.contains(keyword)) {
          return entry.key;
        }
      }
    }
    
    return 'Others'; // Default category
  }
}
