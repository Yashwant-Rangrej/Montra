import '../../../../domain/entities/parsed_transaction.dart';
import '../../../../domain/entities/sms_message.dart';
import '../base_sms_parser.dart';

class IciciParser extends BaseSmsParser {
  @override
  String get bankName => 'ICICI';

  static final RegExp _amountRegex = RegExp(r'(?:INR|Rs\.?)\s*([\d,]+\.?\d*)', caseSensitive: false);
  static final RegExp _merchantRegex = RegExp(r'(?:Info\:?\s*|to\s*|at\s*)([a-zA-Z0-9\s\.\*]+)(?:\s*on|\.|\s*$)', caseSensitive: false);
  static final RegExp _refRegex = RegExp(r'(?:Ref\s*No\.?|UPI\s*Ref\.?)\s*[:\-]?\s*(\d+)', caseSensitive: false);
  static final RegExp _balanceRegex = RegExp(r'(?:Bal|Balance|Avl Bal|Avail Bal)[^0-9]*(?:Rs\.?|INR)?\s*([\d,]+\.?\d*)', caseSensitive: false);

  @override
  bool canParse(SmsMessage message) {
    return message.sender.toUpperCase().contains('ICICI');
  }

  @override
  ParsedTransaction? parse(SmsMessage message) {
    final text = message.body;
    
    final isDebit = text.toLowerCase().contains('debited') || text.toLowerCase().contains('deducted');
    final isCredit = text.toLowerCase().contains('credited') || text.toLowerCase().contains('added');
    
    if (!isDebit && !isCredit) return null;

    final amount = extractAmount(text, _amountRegex);
    if (amount == null) return null;

    String merchant = 'Unknown';
    final merchantMatch = _merchantRegex.firstMatch(text);
    if (merchantMatch != null && merchantMatch.groupCount >= 1) {
      merchant = merchantMatch.group(1)!.trim();
    }

    String? refNo;
    final refMatch = _refRegex.firstMatch(text);
    if (refMatch != null && refMatch.groupCount >= 1) {
      refNo = refMatch.group(1)!.trim();
    }

    final paymentMethod = text.toLowerCase().contains('upi') ? 'UPI' :
                          text.toLowerCase().contains('card') ? 'Card' : 'Net Banking';

    final availableBalance = extractAmount(text, _balanceRegex);

    return ParsedTransaction(
      amount: amount,
      merchant: merchant,
      transactionType: isDebit ? 'debit' : 'credit',
      paymentMethod: paymentMethod,
      transactionDate: message.receivedAt,
      bankName: bankName,
      referenceNumber: refNo,
      availableBalance: availableBalance,
    );
  }
}
