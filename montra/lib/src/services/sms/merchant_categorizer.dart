class MerchantCategorizer {
  // A simple heuristic rule set for auto-categorization based on keywords
  // Real implementation would use database category IDs, so we return a likely category name.

  static String? categorize(String merchantStr) {
    final lower = merchantStr.toLowerCase();

    if (_containsAny(lower, ['zomato', 'swiggy', 'mcdonalds', 'kfc', 'starbucks', 'dominos', 'pizza', 'burger'])) {
      return 'Food & Dining';
    }
    if (_containsAny(lower, ['uber', 'ola', 'rapido', 'irctc', 'makemytrip', 'metro', 'redbus'])) {
      return 'Transportation';
    }
    if (_containsAny(lower, ['amazon', 'flipkart', 'myntra', 'ajio', 'nykaa', 'blinkit', 'instamart', 'zepto', 'dmart', 'bigbasket'])) {
      return 'Shopping';
    }
    if (_containsAny(lower, ['netflix', 'prime', 'spotify', 'hotstar', 'bookmyshow', 'pvr'])) {
      return 'Entertainment';
    }
    if (_containsAny(lower, ['jio', 'airtel', 'vi', 'bsnl', 'bescom', 'tatasky', 'bill'])) {
      return 'Bills & Utilities';
    }
    if (_containsAny(lower, ['apollo', 'pharmeasy', '1mg', 'hospital', 'clinic'])) {
      return 'Health';
    }
    if (_containsAny(lower, ['fuel', 'petrol', 'hpcl', 'bpcl', 'ioc', 'shell'])) {
      return 'Fuel';
    }
    if (_containsAny(lower, ['salary', 'payroll', 'wages'])) {
      return 'Salary';
    }

    return null; // Let the fallback handle it or leave uncategorized
  }

  static bool _containsAny(String text, List<String> keywords) {
    for (final keyword in keywords) {
      if (text.contains(keyword)) {
        return true;
      }
    }
    return false;
  }
}
