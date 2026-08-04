import 'package:drift/drift.dart';
import 'package:montra/src/data/database/database.dart';
import 'package:montra/src/services/notifications/notification_manager.dart';
import 'bank_parsers.dart';
import 'duplicate_detection_service.dart';
import 'merchant_categorizer.dart';
import 'sms_parser.dart';

class SmsProcessor {
  final AppDatabase _db;
  final NotificationManager _notificationManager;
  final DuplicateDetectionService _duplicateDetector;
  final ParserRegistry _registry;

  SmsProcessor(this._db, this._notificationManager)
      : _duplicateDetector = DuplicateDetectionService(_db),
        _registry = ParserRegistry() {
    _registry.registerParser(SbiParser());
    _registry.registerParser(HdfcParser());
    _registry.registerParser(FallbackParser());
  }

  Future<void> processSms(String sender, String body, DateTime receivedAt) async {
    // 1. Try to parse
    final parsed = _registry.tryParse(sender, body, receivedAt);

    if (parsed == null) {
      // 2. Unrecognized SMS - Save to queue
      await _db.into(_db.unrecognizedSms).insert(
            UnrecognizedSmsCompanion.insert(
              sender: sender,
              body: body,
              receivedAt: receivedAt,
              reason: const Value('No parser matched'),
            ),
          );
      return;
    }

    // 3. Duplicate Detection
    final isDup = await _duplicateDetector.isDuplicate(
      amount: parsed.amount,
      merchant: parsed.merchant,
      date: parsed.date,
      bankTransactionId: parsed.referenceNumber,
    );

    if (isDup) {
      return; // Skip duplicate
    }

    // 4. Categorization
    int? categoryId;
    final categoryName = MerchantCategorizer.categorize(parsed.merchant);
    if (categoryName != null) {
      // Find category ID in DB
      final catMatch = await (_db.select(_db.categories)..where((c) => c.name.equals(categoryName))).getSingleOrNull();
      categoryId = catMatch?.id;
    }

    // 5. Default Account - Pick the first account or a default one
    final accounts = await _db.select(_db.accounts).get();
    if (accounts.isEmpty) {
      // Can't save without an account, create a generic "Cash/Bank" account
      await _db.into(_db.accounts).insert(
        AccountsCompanion.insert(
          name: 'Main Account',
          type: 'Bank',
          initialBalance: 0.0,
          createdAt: DateTime.now(),
        ),
      );
    }
    final targetAccount = await _db.select(_db.accounts).getSingleOrNull() ?? accounts.first;

    // 6. Save Transaction
    final newTxId = await _db.into(_db.transactions).insert(
          TransactionsCompanion.insert(
            amount: parsed.amount,
            type: parsed.type,
            merchant: Value(parsed.merchant),
            categoryId: Value(categoryId),
            accountId: targetAccount.id,
            transactionDate: parsed.date,
            originalSms: Value(body),
            bankTransactionId: Value(parsed.referenceNumber),
            paymentMethod: Value(parsed.paymentMethod),
          ),
        );

    // 7. Trigger Notification
    final catLabel = categoryName != null ? ' ($categoryName)' : '';
    await _notificationManager.showTransactionDetected(
      merchant: parsed.merchant,
      amount: parsed.amount,
      date: parsed.date,
      type: parsed.type.toLowerCase(),
      subtitle: 'Auto-detected via SMS$catLabel',
    );
  }
}
