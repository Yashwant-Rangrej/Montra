import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:math';

import 'notification_service.dart';
import 'notification_channels.dart';
import 'notification_models.dart';

class NotificationScheduler {
  final NotificationService _service;
  final Random _random = Random();

  NotificationScheduler(this._service) {
    tz.initializeTimeZones();
  }

  int _generateId() => _random.nextInt(100000);

  Future<void> scheduleDailySummary() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 21, 0); // 9:00 PM
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final androidDetails = AndroidNotificationDetails(
      NotificationChannels.dailySummary.id,
      NotificationChannels.dailySummary.name,
      channelDescription: NotificationChannels.dailySummary.description,
      importance: Importance.high,
    );

    // Using zonedSchedule for the daily summary
    // This is a placeholder since offline data aggregation would need to happen right before sending
    // For a real offline-first app, you'd use flutter_background_service or workmanager
    // to calculate the daily summary and then trigger it, rather than scheduling a static message.
  }

  Future<void> scheduleBackupReminder() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 10, 0); // 10:00 AM
    scheduledDate = scheduledDate.add(const Duration(days: 7)); // 7 days from now

    final androidDetails = AndroidNotificationDetails(
      NotificationChannels.backup.id,
      NotificationChannels.backup.name,
      channelDescription: NotificationChannels.backup.description,
      importance: Importance.low,
    );
  }
}
