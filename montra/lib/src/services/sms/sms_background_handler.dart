import 'dart:ui';
import 'package:flutter/services.dart';
import '../../data/database/database.dart';
import '../../domain/entities/sms_message.dart';
import 'sms_pipeline.dart';

@pragma('vm:entry-point')
void smsBackgroundHandler() async {
  // Ensure Flutter engine is initialized on the background isolate
  // WidgetsFlutterBinding.ensureInitialized() is handled implicitly in Android plugins often,
  // but good to have if we need channel communication.
  
  const MethodChannel channel = MethodChannel('com.montra.app/sms_background');
  
  channel.setMethodCallHandler((call) async {
    if (call.method == 'onSmsReceived') {
      try {
        final Map<dynamic, dynamic> args = call.arguments;
        final message = SmsMessage.fromMap(Map<String, dynamic>.from(args));
        
        final db = AppDatabase();
        final pipeline = SmsPipeline(db);
        
        await pipeline.processSms(message);
      } catch (e) {
        print("Background SMS processing error: $e");
      }
    }
  });

  // Signal the native side that we are ready to receive the queued SMS
  channel.invokeMethod('backgroundChannelReady');
}
