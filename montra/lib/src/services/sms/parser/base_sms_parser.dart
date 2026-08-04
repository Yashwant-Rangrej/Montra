import '../../../domain/entities/parsed_transaction.dart';
import '../../../domain/entities/sms_message.dart';

abstract class BaseSmsParser {
  /// Name of the bank this parser is designed for.
  String get bankName;

  /// Determines if this parser can handle the given SMS based on sender ID and content.
  bool canParse(SmsMessage message);

  /// Extracts transaction details from the SMS. 
  /// Returns null if the SMS is not a valid transaction or parsing fails.
  ParsedTransaction? parse(SmsMessage message);

  /// Helper to extract amount using regex.
  double? extractAmount(String text, RegExp regex) {
    final match = regex.firstMatch(text);
    if (match != null && match.groupCount >= 1) {
      final amountStr = match.group(1)?.replaceAll(',', '');
      if (amountStr != null) {
        return double.tryParse(amountStr);
      }
    }
    return null;
  }
}
