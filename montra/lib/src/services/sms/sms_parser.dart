class ParsedTransaction {
  final double amount;
  final String merchant;
  final String type; // 'Expense', 'Income', 'Transfer'
  final DateTime date;
  final String? bankName;
  final String? referenceNumber;
  final String? paymentMethod;

  ParsedTransaction({
    required this.amount,
    required this.merchant,
    required this.type,
    required this.date,
    this.bankName,
    this.referenceNumber,
    this.paymentMethod,
  });
}

abstract class BaseSmsParser {
  /// The priority of this parser. Higher numbers are checked first.
  int get priority => 0;

  /// Returns true if this parser can handle the given SMS message.
  bool canParse(String sender, String body);

  /// Parses the SMS and returns a ParsedTransaction if successful, or null.
  ParsedTransaction? parse(String sender, String body, DateTime receivedAt);
}

class ParserRegistry {
  final List<BaseSmsParser> _parsers = [];

  void registerParser(BaseSmsParser parser) {
    _parsers.add(parser);
    _parsers.sort((a, b) => b.priority.compareTo(a.priority));
  }

  ParsedTransaction? tryParse(String sender, String body, DateTime receivedAt) {
    for (final parser in _parsers) {
      if (parser.canParse(sender, body)) {
        final result = parser.parse(sender, body, receivedAt);
        if (result != null) return result;
      }
    }
    return null;
  }
}
