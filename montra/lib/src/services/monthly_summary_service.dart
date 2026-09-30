import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database/database.dart';
import '../services/notifications/notification_manager.dart';

class MonthlySummaryService {
  final AppDatabase _db;
  final NotificationManager _notificationManager;

  static const _prefKey = 'last_monthly_summary_sent';

  MonthlySummaryService(this._db, this._notificationManager);

  /// Call this on every app launch. It will fire at most once per month.
  Future<void> checkAndSend() async {
    try {
      final now = DateTime.now();
      // Only trigger on/after the 1st of a new month
      // We track which month we last sent, stored as "YYYY-MM"
      final prefs = await SharedPreferences.getInstance();
      final lastSent = prefs.getString(_prefKey);
      final lastMonth = _lastMonthKey(now);

      if (lastSent == lastMonth) {
        // Already sent for this past month
        return;
      }

      // Compute stats for the previous month
      final stats = await computeLastMonthStats(now);
      if (stats == null || stats['totalExpense'] == 0.0) {
        // No data for last month — don't send
        return;
      }

      // Fire the push notification
      await _notificationManager.showMonthlySummary(
        month: _monthName(now.month - 1 == 0 ? 12 : now.month - 1),
        year: now.month - 1 == 0 ? now.year - 1 : now.year,
        totalExpense: stats['totalExpense'] as double,
        topCategory: stats['topCategory'] as String,
        topCategoryAmount: stats['topCategoryAmount'] as double,
        topMerchant: stats['topMerchant'] as String?,
        txCount: stats['txCount'] as int,
      );

      // Mark as sent
      await prefs.setString(_prefKey, lastMonth);
    } catch (e) {
      debugPrint('MonthlySummaryService: error: $e');
    }
  }

  /// Force-trigger (for the "Generate Summary" button in Settings)
  Future<void> generateNow() async {
    try {
      final now = DateTime.now();
      final stats = await computeLastMonthStats(now);
      if (stats == null) return;

      await _notificationManager.showMonthlySummary(
        month: _monthName(now.month - 1 == 0 ? 12 : now.month - 1),
        year: now.month - 1 == 0 ? now.year - 1 : now.year,
        totalExpense: stats['totalExpense'] as double,
        topCategory: stats['topCategory'] as String,
        topCategoryAmount: stats['topCategoryAmount'] as double,
        topMerchant: stats['topMerchant'] as String?,
        txCount: stats['txCount'] as int,
      );
    } catch (e) {
      debugPrint('MonthlySummaryService.generateNow: error: $e');
    }
  }

  Future<Map<String, dynamic>?> computeLastMonthStats(DateTime now) async {
    int month = now.month - 1;
    int year = now.year;
    if (month == 0) {
      month = 12;
      year -= 1;
    }

    final allTx = await _db.select(_db.transactions).get();
    final lastMonthTx = allTx.where((t) =>
      t.transactionDate.year == year &&
      t.transactionDate.month == month &&
      t.type.toLowerCase() == 'expense'
    ).toList();

    if (lastMonthTx.isEmpty) return null;

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

    // Resolve top category name
    String topCategory = 'Uncategorized';
    double topCategoryAmount = 0;
    if (byCategory.isNotEmpty) {
      final topCatId = byCategory.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      topCategoryAmount = byCategory[topCatId]!;
      final catRow = await (_db.select(_db.categories)..where((c) => c.id.equals(topCatId))).getSingleOrNull();
      if (catRow != null) topCategory = catRow.name;
    }

    // Top merchant
    String? topMerchant;
    if (byMerchant.isNotEmpty) {
      topMerchant = byMerchant.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }

    return {
      'month': month,
      'year': year,
      'totalExpense': totalExpense,
      'topCategory': topCategory,
      'topCategoryAmount': topCategoryAmount,
      'topMerchant': topMerchant,
      'txCount': lastMonthTx.length,
      'byCategory': byCategory, // For the pie chart
    };
  }

  /// Returns "YYYY-MM" of the previous calendar month
  String _lastMonthKey(DateTime now) {
    int m = now.month - 1;
    int y = now.year;
    if (m == 0) { m = 12; y -= 1; }
    return '$y-${m.toString().padLeft(2, '0')}';
  }

  String _monthName(int month) {
    const names = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[month];
  }
}
