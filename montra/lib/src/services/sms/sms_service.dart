import 'package:flutter/foundation.dart';
import 'package:telephony/telephony.dart';
import 'package:montra/src/data/database/database.dart';
import 'package:montra/src/services/notifications/notification_manager.dart';
import 'sms_processor.dart';

@pragma('vm:entry-point')
onBackgroundMessage(SmsMessage message) async {
  debugPrint("onBackgroundMessage called");
  // Initialize Database in the background isolate
  final db = AppDatabase();
  final notificationManager = NotificationManager();
  await notificationManager.initialize();

  final processor = SmsProcessor(db, notificationManager);
  
  if (message.body != null && message.address != null) {
    await processor.processSms(
      message.address!, 
      message.body!, 
      DateTime.fromMillisecondsSinceEpoch(message.date ?? DateTime.now().millisecondsSinceEpoch)
    );
  }
}

class SmsService {
  final Telephony telephony = Telephony.instance;
  final SmsProcessor _processor;

  SmsService(this._processor);

  Future<bool> requestPermissions() async {
    final bool? result = await telephony.requestPhoneAndSmsPermissions;
    return result ?? false;
  }

  void startListening() {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) async {
        debugPrint("onForegroundMessage called");
        if (message.body != null && message.address != null) {
          await _processor.processSms(
            message.address!, 
            message.body!, 
            DateTime.fromMillisecondsSinceEpoch(message.date ?? DateTime.now().millisecondsSinceEpoch)
          );
        }
      },
      onBackgroundMessage: onBackgroundMessage,
    );
  }
}
