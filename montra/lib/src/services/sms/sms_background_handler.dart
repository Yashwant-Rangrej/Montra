import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' as drift;
import '../../data/database/database.dart';
import '../../domain/entities/sms_message.dart';
import '../notifications/notification_service.dart';
import '../notifications/notification_models.dart';
import '../notifications/notification_channels.dart';
import '../../core/network/api_client.dart';

@pragma('vm:entry-point')
void smsBackgroundHandler() async {
  const MethodChannel channel = MethodChannel('com.montra.app/sms_background');
  
  final notificationService = NotificationService();
  await notificationService.init((NotificationPayload payload) {});

  channel.setMethodCallHandler((call) async {
    if (call.method == 'onSmsReceived') {
      try {
        final Map<dynamic, dynamic> args = call.arguments;
        final message = SmsMessage.fromMap(Map<String, dynamic>.from(args));
        
        final apiClient = ApiClient();
        final db = AppDatabase();
        
        // POST raw SMS to the stateless FastAPI backend
        final response = await apiClient.client.post('/process-sms/', data: {
          'sender': message.sender,
          'body': message.body,
        });
        
        if (response.data != null && response.data['success'] == true) {
          final data = response.data;
          
          // Ensure we have an account to tie it to
          final account = await db.select(db.accounts).getSingleOrNull();
          final accountId = account?.id ?? 1;
          
          // Insert parsed transaction into local Drift database
          await db.into(db.transactions).insert(
            TransactionsCompanion.insert(
              amount: data['amount'] != null ? (data['amount'] as num).toDouble() : 0.0,
              type: data['type'] ?? 'expense',
              merchant: drift.Value(data['merchant'] ?? message.sender),
              accountId: accountId,
              transactionDate: message.receivedAt,
              originalSms: drift.Value(message.body),
            )
          );
          
          await notificationService.showNotification(
            id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
            title: 'New Transaction Logged',
            body: '${data['type'] == 'expense' ? 'Spent' : 'Received'} Rs ${data['amount']} at ${data['merchant']}',
            channel: NotificationChannels.transactions,
            payload: NotificationPayload(type: 'transactionDetected', route: '/transactions'),
          );
        } else {
           await db.into(db.unrecognizedSms).insert(
            UnrecognizedSmsCompanion.insert(
              sender: message.sender,
              body: message.body,
              receivedAt: message.receivedAt,
              reason: drift.Value(response.data?['message'] ?? 'Failed to parse API'),
            )
          );
        }
      } catch (e) {
        debugPrint("Background SMS processing error: $e");
      }
    }
  });

  channel.invokeMethod('backgroundChannelReady');
}
