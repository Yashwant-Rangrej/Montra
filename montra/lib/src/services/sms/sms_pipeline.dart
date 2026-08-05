import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import '../../data/database/database.dart';
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
        debugPrint('Duplicate transaction detected, skipping.');
        return;
      }

      final categoryName = CategorizationEngine.getCategory(parsed.merchant);
      
      // Find category ID or create if not exists (simplified logic for now)
      // Usually you'd fetch all categories and map by name
      final category = await (_db.select(_db.categories)..where((c) => c.name.equals(categoryName))..limit(1)).getSingleOrNull();
      int? categoryId = category?.id;



      final transactionCompanion = TransactionsCompanion(
        amount: drift.Value(parsed.amount),
        type: drift.Value(parsed.transactionType == 'credit' ? 'Income' : 'Expense'),
        merchant: drift.Value(parsed.merchant),
        categoryId: drift.Value(categoryId),
        paymentMethod: drift.Value(parsed.paymentMethod),
        bankName: drift.Value(parsed.bankName),
        availableBalance: drift.Value(parsed.availableBalance),
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
          type: NotificationType.transactionDetected.name,
          route: '/transaction/$id',
          data: {'id': id.toString()},
        ),
      );

    } catch (e, st) {
      debugPrint('Error in SMS pipeline: $e\n$st');
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
