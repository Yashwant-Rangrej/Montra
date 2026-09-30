import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../data/database/database.dart';
import '../services/notifications/notification_channels.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'notifications/notification_models.dart';

const _taskName = 'monthly_summary_task';
const _uniqueTaskName = 'monthly_summary_periodic';
const _prefKey = 'last_monthly_summary_sent';

/// Called by WorkManager in a background isolate (app can be closed).
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == _taskName) {
      await _runMonthlySummaryTask();
    }
    return Future.value(true);
  });
}

Future<void> _runMonthlySummaryTask() async {
  try {
    final now = DateTime.now();

    // Only fire on the 1st day of the month
    if (now.day != 1) return;

    // Check we haven't already sent for this previous month
    final prefs = await SharedPreferences.getInstance();
    int lastMonth = now.month - 1;
    int lastYear = now.year;
    if (lastMonth == 0) { lastMonth = 12; lastYear -= 1; }
    final monthKey = '$lastYear-${lastMonth.toString().padLeft(2, '0')}';

    if (prefs.getString(_prefKey) == monthKey) return; // already sent

    // Compute stats from DB
    final db = AppDatabase();
    try {
      final allTx = await db.select(db.transactions).get();
      final lastMonthTx = allTx.where((t) =>
        t.transactionDate.year == lastYear &&
        t.transactionDate.month == lastMonth &&
        t.type.toLowerCase() == 'expense'
      ).toList();

      if (lastMonthTx.isEmpty) {
        await db.close();
        return;
      }

      double totalExpense = 0;
      final Map<int, double> byCategory = {};
      final Map<String, double> byMerchant = {};

      for (final tx in lastMonthTx) {
        totalExpense += tx.amount;
        if (tx.categoryId != null) {
          byCategory[tx.categoryId!] = (byCategory[tx.categoryId!] ?? 0) + tx.amount;
        }
        if (tx.merchant != null && tx.merchant!.isNotEmpty) {
          byMerchant[tx.merchant!] = (byMerchant[tx.merchant!] ?? 0) + tx.amount;
        }
      }

      String topCategory = 'Uncategorized';
      double topCategoryAmount = 0;
      if (byCategory.isNotEmpty) {
        final topEntry = byCategory.entries.reduce((a, b) => a.value > b.value ? a : b);
        topCategoryAmount = topEntry.value;
        final catRow = await (db.select(db.categories)..where((c) => c.id.equals(topEntry.key))).getSingleOrNull();
        if (catRow != null) topCategory = catRow.name;
      }

      String? topMerchant;
      if (byMerchant.isNotEmpty) {
        topMerchant = byMerchant.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      }

      final monthName = _monthNameStr(lastMonth);
      final merchantLine = topMerchant != null ? ' | Top: $topMerchant' : '';

      final plugin = FlutterLocalNotificationsPlugin();
      const androidInit = AndroidInitializationSettings('ic_notification');
      await plugin.initialize(settings: const InitializationSettings(android: androidInit));

      final androidDetails = AndroidNotificationDetails(
        NotificationChannels.insights.id,
        NotificationChannels.insights.name,
        channelDescription: NotificationChannels.insights.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: 'ic_notification',
        visibility: NotificationVisibility.public,
      );

      final payloadStr = jsonEncode(const NotificationPayload(type: 'monthlySummary', route: '/monthly-summary-report').toJson());

      await plugin.show(
        id: 8888,
        title: '📊 $monthName $lastYear Summary',
        body: 'Spent ₹${totalExpense.toStringAsFixed(0)} across ${lastMonthTx.length} transactions. Most: $topCategory (₹${topCategoryAmount.toStringAsFixed(0)})$merchantLine. Tap to view.',
        notificationDetails: NotificationDetails(android: androidDetails),
        payload: payloadStr,
      );

      // Mark as sent
      await prefs.setString(_prefKey, monthKey);
    } finally {
      await db.close();
    }
  } catch (e) {
    debugPrint('MonthlySummaryWorker error: $e');
  }
}

String _monthNameStr(int month) {
  const names = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return names[month];
}

/// Schedules the periodic WorkManager task.
/// Call once on app init — WorkManager persists it across reboots.
Future<void> registerMonthlySummaryWorker() async {
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    _uniqueTaskName,
    _taskName,
    // WorkManager minimum period is 15 minutes.
    // It runs roughly every 12 hours; on the 1st the task itself checks the date.
    frequency: const Duration(hours: 12),
    constraints: Constraints(
      networkType: NetworkType.notRequired,
      requiresBatteryNotLow: false,
    ),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
  debugPrint('MonthlySummaryWorker: periodic task registered (12h interval)');
}
