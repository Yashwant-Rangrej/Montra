import 'package:drift/drift.dart' as drift;
import '../../data/database/database.dart';
import '../../data/database/tables.dart';
import '../../domain/entities/parsed_transaction.dart';
import '../../domain/entities/sms_message.dart';
import '../categorization/categorization_engine.dart';
import '../notifications/notification_channels.dart';
import '../notifications/notification_models.dart';
import '../notifications/notification_service.dart';
import 'duplicate_detector.dart';
import 'parser/parser_registry.dart';

class SmsPipeline {
  final AppDatabase _db;
  final ParserRegistry _parserRegistry;
  final DuplicateDetector _duplicateDetector;
  final NotificationService _notificationService;

  SmsPipeline(this._db)
      : _parserRegistry = ParserRegistry(),
        _duplicateDetector = DuplicateDetector(_db),
        _notificationService = NotificationService();

  Future<void> processSms(SmsMessage message) async {
    try {
      final parsed = _parserRegistry.parse(message);
      
      if (parsed == null) {
        await _saveUnrecognized(message, "Failed to parse");
        return;
      }

      final isDuplicate = await _duplicateDetector.isDuplicate(parsed);
      if (isDuplicate) {
        print('Duplicate transaction detected, skipping.');
        return;
      }

      final categoryName = CategorizationEngine.getCategory(parsed.merchant);
      
      // Find category ID or create if not exists (simplified logic for now)
      // Usually you'd fetch all categories and map by name
      final category = await (_db.select(_db.categories)..where((c) => c.name.equals(categoryName))..limit(1)).getSingleOrNull();
      int? categoryId = category?.id;

      // Same for account (we assume a default account for background parsing or map based on bank)
      var account = await (_db.select(_db.accounts)..limit(1)).getSingleOrNull();
      if (account == null) {
        // Can't save without an account, create a generic "Main Account"
        await _db.into(_db.accounts).insert(
          AccountsCompanion(
            name: const drift.Value('Main Account'),
            type: const drift.Value('Bank'),
            initialBalance: const drift.Value(0.0),
            createdAt: drift.Value(DateTime.now()),
          ),
        );
        account = await (_db.select(_db.accounts)..limit(1)).getSingleOrNull();
      }

      if (account == null) {
        await _saveUnrecognized(message, "Failed to create or find an account");
        return;
      }

      final transactionCompanion = TransactionsCompanion(
        amount: drift.Value(parsed.amount),
        type: drift.Value(parsed.transactionType),
        merchant: drift.Value(parsed.merchant),
        categoryId: drift.Value(categoryId),
        paymentMethod: drift.Value(parsed.paymentMethod),
        accountId: drift.Value(account.id),
        transactionDate: drift.Value(parsed.transactionDate),
        originalSms: drift.Value(message.body),
        bankTransactionId: drift.Value(parsed.referenceNumber),
      );

      final id = await _db.into(_db.transactions).insert(transactionCompanion);

      await _notificationService.showNotification(
        id: id,
        title: '${parsed.transactionType == 'credit' ? 'Received' : 'Spent'} ${parsed.amount}',
        body: 'at ${parsed.merchant}',
        channel: NotificationChannels.transactions,
        payload: NotificationPayload(
          id: id.toString(),
          type: NotificationType.transaction,
          route: '/transaction/$id',
        ),
      );

    } catch (e, st) {
      print('Error in SMS pipeline: $e\n$st');
      await _saveUnrecognized(message, e.toString());
    }
  }

  Future<void> _saveUnrecognized(SmsMessage message, String reason) async {
    await _db.into(_db.unrecognizedSms).insert(
      UnrecognizedSmsCompanion(
        sender: drift.Value(message.sender),
        body: drift.Value(message.body),
        receivedAt: drift.Value(message.receivedAt),
        reason: drift.Value(reason),
      ),
    );
  }
}
