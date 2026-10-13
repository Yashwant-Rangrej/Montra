import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'sms_background_handler.dart';

abstract class SmsInterceptor {
  Future<bool> requestPermissions();
  Future<void> initialize();
  void dispose();
}

class NativeSmsInterceptor implements SmsInterceptor {
  static const MethodChannel _channel = MethodChannel('com.montra.app/sms_interceptor');
  
  Future<void> Function(Map<String, dynamic> args)? onForegroundSms;

  @override
  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  @override
  Future<void> initialize() async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) return;

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onSmsReceivedForeground') {
        final args = Map<String, dynamic>.from(call.arguments as Map);
        if (onForegroundSms != null) {
          await onForegroundSms!(args);
        }
      }
    });

    // Get the raw handle of our background entry point function
    final callback = PluginUtilities.getCallbackHandle(smsBackgroundHandler);
    if (callback != null) {
      await _channel.invokeMethod('initialize', {
        'callbackHandle': callback.toRawHandle(),
      });
    }
  }

  @override
  void dispose() {
    _channel.setMethodCallHandler(null);
  }
}
