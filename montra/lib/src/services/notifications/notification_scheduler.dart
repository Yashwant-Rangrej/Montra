import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationScheduler {

  NotificationScheduler() {
    tz.initializeTimeZones();
  }

  Future<void> scheduleDailySummary() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 21, 0); // 9:00 PM
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Using zonedSchedule for the daily summary
    // This is a placeholder since offline data aggregation would need to happen right before sending
    // For a real offline-first app, you'd use flutter_background_service or workmanager
    // to calculate the daily summary and then trigger it, rather than scheduling a static message.
  }

  Future<void> scheduleBackupReminder() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 10, 0); // 10:00 AM
    scheduledDate = scheduledDate.add(const Duration(days: 7)); // 7 days from now
  }
}
