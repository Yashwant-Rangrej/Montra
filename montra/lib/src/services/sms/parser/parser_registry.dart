import '../../../domain/entities/parsed_transaction.dart';
import '../../../domain/entities/sms_message.dart';
import 'banks/hdfc_parser.dart';
import 'banks/icici_parser.dart';
import 'banks/sbi_parser.dart';
import 'base_sms_parser.dart';
import 'fallback_parser.dart';

class ParserRegistry {
  final List<BaseSmsParser> _parsers = [];
  final FallbackParser _fallbackParser = FallbackParser();

  ParserRegistry() {
    _registerDefaultParsers();
  }

  void _registerDefaultParsers() {
    _parsers.addAll([
      SbiParser(),
      HdfcParser(),
      IciciParser(),
    ]);
  }

  ParsedTransaction? parse(SmsMessage message) {
    for (final parser in _parsers) {
      if (parser.canParse(message)) {
        final result = parser.parse(message);
        if (result != null) return result;
      }
    }
    
    // Try fallback if no bank parser matched or if they returned null
    return _fallbackParser.parse(message);
  }
}
