import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationChannels {
  static const AndroidNotificationChannel dailySummary = AndroidNotificationChannel(
    'daily_summary_channel',
    'Daily Summary',
    description: 'Notifications for daily financial summaries',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel transactions = AndroidNotificationChannel(
    'transactions_channel',
    'Transactions',
    description: 'Alerts for detected or large transactions',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel budgets = AndroidNotificationChannel(
    'budgets_channel',
    'Budget Alerts',
    description: 'Notifications for budget milestones',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel insights = AndroidNotificationChannel(
    'insights_channel',
    'Smart Insights',
    description: 'Intelligent financial insights and trends',
    importance: Importance.defaultImportance,
  );

  static const AndroidNotificationChannel backup = AndroidNotificationChannel(
    'backup_channel',
    'Backup Reminders',
    description: 'Reminders to backup your financial data',
    importance: Importance.low,
  );

  static const AndroidNotificationChannel system = AndroidNotificationChannel(
    'system_channel',
    'System Alerts',
    description: 'General system notifications',
    importance: Importance.defaultImportance,
  );

  static List<AndroidNotificationChannel> get allChannels => [
        dailySummary,
        transactions,
        budgets,
        insights,
        backup,
        system,
      ];
}
