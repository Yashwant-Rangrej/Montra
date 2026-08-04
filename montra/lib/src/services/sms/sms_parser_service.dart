import 'package:telephony/telephony.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

class SmsParserService {
  final TransactionRepository _transactionRepo;

  SmsParserService(this._transactionRepo);

  void handleIncomingSms(SmsMessage message) async {
    final body = message.body ?? '';
    final transaction = _parseSmsToTransaction(body);

    if (transaction != null) {
      await _transactionRepo.insertTransaction(transaction);
      // Optional: Trigger a local notification here
    }
  }

  TransactionEntity? _parseSmsToTransaction(String body) {
    final lowerBody = body.toLowerCase();

    // 1. Explicitly ignore OTP and promotional
    if (lowerBody.contains('otp') || 
        lowerBody.contains('code') || 
        lowerBody.contains('verification') ||
        lowerBody.contains('offer') ||
        lowerBody.contains('discount')) {
      return null;
    }

    // 2. Determine Type (Income or Expense)
    String? type;
    if (lowerBody.contains('debited') || 
        lowerBody.contains('spent') || 
        lowerBody.contains('paid') ||
        lowerBody.contains('deducted')) {
      type = 'Expense';
    } else if (lowerBody.contains('credited') || 
               lowerBody.contains('received') || 
               lowerBody.contains('refund') ||
               lowerBody.contains('added')) {
      type = 'Income';
    }
    
    // Per User Feedback: Even if it doesn't match specific payment methods, 
    // if we detect it as a financial transaction with an amount, we track it.
    if (type == null) {
      // If we can't even tell if it's income or expense, we must ignore it
      // as we "never auto-merge uncertain transactions".
      return null;
    }

    // 3. Detect Payment Method
    String? paymentMethod;
    if (lowerBody.contains('upi')) {
      paymentMethod = 'UPI';
    } else if (lowerBody.contains('debit card') || lowerBody.contains('atm')) {
      paymentMethod = 'Debit Card';
    } else if (lowerBody.contains('credit card')) {
      paymentMethod = 'Credit Card';
    } else if (lowerBody.contains('salary')) {
      paymentMethod = 'Salary';
    } else if (lowerBody.contains('cashback')) {
      paymentMethod = 'Cashback';
    } else if (lowerBody.contains('refund')) {
      paymentMethod = 'Refund';
    } else if (lowerBody.contains('interest')) {
      paymentMethod = 'Interest';
    } else if (lowerBody.contains('emi')) {
      paymentMethod = 'EMI';
    } else if (lowerBody.contains('charge') || lowerBody.contains('fee')) {
      paymentMethod = 'Bank Charge';
    } else if (lowerBody.contains('transfer') || lowerBody.contains('neft') || lowerBody.contains('imps') || lowerBody.contains('rtgs')) {
      paymentMethod = 'Bank Transfer';
    } else {
      paymentMethod = 'Other';
    }

    // 4. Extract Amount
    double? amount;
    // Regex matches rs. 500, inr 500, rs 500.50, INR500
    final amountRegex = RegExp(r'(?:rs\.?|inr|₹)\s*([\d,]+\.?\d*)', caseSensitive: false);
    final match = amountRegex.firstMatch(lowerBody);
    
    if (match != null) {
      amount = double.tryParse(match.group(1)!.replaceAll(',', ''));
    }
    
    if (amount == null || amount <= 0) {
      return null; // No valid amount found
    }

    // 5. Extract Merchant
    String merchant = 'Unknown';
    if (lowerBody.contains('to ')) {
      final toRegex = RegExp(r'to\s+([a-zA-Z0-9@\.\s]+?)(?:\s+on|\s+ref|\.|\n|$)');
      final toMatch = toRegex.firstMatch(lowerBody);
      if (toMatch != null) {
        merchant = toMatch.group(1)!.trim();
      }
    } else if (lowerBody.contains('from ')) {
      final fromRegex = RegExp(r'from\s+([a-zA-Z0-9@\.\s]+?)(?:\s+on|\s+ref|\.|\n|$)');
      final fromMatch = fromRegex.firstMatch(lowerBody);
      if (fromMatch != null) {
        merchant = fromMatch.group(1)!.trim();
      }
    }

    // 6. Return Entity
    return TransactionEntity(
      id: 0,
      amount: amount,
      type: type,
      merchant: merchant,
      accountId: 1, // Default to a bank account ID for SMS
      paymentMethod: paymentMethod,
      transactionDate: DateTime.now(),
      originalSms: body,
      notes: 'Auto-imported via SMS',
    );
  }
}
