import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' as drift;
import '../../data/database/database.dart';
import '../../domain/entities/sms_message.dart';
import '../notifications/notification_service.dart';
import '../notifications/notification_models.dart';
import '../notifications/notification_channels.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  channel.setMethodCallHandler((call) async {
    if (call.method == 'onSmsReceived') {
      try {
        final Map<dynamic, dynamic> args = call.arguments;
        final message = SmsMessage.fromMap(Map<String, dynamic>.from(args));
        
        debugPrint("Background SMS received from: ${message.sender}");
        
        final db = AppDatabase();
        
        final parsed = SmsParser.parseSms(message.sender, message.body);
        
        if (parsed != null) {
          debugPrint("SMS parsed: ${parsed.merchant} - ₹${parsed.amount}");
          
          // Banks concept removed; default to accountId 1
          final accountId = 1;

          // Find category ID based on parsed category name
          final categoryRow = await (db.select(db.categories)..where((c) => c.name.equals(parsed.category))).getSingleOrNull();
          final int? categoryId = categoryRow?.id;
          
          // Insert parsed transaction into local Drift database
          final insertedId = await db.into(db.transactions).insert(
            TransactionsCompanion.insert(
              amount: parsed.amount,
              type: parsed.type,
              merchant: drift.Value(parsed.merchant),
              categoryId: drift.Value(categoryId),
              accountId: accountId,
              transactionDate: message.receivedAt,
              originalSms: drift.Value(message.body),
            )
          );
          
          debugPrint("Transaction inserted with id: $insertedId");
          
          await notificationService.showNotification(
            id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
            title: '💳 Expense Detected',
            body: 'Spent ₹${parsed.amount.toStringAsFixed(0)} at ${parsed.merchant} (${parsed.category})',
            channel: NotificationChannels.transactions,
            payload: NotificationPayload(
              type: 'transactionDetected', 
              route: '/transactions', // Or a direct edit route if you had one
              data: {'transactionId': insertedId},
            ),
            actions: [
              const AndroidNotificationAction('ACTION_FOOD', '🍔 Food', showsUserInterface: false),
              const AndroidNotificationAction('ACTION_TRANSPORT', '🚗 Transport', showsUserInterface: false),
            ],
          );
          await db.close();
          await channel.invokeMethod('smsProcessed');
        } else {
          debugPrint("SMS could not be parsed, saving as unrecognized: ${message.body}");
           await db.into(db.unrecognizedSms).insert(
            UnrecognizedSmsCompanion.insert(
              sender: message.sender,
              body: message.body,
              receivedAt: message.receivedAt,
              reason: const drift.Value('Could not extract transaction details from SMS.'),
            )
          );
          await db.close();
        }
      } catch (e, stackTrace) {
        debugPrint("Background SMS processing error: $e");
        debugPrint("Stack trace: $stackTrace");
      }
    }
  });

  // Signal Kotlin that Dart handler is registered and ready to receive SMS.
  // Must be awaited to ensure proper sequencing with the Kotlin side.
  await channel.invokeMethod('backgroundChannelReady');
  debugPrint("Background SMS handler initialized and ready.");
}
