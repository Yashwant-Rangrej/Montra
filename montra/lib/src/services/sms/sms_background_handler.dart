import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' as drift;
import '../../data/database/database.dart';
import '../../domain/entities/sms_message.dart';
import '../notifications/notification_service.dart';
import '../notifications/notification_models.dart';
import '../notifications/notification_channels.dart';
import 'sms_parser.dart';

@pragma('vm:entry-point')
void smsBackgroundHandler() async {
  // CRITICAL: This runs in a background isolate started by the Kotlin SmsReceiver.
  // WidgetsFlutterBinding must be initialized before using MethodChannels,
  // path_provider, or any plugin that depends on the Flutter engine.
  WidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('com.montra.app/sms_background');

  final notificationService = NotificationService();
  await notificationService.init((NotificationPayload payload) {});
  debugPrint('Notification service initialized');

  channel.setMethodCallHandler((call) async {
    if (call.method == 'onSmsReceived') {
      await _processSms(call.arguments, notificationService, channel);
    }
  });

  // Signal Kotlin that Dart handler is registered and ready to receive SMS.
  await channel.invokeMethod('backgroundChannelReady');
  debugPrint('Background SMS handler initialized and ready.');
}

Future<void> _processSms(
  dynamic arguments,
  NotificationService notificationService,
  MethodChannel channel,
) async {
  try {
    final Map<dynamic, dynamic> args = arguments;
    final message = SmsMessage.fromMap(Map<String, dynamic>.from(args));

    debugPrint('Background SMS received from: ${message.sender}');

    final db = AppDatabase();

    final parsed = SmsParser.parseSms(message.sender, message.body);

    if (parsed != null) {
      debugPrint('SMS parsed: ${parsed.merchant} - ₹${parsed.amount}');

      // Prevent duplicate transactions if reference number or identical SMS already stored
      if (parsed.referenceNumber != null && parsed.referenceNumber!.isNotEmpty) {
        final existingRef = await (db.select(db.transactions)
              ..where((t) => t.bankTransactionId.equals(parsed.referenceNumber!)))
            .getSingleOrNull();
        if (existingRef != null) {
          debugPrint('Duplicate SMS skipped: reference number ${parsed.referenceNumber} already exists');
          await db.close();
          return;
        }
      }
      final existingSms = await (db.select(db.transactions)
            ..where((t) => t.originalSms.equals(message.body)))
          .getSingleOrNull();
      if (existingSms != null) {
        debugPrint('Duplicate SMS skipped: identical body already recorded');
        await db.close();
        return;
      }

      // Default to accountId 1
      const accountId = 1;

      // Find category ID based on parsed category name
      final categoryRow = await (db.select(
        db.categories,
      )..where((c) => c.name.equals(parsed.category) | c.name.like('${parsed.category}%'))).getSingleOrNull();
      final int? categoryId = categoryRow?.id;

      // Insert parsed transaction into local Drift database
      final insertedId = await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              amount: parsed.amount,
              type: parsed.type,
              merchant: drift.Value(parsed.merchant),
              categoryId: drift.Value(categoryId),
              accountId: accountId,
              paymentMethod: drift.Value(parsed.paymentMethod),
              availableBalance: drift.Value(parsed.availableBalance),
              bankTransactionId: drift.Value(parsed.referenceNumber),
              transactionDate: message.receivedAt,
              originalSms: drift.Value(message.body),
            ),
          );

      debugPrint('Transaction inserted with id: $insertedId');

      if (parsed.availableBalance != null) {
        await (db.update(db.accounts)..where((a) => a.id.equals(accountId))).write(
          AccountsCompanion(
            availableBalance: drift.Value(parsed.availableBalance),
            lastTransactionDate: drift.Value(message.receivedAt),
          ),
        );
      }

      // Close DB before the async notification call so a notification
      // failure never leaks the database handle.
      await db.close();

      debugPrint('Attempting to show SMS detection notification');
      await notificationService.showNotification(
        // Use a wide remainder to avoid notification ID collisions when
        // multiple SMS arrive within milliseconds of each other.
        id: (DateTime.now().millisecondsSinceEpoch ~/ 100).remainder(
          2147483647,
        ),
        title: '💳 Expense Detected',
        body:
            'Spent ₹${parsed.amount.toStringAsFixed(0)} at ${parsed.merchant} via ${parsed.paymentMethod} (${parsed.category})',
        channel: NotificationChannels.transactions,
        payload: NotificationPayload(
          type: 'transactionDetected',
          route: '/transactions',
          data: {'transactionId': insertedId},
        ),
      );
    } else {
      final bool isFinancial = SmsParser.isFinancialMessage(message.sender, message.body);

      if (isFinancial) {
        debugPrint(
          'Financial SMS could not be parsed, saving as unrecognized: ${message.body}',
        );
        await db
            .into(db.unrecognizedSms)
            .insert(
              UnrecognizedSmsCompanion.insert(
                sender: message.sender,
                body: message.body,
                receivedAt: message.receivedAt,
                reason: const drift.Value(
                  'Could not extract transaction details from SMS.',
                ),
              ),
            );
      } else {
        debugPrint(
          'Non-financial SMS from ${message.sender} — silently dropped.',
        );
      }
      await db.close();
    }

    // Signal Kotlin that this SMS has been fully processed.
    // Kotlin will tear down the engine after all pending SMS are done.
    try {
      await channel.invokeMethod('smsProcessingComplete');
    } catch (_) {
      // Engine may already be shutting down — safe to ignore.
    }
  } catch (e, stackTrace) {
    debugPrint('Background SMS processing error: $e');
    debugPrint('Stack trace: $stackTrace');
    // Still signal complete so the engine doesn't hang.
    try {
      await channel.invokeMethod('smsProcessingComplete');
    } catch (_) {}
  }
}
