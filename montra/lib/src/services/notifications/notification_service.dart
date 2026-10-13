import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_channels.dart';
import 'notification_models.dart';
import '../../data/database/database.dart';
import 'package:drift/drift.dart' as drift;

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  if (response.actionId != null && response.payload != null) {
    try {
      final payload = NotificationPayload.fromJson(jsonDecode(response.payload!));
      final txIdStr = payload.data?['transactionId'];
      if (txIdStr != null) {
        final txId = int.parse(txIdStr.toString());
        final action = response.actionId;
        
        String? categoryName;
        if (action == 'ACTION_FOOD') {
          categoryName = 'Food';
        } else if (action == 'ACTION_TRANSPORT') {
          categoryName = 'Transportation';
        }

        if (categoryName != null) {
          final db = AppDatabase();
          // Find category ID
          final categoryRow = await (db.select(db.categories)..where((c) => c.name.equals(categoryName!))).getSingleOrNull();
          
          if (categoryRow != null) {
            // Update transaction
            await (db.update(db.transactions)..where((t) => t.id.equals(txId)))
                .write(TransactionsCompanion(categoryId: drift.Value(categoryRow.id)));
          }
          await db.close();
        }
      }
    } catch (e) {
      debugPrint('Background notification action error: $e');
    }
  }
}

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init(Function(NotificationPayload) onNotificationTap) async {
    try {
      const androidInit = AndroidInitializationSettings('ic_notification');
      const initSettings = InitializationSettings(android: androidInit);

      final result = await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null) {
            try {
              final payload = NotificationPayload.fromJson(
                jsonDecode(response.payload!),
              );
              // Only trigger foreground tap if it wasn't an action button
              if (response.actionId == null) {
                onNotificationTap(payload);
              }
            } catch (e) {
              debugPrint('NotificationService: Error parsing payload: $e');
            }
          }
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );
      debugPrint('NotificationService: initialize returned: $result');

      // Create Android channels
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

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
    List<AndroidNotificationAction>? actions,
  }) async {
    // 1. Primary attempt: with ic_notification small icon and ic_launcher large icon
    try {
      final androidDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.max,
        priority: Priority.max,
        icon: 'ic_notification',
        largeIcon: const DrawableResourceAndroidBitmap('ic_launcher'),
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.message,
        actions: actions,
      );

      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(android: androidDetails),
        payload: jsonEncode(payload.toJson()),
      );
      debugPrint('NotificationService: Notification shown (id=$id, title=$title)');
      return;
    } catch (e) {
      debugPrint('NotificationService: Primary showNotification failed: $e. Retrying with basic notification.');
    }

    // 2. Secondary fallback: without large icon (standard clean Android notification)
    try {
      final fallbackDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.max,
        priority: Priority.max,
        icon: 'ic_notification',
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.message,
        actions: actions,
      );

      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(android: fallbackDetails),
        payload: jsonEncode(payload.toJson()),
      );
      debugPrint('NotificationService: Fallback notification shown (id=$id, title=$title)');
      return;
    } catch (e) {
      debugPrint('NotificationService: Secondary showNotification failed: $e. Retrying with @mipmap/ic_launcher.');
    }

    // 3. Ultimate fallback: using @mipmap/ic_launcher for small icon
    try {
      final ultimateDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.message,
        actions: actions,
      );

      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(android: ultimateDetails),
        payload: jsonEncode(payload.toJson()),
      );
      debugPrint('NotificationService: Ultimate fallback notification shown (id=$id, title=$title)');
    } catch (e, st) {
      debugPrint('NotificationService: All notification attempts FAILED: $e\n$st');
    }
  }
}
