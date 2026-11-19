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
      if (stats == null || (stats['totalExpense'] as num? ?? 0.0) == 0.0) return;

      await _notificationManager.showMonthlySummary(
        month: _monthName(now.month - 1 == 0 ? 12 : now.month - 1),
        year: now.month - 1 == 0 ? now.year - 1 : now.year,
        totalExpense: (stats['totalExpense'] as num).toDouble(),
        topCategory: stats['topCategory'] as String,
        topCategoryAmount: (stats['topCategoryAmount'] as num).toDouble(),
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
    return computeStatsForMonth(month, year);
  }

  Future<Map<String, dynamic>?> computeStatsForMonth(int month, int year) async {
    final allTx = await _db.select(_db.transactions).get();
    final allCategories = await _db.select(_db.categories).get();
    final categoriesMap = {for (final c in allCategories) c.id: c};

    final monthTx = allTx.where((t) {
      final localDate = t.transactionDate.toLocal();
      return localDate.year == year &&
             localDate.month == month &&
             t.type.toLowerCase() != 'ignored';
    }).toList();

    final expenses = monthTx.where((t) => t.type.toLowerCase() == 'expense').toList();
    final incomes = monthTx.where((t) => t.type.toLowerCase() == 'income').toList();

    if (expenses.isEmpty && incomes.isEmpty) {
      final int daysInMonth = DateTime(year, month + 1, 0).day;
      return {
        'month': month,
        'year': year,
        'totalExpense': 0.0,
        'totalIncome': 0.0,
        'netSavings': 0.0,
        'txCount': 0,
        'incomeCount': 0,
        'daysInMonth': daysInMonth,
        'dailyAverage': 0.0,
        'topCategory': 'None',
        'topCategoryAmount': 0.0,
        'topMerchant': null,
        'topMerchantAmount': 0.0,
        'peakDay': {
          'day': 1,
          'amount': 0.0,
        },
        'byCategory': <int, double>{},
        'categoryBreakdown': <Map<String, dynamic>>[],
        'merchantBreakdown': <Map<String, dynamic>>[],
        'paymentMethodBreakdown': <Map<String, dynamic>>[],
        'topTransactions': <Map<String, dynamic>>[],
        'allTransactions': <Map<String, dynamic>>[],
      };
    }

    double totalExpense = 0;
    double totalIncome = 0;
    for (final tx in expenses) {
      totalExpense += tx.amount;
    }
    for (final tx in incomes) {
      totalIncome += tx.amount;
    }

    final double netSavings = totalIncome - totalExpense;
    final int daysInMonth = DateTime(year, month + 1, 0).day;
    final double dailyAverage = daysInMonth > 0 ? (totalExpense / daysInMonth) : 0.0;

    // Category breakdown
    final Map<int, double> byCategory = {};
    final Map<int, int> categoryCounts = {};
    for (final tx in expenses) {
      final catId = tx.categoryId ?? 0;
      byCategory[catId] = (byCategory[catId] ?? 0) + tx.amount;
      categoryCounts[catId] = (categoryCounts[catId] ?? 0) + 1;
    }

    final List<Map<String, dynamic>> categoryBreakdown = [];
    byCategory.forEach((catId, amount) {
      final cat = categoriesMap[catId];
      categoryBreakdown.add({
        'categoryId': catId,
        'name': cat?.name ?? 'Uncategorized',
        'icon': cat?.icon,
        'color': cat?.color,
        'amount': amount,
        'count': categoryCounts[catId] ?? 0,
        'percentage': totalExpense > 0 ? (amount / totalExpense) * 100 : 0.0,
      });
    });
    categoryBreakdown.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

    String topCategory = 'Uncategorized';
    double topCategoryAmount = 0;
    if (categoryBreakdown.isNotEmpty) {
      topCategory = categoryBreakdown.first['name'] as String;
      topCategoryAmount = categoryBreakdown.first['amount'] as double;
    }

    // Merchant breakdown
    final Map<String, double> merchantSpend = {};
    final Map<String, int> merchantCounts = {};
    for (final tx in expenses) {
      if (tx.merchant != null && tx.merchant!.trim().isNotEmpty) {
        final m = tx.merchant!.trim();
        merchantSpend[m] = (merchantSpend[m] ?? 0) + tx.amount;
        merchantCounts[m] = (merchantCounts[m] ?? 0) + 1;
      }
    }

    final List<Map<String, dynamic>> merchantBreakdown = [];
    merchantSpend.forEach((m, amount) {
      merchantBreakdown.add({
        'name': m,
        'amount': amount,
        'count': merchantCounts[m] ?? 0,
        'percentage': totalExpense > 0 ? (amount / totalExpense) * 100 : 0.0,
      });
    });
    merchantBreakdown.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

    String? topMerchant;
    double topMerchantAmount = 0;
    if (merchantBreakdown.isNotEmpty) {
      topMerchant = merchantBreakdown.first['name'] as String;
      topMerchantAmount = merchantBreakdown.first['amount'] as double;
    }

    // Payment methods breakdown
    final Map<String, double> paymentMethods = {};
    final Map<String, int> paymentMethodCounts = {};
    for (final tx in expenses) {
      String method = (tx.originalSms != null && (tx.paymentMethod == null || tx.paymentMethod == 'Cash'))
          ? 'UPI'
          : (tx.paymentMethod ?? 'Cash');
      if (method.trim().isEmpty) method = 'Cash';
      paymentMethods[method] = (paymentMethods[method] ?? 0) + tx.amount;
      paymentMethodCounts[method] = (paymentMethodCounts[method] ?? 0) + 1;
    }

    final List<Map<String, dynamic>> paymentMethodBreakdown = [];
    paymentMethods.forEach((method, amount) {
      paymentMethodBreakdown.add({
        'method': method,
        'amount': amount,
        'count': paymentMethodCounts[method] ?? 0,
        'percentage': totalExpense > 0 ? (amount / totalExpense) * 100 : 0.0,
      });
    });
    paymentMethodBreakdown.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

    // Top 5 largest expenses
    final sortedExpenses = List<Transaction>.from(expenses)..sort((a, b) => b.amount.compareTo(a.amount));
    final List<Map<String, dynamic>> topTransactions = sortedExpenses.take(5).map((tx) {
      final cat = categoriesMap[tx.categoryId];
      return {
        'id': tx.id,
        'amount': tx.amount,
        'merchant': tx.merchant ?? tx.notes ?? 'Expense',
        'date': tx.transactionDate.toLocal(),
        'paymentMethod': (tx.originalSms != null && (tx.paymentMethod == null || tx.paymentMethod == 'Cash'))
            ? 'UPI'
            : (tx.paymentMethod ?? 'Cash'),
        'categoryName': cat?.name ?? 'Uncategorized',
        'categoryIcon': cat?.icon,
        'categoryId': tx.categoryId,
        'accountId': tx.accountId,
        'targetAccountId': tx.targetAccountId,
        'availableBalance': tx.availableBalance,
        'notes': tx.notes,
        'originalSms': tx.originalSms,
        'bankTransactionId': tx.bankTransactionId,
        'receiptAttachment': tx.receiptAttachment,
      };
    }).toList();

    // All transactions for that month, sorted by date descending
    final sortedMonthTx = List<Transaction>.from(monthTx)
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    final List<Map<String, dynamic>> allMonthTransactions = sortedMonthTx.map((tx) {
      final cat = categoriesMap[tx.categoryId];
      return {
        'id': tx.id,
        'amount': tx.amount,
        'type': tx.type,
        'merchant': tx.merchant ?? tx.notes ?? (tx.type.toLowerCase() == 'expense' ? 'Expense' : 'Income'),
        'date': tx.transactionDate.toLocal(),
        'paymentMethod': (tx.originalSms != null && (tx.paymentMethod == null || tx.paymentMethod == 'Cash'))
            ? 'UPI'
            : (tx.paymentMethod ?? 'Cash'),
        'categoryName': cat?.name ?? 'Uncategorized',
        'categoryIcon': cat?.icon,
        'categoryId': tx.categoryId,
        'accountId': tx.accountId,
        'targetAccountId': tx.targetAccountId,
        'availableBalance': tx.availableBalance,
        'notes': tx.notes,
        'originalSms': tx.originalSms,
        'bankTransactionId': tx.bankTransactionId,
        'receiptAttachment': tx.receiptAttachment,
      };
    }).toList();

    // Peak spending day
    final Map<int, double> dailySpend = {};
    for (final tx in expenses) {
      final day = tx.transactionDate.toLocal().day;
      dailySpend[day] = (dailySpend[day] ?? 0) + tx.amount;
    }
    int peakDayNumber = 1;
    double peakDayAmount = 0;
    dailySpend.forEach((day, amount) {
      if (amount > peakDayAmount) {
        peakDayAmount = amount;
        peakDayNumber = day;
      }
    });

    return {
      'month': month,
      'year': year,
      'totalExpense': totalExpense,
      'totalIncome': totalIncome,
      'netSavings': netSavings,
      'txCount': expenses.length,
      'incomeCount': incomes.length,
      'daysInMonth': daysInMonth,
      'dailyAverage': dailyAverage,
      'topCategory': topCategory,
      'topCategoryAmount': topCategoryAmount,
      'topMerchant': topMerchant,
      'topMerchantAmount': topMerchantAmount,
      'peakDay': {
        'day': peakDayNumber,
        'amount': peakDayAmount,
      },
      'byCategory': byCategory, // For backwards compatibility
      'categoryBreakdown': categoryBreakdown,
      'merchantBreakdown': merchantBreakdown,
      'paymentMethodBreakdown': paymentMethodBreakdown,
      'topTransactions': topTransactions,
      'allTransactions': allMonthTransactions,
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
