import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_channels.dart';
import 'notification_models.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init(Function(NotificationPayload) onNotificationTap) async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          try {
            final payload = NotificationPayload.fromJson(jsonDecode(response.payload!));
            onNotificationTap(payload);
          } catch (e) {
            // Handle parsing error
          }
        }
      },
    );

    // Create Android channels
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      try {
        await androidPlugin.requestNotificationsPermission();
      } catch (_) {}
      for (var channel in NotificationChannels.allChannels) {
        await androidPlugin.createNotificationChannel(channel);
      }
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required AndroidNotificationChannel channel,
    required NotificationPayload payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
      priority: Priority.high,
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    final details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: jsonEncode(payload.toJson()),
    );
  }
}
