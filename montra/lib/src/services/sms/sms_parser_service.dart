import 'package:telephony/telephony.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../data/repositories/transaction_repository_impl.dart';

class SmsParserService {
  final TransactionRepositoryImpl _transactionRepo;

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
    body = body.toLowerCase();

    // Ignore OTP and promotional messages
    if (body.contains('otp') || body.contains('code') || body.contains('verification')) {
      return null;
    }

    double? amount;
    String type = 'Expense';
    String merchant = 'Unknown Merchant';
    
    // Example regex for parsing amount (e.g., Rs. 500, INR 500)
    final amountRegex = RegExp(r'(?:rs\.?|inr)\s*([\d,]+\.?\d*)', caseSensitive: false);
    final match = amountRegex.firstMatch(body);
    
    if (match != null) {
      amount = double.tryParse(match.group(1)!.replaceAll(',', ''));
    }
    
    if (amount == null) return null;

    // Basic logic for Expense/Income
    if (body.contains('debited') || body.contains('spent') || body.contains('paid')) {
      type = 'Expense';
    } else if (body.contains('credited') || body.contains('received') || body.contains('refund')) {
      type = 'Income';
    } else {
      return null; // Don't auto-merge uncertain transactions per PRD
    }

    // Try to extract merchant (simplified for MVP)
    if (body.contains('to ')) {
      final merchantRegex = RegExp(r'to\s+([a-z0-9@]+)');
      final merchantMatch = merchantRegex.firstMatch(body);
      if (merchantMatch != null) {
        merchant = merchantMatch.group(1)!;
      }
    }

    return TransactionEntity(
      id: 0,
      amount: amount,
      type: type,
      merchant: merchant,
      accountId: 1, // Default to a bank account ID
      transactionDate: DateTime.now(),
      originalSms: body,
      notes: 'Auto-imported from SMS',
    );
  }
}
