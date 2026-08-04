import '../../../domain/entities/parsed_transaction.dart';
import '../../../domain/entities/sms_message.dart';
import 'base_sms_parser.dart';

class FallbackParser extends BaseSmsParser {
  @override
  String get bankName => 'Unknown Bank';

  static final RegExp _amountRegex = RegExp(r'(?:(?:Rs|INR)\.?\s*|(?<=\s|^))(?:(?:[1-9]\d{0,2}(?:,\d{3})+)|(?:\d+))(?:\.\d{1,2})?(?=\s|$)', caseSensitive: false);
  
  @override
  bool canParse(SmsMessage message) {
    // Fallback parser accepts any message, but it only tries to parse if it looks like a transaction.
    return message.body.toLowerCase().contains('debited') || 
           message.body.toLowerCase().contains('credited') ||
           message.body.toLowerCase().contains('spent');
  }

  @override
  ParsedTransaction? parse(SmsMessage message) {
    if (!canParse(message)) return null;

    final text = message.body;
    
    final isDebit = text.toLowerCase().contains('debited') || text.toLowerCase().contains('spent') || text.toLowerCase().contains('deducted');
    final isCredit = text.toLowerCase().contains('credited') || text.toLowerCase().contains('added') || text.toLowerCase().contains('deposited');
    
    if (!isDebit && !isCredit) return null;

    final amount = extractAmount(text, _amountRegex);
    if (amount == null) return null;

    return ParsedTransaction(
      amount: amount,
      merchant: 'Unknown Merchant',
      transactionType: isDebit ? 'debit' : 'credit',
      paymentMethod: 'Unknown',
      transactionDate: message.receivedAt,
      bankName: 'Unknown',
      referenceNumber: null,
    );
  }
}
