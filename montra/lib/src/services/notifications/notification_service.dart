import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_channels.dart';
import 'notification_models.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init(Function(NotificationPayload) onNotificationTap) async {
    try {
      const androidInit = AndroidInitializationSettings('app_icon');
      const initSettings = InitializationSettings(android: androidInit);

      final result = await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null) {
            try {
              final payload = NotificationPayload.fromJson(jsonDecode(response.payload!));
              onNotificationTap(payload);
            } catch (e) {
              debugPrint('NotificationService: Error parsing payload: $e');
            }
          }
        },
      );
      debugPrint('NotificationService: initialize returned: $result');

      // Create Android channels
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        try {
          final granted = await androidPlugin.requestNotificationsPermission();
          debugPrint('NotificationService: Permission granted: $granted');
        } catch (e) {
          debugPrint('NotificationService: Permission request error: $e');
        }
        for (var channel in NotificationChannels.allChannels) {
          await androidPlugin.createNotificationChannel(channel);
        }
        debugPrint('NotificationService: Channels created');
      }

      debugPrint('NotificationService: Initialized successfully');
    } catch (e, st) {
      debugPrint('NotificationService: Init FAILED: $e\n$st');
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required AndroidNotificationChannel channel,
    required NotificationPayload payload,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: Priority.high,
        icon: 'app_icon',
        largeIcon: const DrawableResourceAndroidBitmap('app_icon'),
      );

      final details = NotificationDetails(android: androidDetails);

      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: jsonEncode(payload.toJson()),
      );
      debugPrint('NotificationService: Notification shown (id=$id, title=$title)');
    } catch (e, st) {
      debugPrint('NotificationService: showNotification FAILED: $e\n$st');
    }
  }
}
