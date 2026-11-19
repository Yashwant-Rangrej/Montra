import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:drift/drift.dart' as drift;
import '../../providers/repository_providers.dart';
import '../../data/database/database.dart';
import '../../services/monthly_summary_service.dart';
import '../../services/notifications/notification_manager.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/category_icon_helper.dart';
import '../../domain/entities/transaction_entity.dart';

class MonthlySummaryScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? stats;

  const MonthlySummaryScreen({
    super.key,
    this.stats,
  });

  @override
  ConsumerState<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends ConsumerState<MonthlySummaryScreen> {
  bool _isSaving = false;
  bool _isLoading = false;
  Map<String, dynamic>? _stats;
  int _touchedCategoryIndex = -1;

  late int _selectedMonth;
  late int _selectedYear;

  // Filter for itemized transactions list: 'all', 'expense', 'income'
  String _txFilter = 'all';
  bool _showAllTxList = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    if (widget.stats != null) {
      _stats = widget.stats;
      _selectedMonth = widget.stats!['month'] as int? ?? now.month;
      _selectedYear = widget.stats!['year'] as int? ?? now.year;
    } else {
      _selectedMonth = now.month;
      _selectedYear = now.year;
      _loadStatsForMonth(_selectedMonth, _selectedYear);
    }
  }

  String _monthName(int month) {
    const names = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    if (month >= 1 && month <= 12) return names[month];
    return '';
  }

  String _formatCurrency(double amount, {bool decimals = true}) {
    try {
      final formatter = NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: decimals ? 2 : 0,
      );
      return formatter.format(amount);
    } catch (_) {
      return '₹${decimals ? amount.toStringAsFixed(2) : amount.toStringAsFixed(0)}';
    }
  }

  bool get _canGoNext {
    final now = DateTime.now();
    if (_selectedYear < now.year) return true;
    if (_selectedYear == now.year && _selectedMonth < now.month) return true;
    return false;
  }

  Future<void> _loadStatsForMonth(int month, int year) async {
    setState(() {
      _isLoading = true;
      _selectedMonth = month;
      _selectedYear = year;
      _touchedCategoryIndex = -1;
      _showAllTxList = false;
    });

    final db = ref.read(databaseProvider);
    final notifManager = ref.read(notificationManagerProvider);
    final service = MonthlySummaryService(db, notifManager);

    final computed = await service.computeStatsForMonth(month, year);
    if (mounted) {
      setState(() {
        _stats = computed;
        _isLoading = false;
      });
    }
  }

  void _previousMonth() {
    int m = _selectedMonth - 1;
    int y = _selectedYear;
    if (m < 1) {
      m = 12;
      y -= 1;
    }
    _loadStatsForMonth(m, y);
  }

  void _nextMonth() {
    if (!_canGoNext) return;
    int m = _selectedMonth + 1;
    int y = _selectedYear;
    if (m > 12) {
      m = 1;
      y += 1;
    }
    _loadStatsForMonth(m, y);
  }

  void _showMonthPickerSheet() {
    int pickerYear = _selectedYear;
    final now = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded),
                          onPressed: pickerYear > 2020
                              ? () => setModalState(() => pickerYear--)
                              : null,
                        ),
                        Text(
                          '$pickerYear',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded),
                          onPressed: pickerYear < now.year
                              ? () => setModalState(() => pickerYear++)
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final monthNum = index + 1;
                        final isFuture = pickerYear > now.year ||
                            (pickerYear == now.year && monthNum > now.month);
                        final isSelected =
                            pickerYear == _selectedYear && monthNum == _selectedMonth;

                        return InkWell(
                          onTap: isFuture
                              ? null
                              : () {
                                  Navigator.pop(ctx);
                                  _loadStatsForMonth(monthNum, pickerYear);
                                },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : isFuture
                                      ? Colors.grey.withValues(alpha: 0.1)
                                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? null
                                  : Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _monthName(monthNum).substring(0, 3),
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : isFuture
                                        ? Colors.grey.shade400
                                        : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveSummary() async {
    if (_stats == null) return;
    setState(() => _isSaving = true);
    final db = ref.read(databaseProvider);

    try {
      // Remove any previously saved snapshot for this month & year to avoid duplicates
      await (db.delete(db.savedSummaries)
            ..where((tbl) => tbl.month.equals(_selectedMonth) & tbl.year.equals(_selectedYear)))
          .go();

      await db.into(db.savedSummaries).insert(
        SavedSummariesCompanion.insert(
          month: _selectedMonth,
          year: _selectedYear,
          totalExpense: ((_stats!['totalExpense'] as num?) ?? 0.0).toDouble(),
          topCategory: (_stats!['topCategory'] as String?) ?? 'Uncategorized',
          topCategoryAmount: ((_stats!['topCategoryAmount'] as num?) ?? 0.0).toDouble(),
          topMerchant: drift.Value(_stats!['topMerchant'] as String?),
          transactionCount: (_stats!['txCount'] as int?) ?? 0,
          totalIncome: drift.Value(((_stats!['totalIncome'] as num?) ?? 0.0).toDouble()),
          netSavings: drift.Value(((_stats!['netSavings'] as num?) ?? 0.0).toDouble()),
          dailyAverage: drift.Value(((_stats!['dailyAverage'] as num?) ?? 0.0).toDouble()),
          incomeCount: drift.Value((_stats!['incomeCount'] as int?) ?? 0),
          categoryBreakdown: drift.Value(
            _stats!['categoryBreakdown'] != null ? jsonEncode(_stats!['categoryBreakdown']) : null,
          ),
          merchantBreakdown: drift.Value(
            _stats!['merchantBreakdown'] != null ? jsonEncode(_stats!['merchantBreakdown']) : null,
          ),
          paymentMethodBreakdown: drift.Value(
            _stats!['paymentMethodBreakdown'] != null ? jsonEncode(_stats!['paymentMethodBreakdown']) : null,
          ),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_monthName(_selectedMonth)} $_selectedYear report saved to database!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save report: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _shareReport() {
    if (_stats == null) return;
    final month = _monthName(_selectedMonth);
    final year = _selectedYear;
    final totalExpense = (_stats!['totalExpense'] as num?)?.toDouble() ?? 0.0;
    final totalIncome = (_stats!['totalIncome'] as num?)?.toDouble() ?? 0.0;
    final netSavings = (_stats!['netSavings'] as num?)?.toDouble() ?? (totalIncome - totalExpense);
    final txCount = _stats!['txCount'] as int? ?? 0;
    final incomeCount = _stats!['incomeCount'] as int? ?? 0;
    final dailyAvg = (_stats!['dailyAverage'] as num?)?.toDouble() ?? 0.0;
    final topCategory = _stats!['topCategory'] as String? ?? 'None';
    final topCategoryAmount = (_stats!['topCategoryAmount'] as num?)?.toDouble() ?? 0.0;
    final topMerchant = _stats!['topMerchant'] as String? ?? 'None';
    final topMerchantAmount = (_stats!['topMerchantAmount'] as num?)?.toDouble() ?? 0.0;
    final peakDay = _stats!['peakDay'] as Map<String, dynamic>?;

    final categories = (_stats!['categoryBreakdown'] as List<dynamic>?) ?? [];
    final merchants = (_stats!['merchantBreakdown'] as List<dynamic>?) ?? [];

    final buffer = StringBuffer();
    buffer.writeln('📊 Montra Monthly Statement - $month $year');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('💸 Total Expenses: ${_formatCurrency(totalExpense)} ($txCount txns)');
    if (totalIncome > 0) {
      buffer.writeln('💰 Total Income: ${_formatCurrency(totalIncome)} ($incomeCount txns)');
      final sign = netSavings >= 0 ? '+' : '';
      buffer.writeln('📈 Net Savings: $sign${_formatCurrency(netSavings)}');
      final savingsRate = (netSavings / totalIncome * 100).toStringAsFixed(1);
      buffer.writeln('🎯 Savings Rate: $savingsRate%');
    }
    buffer.writeln('📅 Daily Average Spend: ${_formatCurrency(dailyAvg, decimals: false)}/day');
    if (topCategory != 'None') {
      buffer.writeln('🌟 Top Category: $topCategory (${_formatCurrency(topCategoryAmount, decimals: false)})');
    }
    if (topMerchant != 'None') {
      buffer.writeln('🏬 Top Payee: $topMerchant (${_formatCurrency(topMerchantAmount, decimals: false)})');
    }
    if (peakDay != null && (peakDay['amount'] as num? ?? 0) > 0) {
      buffer.writeln('⚡ Peak Spending Day: ${peakDay['day']}th $month (${_formatCurrency((peakDay['amount'] as num).toDouble(), decimals: false)})');
    }

    if (categories.isNotEmpty) {
      buffer.writeln('\n📂 Category Breakdown:');
      for (final cat in categories.take(6)) {
        final name = cat['name'];
        final amount = _formatCurrency((cat['amount'] as num).toDouble(), decimals: false);
        final pct = (cat['percentage'] as num).toStringAsFixed(1);
        buffer.writeln(' • $name: $amount ($pct%)');
      }
    }

    if (merchants.isNotEmpty) {
      buffer.writeln('\n🏬 Top Payees:');
      for (final m in merchants.take(5)) {
        final name = m['name'];
        final amount = _formatCurrency((m['amount'] as num).toDouble(), decimals: false);
        final count = m['count'];
        buffer.writeln(' • $name: $amount ($count txns)');
      }
    }

    buffer.writeln('\n🔒 Generated privately and offline on-device with Montra.');

    SharePlus.instance.share(
      ShareParams(
        text: buffer.toString(),
        subject: 'Montra Financial Statement - $month $year',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthName = _monthName(_selectedMonth);
    final year = _selectedYear;

    return Scaffold(
      appBar: AppBar(
        title: Text('$monthName $year Statement'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Statement',
            onPressed: (_stats != null && !_isLoading) ? _shareReport : null,
          ),
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.bookmark_add_outlined),
            tooltip: 'Save Statement',
            onPressed: (_stats != null && !_isLoading && !_isSaving) ? _saveSummary : null,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── MONTH SELECTOR NAVIGATION BAR ─────────────────────────────
          _buildMonthSelector(context, monthName: monthName, year: year),

          // ── MAIN CONTENT (SCROLLABLE) ──────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildBodyContent(context, monthName: monthName, year: year),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(
    BuildContext context, {
    required String monthName,
    required int year,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            tooltip: 'Previous Month',
            onPressed: _isLoading ? null : _previousMonth,
          ),
          InkWell(
            onTap: _isLoading ? null : _showMonthPickerSheet,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$monthName $year',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down_rounded, size: 20),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            tooltip: 'Next Month',
            onPressed: (_isLoading || !_canGoNext) ? null : _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent(
    BuildContext context, {
    required String monthName,
    required int year,
  }) {
    if (_stats == null) {
      return _buildEmptyMonthView(context, monthName: monthName, year: year);
    }

    final totalExpense = (_stats!['totalExpense'] as num?)?.toDouble() ?? 0.0;
    final totalIncome = (_stats!['totalIncome'] as num?)?.toDouble() ?? 0.0;
    final netSavings = (_stats!['netSavings'] as num?)?.toDouble() ?? (totalIncome - totalExpense);
    final txCount = _stats!['txCount'] as int? ?? 0;
    final incomeCount = _stats!['incomeCount'] as int? ?? 0;
    final dailyAvg = (_stats!['dailyAverage'] as num?)?.toDouble() ?? 0.0;
    final daysInMonth = _stats!['daysInMonth'] as int? ?? DateTime(year, _selectedMonth + 1, 0).day;

    final topCategory = _stats!['topCategory'] as String? ?? 'None';
    final topCategoryAmount = (_stats!['topCategoryAmount'] as num?)?.toDouble() ?? 0.0;
    final topMerchant = _stats!['topMerchant'] as String?;
    final topMerchantAmount = (_stats!['topMerchantAmount'] as num?)?.toDouble() ?? 0.0;
    final peakDay = _stats!['peakDay'] as Map<String, dynamic>?;

    final categoriesList = (_stats!['categoryBreakdown'] as List<dynamic>?) ?? [];
    final merchantsList = (_stats!['merchantBreakdown'] as List<dynamic>?) ?? [];
    final paymentMethodsList = (_stats!['paymentMethodBreakdown'] as List<dynamic>?) ?? [];
    final topTransactionsList = (_stats!['topTransactions'] as List<dynamic>?) ?? [];
    final allTransactionsList = (_stats!['allTransactions'] as List<dynamic>?) ?? [];

    if (totalExpense == 0.0 && totalIncome == 0.0 && txCount == 0 && incomeCount == 0) {
      return _buildEmptyMonthView(context, monthName: monthName, year: year);
    }

    final chartColors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.tertiary,
      Colors.teal,
      Colors.orange.shade700,
      Colors.indigo.shade400,
      Colors.purple,
      Colors.pink.shade400,
      Colors.blueGrey,
    ];

    // Pie chart sections
    final List<PieChartSectionData> pieSections = [];
    for (int i = 0; i < categoriesList.length; i++) {
      final cat = categoriesList[i];
      final amount = (cat['amount'] as num).toDouble();
      final isTouched = i == _touchedCategoryIndex;
      final radius = isTouched ? 55.0 : 45.0;
      final color = chartColors[i % chartColors.length];
      final pct = totalExpense > 0 ? (amount / totalExpense) * 100 : 0.0;

      pieSections.add(
        PieChartSectionData(
          color: color,
          value: amount,
          title: pct >= 8 ? '${pct.toStringAsFixed(0)}%' : '',
          radius: radius,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── HERO FINANCIAL STATEMENT BANNER ─────────────────────────────
          _buildHeroBanner(
            context,
            monthName: monthName,
            year: year,
            totalExpense: totalExpense,
            totalIncome: totalIncome,
            netSavings: netSavings,
            dailyAverage: dailyAvg,
            txCount: txCount,
            incomeCount: incomeCount,
            daysInMonth: daysInMonth,
          ),
          const SizedBox(height: 18),

          // ── SAVINGS HEALTH BAR (IF INCOME RECORDED) ──────────────────────
          if (totalIncome > 0) ...[
            _buildSavingsRateCard(
              context,
              totalIncome: totalIncome,
              totalExpense: totalExpense,
              netSavings: netSavings,
            ),
            const SizedBox(height: 18),
          ],

          // ── KEY FINANCIAL HIGHLIGHTS (TOP CAT, TOP PAYEE, PEAK DAY) ──────
          _buildHighlightsSection(
            context,
            topCategory: topCategory,
            topCategoryAmount: topCategoryAmount,
            topMerchant: topMerchant,
            topMerchantAmount: topMerchantAmount,
            peakDay: peakDay,
            monthName: monthName,
            totalExpense: totalExpense,
            txCount: txCount,
          ),
          const SizedBox(height: 24),

          // ── CATEGORY EXPENSE BREAKDOWN (DONUT + ITEMIZED LIST) ──────────
          if (categoriesList.isNotEmpty) ...[
            _buildCategoryBreakdownCard(
              context,
              pieSections: pieSections,
              categoriesList: categoriesList,
              chartColors: chartColors,
              totalExpense: totalExpense,
            ),
            const SizedBox(height: 24),
          ],

          // ── TOP PAYEES & MERCHANTS LEADERBOARD ──────────────────────────
          if (merchantsList.isNotEmpty) ...[
            _buildTopMerchantsCard(
              context,
              merchantsList: merchantsList,
              totalExpense: totalExpense,
            ),
            const SizedBox(height: 24),
          ],

          // ── PAYMENT METHODS BREAKDOWN ──────────────────────────────────
          if (paymentMethodsList.isNotEmpty) ...[
            _buildPaymentModesCard(
              context,
              paymentMethodsList: paymentMethodsList,
              totalExpense: totalExpense,
            ),
            const SizedBox(height: 24),
          ],

          // ── TOP 5 MAJOR PURCHASES / EXPENSES ───────────────────────────
          if (topTransactionsList.isNotEmpty) ...[
            _buildTopExpensesCard(
              context,
              topTransactionsList: topTransactionsList,
            ),
            const SizedBox(height: 24),
          ],

          // ── ITEMIZED ALL TRANSACTIONS OF THIS MONTH ONLY ─────────────────
          _buildAllTransactionsSection(
            context,
            allTransactionsList: allTransactionsList,
            monthName: monthName,
            year: year,
          ),
          const SizedBox(height: 24),

          // ── FOOTER ACTIONS ─────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _shareReport,
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Share Summary'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isSaving ? null : _saveSummary,
                  icon: const Icon(Icons.bookmark_added_rounded),
                  label: const Text('Save Report'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmptyMonthView(
    BuildContext context, {
    required String monthName,
    required int year,
  }) {
    final now = DateTime.now();
    final isCurrentMonth = (year == now.year && _selectedMonth == now.month);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Transactions in $monthName $year',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Transactions belonging strictly to $monthName $year will be analyzed and shown here automatically.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (!isCurrentMonth)
              FilledButton.icon(
                onPressed: () => _loadStatsForMonth(now.month, now.year),
                icon: const Icon(Icons.today_rounded),
                label: const Text('Go to Current Month'),
              ),
            if (isCurrentMonth)
              FilledButton.icon(
                onPressed: () => context.push('/add-transaction'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Transaction'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner(
    BuildContext context, {
    required String monthName,
    required int year,
    required double totalExpense,
    required double totalIncome,
    required double netSavings,
    required double dailyAverage,
    required int txCount,
    required int incomeCount,
    required int daysInMonth,
  }) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary,
            Color.lerp(primary, Colors.black, 0.28)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$monthName $year Statement'.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$txCount expenses',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Total Expenses',
            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(totalExpense),
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeroSubmetric(
                label: 'Daily Average',
                value: '${_formatCurrency(dailyAverage, decimals: false)}/day',
              ),
              if (totalIncome > 0)
                _buildHeroSubmetric(
                  label: 'Total Income',
                  value: _formatCurrency(totalIncome, decimals: false),
                  valueColor: Colors.greenAccent.shade200,
                ),
              if (totalIncome > 0)
                _buildHeroSubmetric(
                  label: 'Net Savings',
                  value: '${netSavings >= 0 ? "+" : ""}${_formatCurrency(netSavings, decimals: false)}',
                  valueColor: netSavings >= 0 ? Colors.greenAccent.shade200 : Colors.redAccent.shade100,
                ),
              if (totalIncome <= 0)
                _buildHeroSubmetric(
                  label: 'Days in Month',
                  value: '$daysInMonth Days',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSubmetric({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsRateCard(
    BuildContext context, {
    required double totalIncome,
    required double totalExpense,
    required double netSavings,
  }) {
    final savingsRatio = totalIncome > 0 ? (netSavings / totalIncome) : 0.0;
    final savingsPercent = (savingsRatio * 100).clamp(-100.0, 100.0);
    final isPositive = netSavings >= 0;

    final progressVal = isPositive ? (savingsRatio.clamp(0.0, 1.0)) : 0.0;
    final barColor = savingsPercent >= 20
        ? Colors.green.shade600
        : savingsPercent > 0
            ? Colors.amber.shade700
            : Colors.red.shade600;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.savings_rounded : Icons.warning_amber_rounded,
                    color: barColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Monthly Savings Rate',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${isPositive ? "+" : ""}${savingsPercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: barColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressVal,
              backgroundColor: barColor.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isPositive
                ? 'You retained ${_formatCurrency(netSavings, decimals: false)} (${savingsPercent.toStringAsFixed(1)}%) of your earnings this month.'
                : 'Expenses exceeded income by ${_formatCurrency(netSavings.abs(), decimals: false)} this month.',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsSection(
    BuildContext context, {
    required String topCategory,
    required double topCategoryAmount,
    required String? topMerchant,
    required double topMerchantAmount,
    required Map<String, dynamic>? peakDay,
    required String monthName,
    required double totalExpense,
    required int txCount,
  }) {
    final peakDayNumber = peakDay?['day'] ?? 1;
    final peakDayAmount = (peakDay?['amount'] as num?)?.toDouble() ?? 0.0;
    final topCatPct = totalExpense > 0 ? (topCategoryAmount / totalExpense * 100).toStringAsFixed(0) : '0';

    return Row(
      children: [
        Expanded(
          child: _buildHighlightCard(
            context,
            icon: Icons.star_rounded,
            iconColor: Colors.amber.shade700,
            bgColor: Colors.amber.withValues(alpha: 0.1),
            title: 'Top Category',
            value: topCategory,
            subtitle: '${_formatCurrency(topCategoryAmount, decimals: false)} ($topCatPct%)',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildHighlightCard(
            context,
            icon: Icons.storefront_rounded,
            iconColor: Colors.indigo,
            bgColor: Colors.indigo.withValues(alpha: 0.1),
            title: 'Top Payee',
            value: topMerchant ?? 'Various',
            subtitle: topMerchantAmount > 0 ? _formatCurrency(topMerchantAmount, decimals: false) : 'N/A',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildHighlightCard(
            context,
            icon: Icons.bolt_rounded,
            iconColor: Colors.red.shade700,
            bgColor: Colors.red.withValues(alpha: 0.1),
            title: 'Peak Day',
            value: '${peakDayNumber}th $monthName',
            subtitle: peakDayAmount > 0 ? _formatCurrency(peakDayAmount, decimals: false) : 'N/A',
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: bgColor,
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownCard(
    BuildContext context, {
    required List<PieChartSectionData> pieSections,
    required List<dynamic> categoriesList,
    required List<Color> chartColors,
    required double totalExpense,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Expense Breakdown by Category',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Donut Chart
          SizedBox(
            height: 190,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedCategoryIndex = -1;
                        return;
                      }
                      _touchedCategoryIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sectionsSpace: 3,
                centerSpaceRadius: 45,
                sections: pieSections,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Itemized Category List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categoriesList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final cat = categoriesList[index];
              final name = cat['name'] as String;
              final iconKey = cat['icon'] as String?;
              final amount = (cat['amount'] as num).toDouble();
              final count = cat['count'] as int? ?? 0;
              final percentage = (cat['percentage'] as num).toDouble();
              final color = chartColors[index % chartColors.length];
              final isTouched = index == _touchedCategoryIndex;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isTouched ? color.withValues(alpha: 0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: color.withValues(alpha: 0.15),
                          child: Icon(
                            CategoryIconHelper.getIcon(name, iconKey),
                            size: 18,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              Text(
                                '$count transactions',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatCurrency(amount),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 11,
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: totalExpense > 0 ? amount / totalExpense : 0,
                        backgroundColor: color.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopMerchantsCard(
    BuildContext context, {
    required List<dynamic> merchantsList,
    required double totalExpense,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.leaderboard_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Top Spending Payees & Merchants',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: merchantsList.length > 5 ? 5 : merchantsList.length,
            separatorBuilder: (context, index) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final m = merchantsList[index];
              final name = m['name'] as String;
              final amount = (m['amount'] as num).toDouble();
              final count = m['count'] as int? ?? 0;
              final percentage = (m['percentage'] as num).toDouble();

              return Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: index == 0
                          ? Colors.amber.shade700
                          : index == 1
                              ? Colors.grey.shade600
                              : index == 2
                                  ? Colors.brown.shade400
                                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: index <= 2 ? Colors.white : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '$count purchases • ${percentage.toStringAsFixed(1)}% of total',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatCurrency(amount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.expense,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentModesCard(
    BuildContext context, {
    required List<dynamic> paymentMethodsList,
    required double totalExpense,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Payment Modes Distribution',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: paymentMethodsList.map((pm) {
              final method = pm['method'] as String;
              final amount = (pm['amount'] as num).toDouble();
              final count = pm['count'] as int? ?? 0;
              final percentage = (pm['percentage'] as num).toDouble();

              IconData icon = Icons.payments_outlined;
              if (method.toUpperCase().contains('UPI')) icon = Icons.qr_code_2_rounded;
              if (method.toUpperCase().contains('CARD')) icon = Icons.credit_card_rounded;
              if (method.toUpperCase().contains('NET') || method.toUpperCase().contains('BANK')) {
                icon = Icons.account_balance_rounded;
              }

              return Container(
                width: (MediaQuery.of(context).size.width - 76) / 2,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            method,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatCurrency(amount, decimals: false),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}% ($count txns)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopExpensesCard(
    BuildContext context, {
    required List<dynamic> topTransactionsList,
  }) {
    final dateFormat = DateFormat('dd MMM, hh:mm a');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded, color: Colors.deepOrange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Top 5 Major Purchases',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topTransactionsList.length,
            separatorBuilder: (context, index) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final tx = topTransactionsList[index];
              final merchant = tx['merchant'] as String;
              final amount = (tx['amount'] as num).toDouble();
              final date = tx['date'] as DateTime;
              final categoryName = tx['categoryName'] as String?;
              final categoryIcon = tx['categoryIcon'] as String?;
              final paymentMethod = tx['paymentMethod'] as String;

              return InkWell(
                onTap: () {
                  final entity = TransactionEntity(
                    id: tx['id'] as int,
                    amount: amount,
                    type: 'Expense',
                    merchant: tx['merchant'] as String?,
                    categoryId: tx['categoryId'] as int?,
                    paymentMethod: tx['paymentMethod'] as String?,
                    accountId: (tx['accountId'] as int?) ?? 1,
                    targetAccountId: tx['targetAccountId'] as int?,
                    availableBalance: (tx['availableBalance'] as num?)?.toDouble(),
                    transactionDate: date,
                    notes: tx['notes'] as String?,
                    originalSms: tx['originalSms'] as String?,
                    bankTransactionId: tx['bankTransactionId'] as String?,
                    receiptAttachment: tx['receiptAttachment'] as String?,
                  );
                  context.push('/add-transaction', extra: entity).then((_) {
                    _loadStatsForMonth(_selectedMonth, _selectedYear);
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.expense.withValues(alpha: 0.1),
                        child: Icon(
                          CategoryIconHelper.getIcon(categoryName, categoryIcon),
                          size: 20,
                          color: AppTheme.expense,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              merchant,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${dateFormat.format(date)} • $paymentMethod',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '-${_formatCurrency(amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.expense,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAllTransactionsSection(
    BuildContext context, {
    required List<dynamic> allTransactionsList,
    required String monthName,
    required int year,
  }) {
    final dateFormat = DateFormat('dd MMM, hh:mm a');

    // Filter list
    final filteredList = allTransactionsList.where((tx) {
      final type = (tx['type'] as String? ?? 'expense').toLowerCase();
      if (_txFilter == 'expense') return type == 'expense';
      if (_txFilter == 'income') return type == 'income';
      return true;
    }).toList();

    final expensesCount = allTransactionsList
        .where((t) => (t['type'] as String? ?? 'expense').toLowerCase() == 'expense')
        .length;
    final incomeCount = allTransactionsList
        .where((t) => (t['type'] as String? ?? '').toLowerCase() == 'income')
        .length;

    final displayedList = _showAllTxList ? filteredList : filteredList.take(10).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.list_alt_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'All $monthName Transactions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${allTransactionsList.length} total',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Itemized list strictly belonging to $monthName $year calendar period.',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),

          // Filter Segmented Chips
          Row(
            children: [
              _buildFilterChip('all', 'All (${allTransactionsList.length})'),
              const SizedBox(width: 8),
              _buildFilterChip('expense', 'Expenses ($expensesCount)'),
              const SizedBox(width: 8),
              _buildFilterChip('income', 'Income ($incomeCount)'),
            ],
          ),
          const SizedBox(height: 16),

          if (filteredList.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No ${_txFilter == "expense" ? "expenses" : _txFilter == "income" ? "incomes" : "transactions"} found for $monthName $year.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            )
          else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayedList.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final tx = displayedList[index];
                final merchant = tx['merchant'] as String? ?? 'Transaction';
                final amount = (tx['amount'] as num).toDouble();
                final date = tx['date'] as DateTime;
                final categoryName = tx['categoryName'] as String?;
                final categoryIcon = tx['categoryIcon'] as String?;
                final paymentMethod = tx['paymentMethod'] as String? ?? 'Cash';
                final type = (tx['type'] as String? ?? 'expense').toLowerCase();
                final isExpense = type == 'expense';

                final color = isExpense ? AppTheme.expense : AppTheme.income;

                return InkWell(
                  onTap: () {
                    final entity = TransactionEntity(
                      id: tx['id'] as int,
                      amount: amount,
                      type: tx['type'] as String? ?? 'Expense',
                      merchant: tx['merchant'] as String?,
                      categoryId: tx['categoryId'] as int?,
                      paymentMethod: tx['paymentMethod'] as String?,
                      accountId: (tx['accountId'] as int?) ?? 1,
                      targetAccountId: tx['targetAccountId'] as int?,
                      availableBalance: (tx['availableBalance'] as num?)?.toDouble(),
                      transactionDate: date,
                      notes: tx['notes'] as String?,
                      originalSms: tx['originalSms'] as String?,
                      bankTransactionId: tx['bankTransactionId'] as String?,
                      receiptAttachment: tx['receiptAttachment'] as String?,
                    );
                    context.push('/add-transaction', extra: entity).then((_) {
                      _loadStatsForMonth(_selectedMonth, _selectedYear);
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: color.withValues(alpha: 0.1),
                          child: Icon(
                            isExpense
                                ? CategoryIconHelper.getIcon(categoryName, categoryIcon)
                                : Icons.arrow_downward_rounded,
                            size: 18,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                merchant,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    dateFormat.format(date),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      paymentMethod,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${isExpense ? "-" : "+"}${_formatCurrency(amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            if (filteredList.length > 10) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showAllTxList = !_showAllTxList;
                    });
                  },
                  icon: Icon(_showAllTxList ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                  label: Text(
                    _showAllTxList
                        ? 'Show Top 10 Only'
                        : 'Show All ${filteredList.length} Transactions',
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _txFilter == key;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => setState(() => _txFilter = key),
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
