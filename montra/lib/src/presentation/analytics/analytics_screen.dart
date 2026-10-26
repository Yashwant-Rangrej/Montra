import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/transactions_provider.dart';
import '../../providers/categories_provider.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/empty_state_widget.dart';
import '../../domain/entities/transaction_entity.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  // null = all-time / overall view; 0 = Today, 1 = Yesterday, ..., 6 = 6 days ago
  int? _selectedDaysAgo;
  DateTime _lastTouchTime = DateTime.fromMillisecondsSinceEpoch(0);

  void _onBarTapped(int daysAgo) {
    setState(() {
      if (_selectedDaysAgo == daysAgo) {
        _selectedDaysAgo = null;
      } else {
        _selectedDaysAgo = daysAgo;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final intelligenceAsync = ref.watch(merchantIntelligenceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: Column(
        children: [
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                final filtered = transactions
                    .where((t) => t.type.toLowerCase() == 'expense')
                    .toList();

                if (filtered.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.analytics_outlined,
                    title: 'No Data Available',
                    message: 'There are no expense transactions to analyze yet.',
                  );
                }

                return categoriesAsync.when(
                  data: (categories) {
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);

                    // Daily sums for the 7-day window (0 = Today, ..., 6 = 6 days ago)
                    final Map<int, double> dailySums = {
                      for (var i = 0; i < 7; i++) i: 0.0,
                    };

                    for (var t in filtered) {
                      final txLocal = t.transactionDate.toLocal();
                      final txDay =
                          DateTime(txLocal.year, txLocal.month, txLocal.day);
                      final daysDifference = today.difference(txDay).inDays;
                      if (daysDifference >= 0 && daysDifference < 7) {
                        dailySums[daysDifference] =
                            (dailySums[daysDifference] ?? 0.0) + t.amount;
                      }
                    }

                    // Target transactions based on whether a specific day's bar is selected
                    final List<TransactionEntity> displayExpenses =
                        _selectedDaysAgo != null
                            ? filtered.where((t) {
                                final txLocal = t.transactionDate.toLocal();
                                final txDay = DateTime(
                                    txLocal.year, txLocal.month, txLocal.day);
                                return today.difference(txDay).inDays ==
                                    _selectedDaysAgo;
                              }).toList()
                            : filtered;

                    // Group by category ID for the target transactions
                    final Map<int, double> displayCategorySums = {};
                    double displayTotal = 0.0;

                    for (var t in displayExpenses) {
                      final catId = t.categoryId ?? 0;
                      displayCategorySums[catId] =
                          (displayCategorySums[catId] ?? 0.0) + t.amount;
                      displayTotal += t.amount;
                    }

                    // Maximum sum for vertical scaling of the bar chart
                    final maxDailySum = dailySums.values
                        .fold<double>(0.0, (m, v) => v > m ? v : m);
                    final chartMaxY =
                        maxDailySum > 0 ? maxDailySum * 1.25 : 100.0;

                    // Day label when a day is selected
                    String dayTitle = '';
                    if (_selectedDaysAgo != null) {
                      final selectedDate =
                          today.subtract(Duration(days: _selectedDaysAgo!));
                      if (_selectedDaysAgo == 0) {
                        dayTitle = 'Today';
                      } else if (_selectedDaysAgo == 1) {
                        dayTitle = 'Yesterday';
                      } else {
                        dayTitle = DateFormat('EEE, MMM d').format(selectedDate);
                      }
                    }

                    // Colors palette for pie chart slices
                    final colors = [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.tertiary,
                      Theme.of(context).colorScheme.secondary,
                      Theme.of(context).colorScheme.error,
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.secondaryContainer,
                      Theme.of(context).colorScheme.tertiaryContainer,
                    ];

                    // Generate PieChart sections
                    final List<PieChartSectionData> pieSections = [];
                    int colorIndex = 0;
                    final List<Widget> legendWidgets = [];

                    displayCategorySums.forEach((catId, sum) {
                      if (sum <= 0) return;
                      final category =
                          categories.where((c) => c.id == catId).firstOrNull;
                      final catName = category?.name ?? 'Uncategorized';
                      final color = colors[colorIndex % colors.length];
                      colorIndex++;
                      final percentage =
                          displayTotal > 0 ? (sum / displayTotal) * 100 : 0.0;

                      pieSections.add(
                        PieChartSectionData(
                          color: color,
                          value: sum,
                          title: '${percentage.toStringAsFixed(1)}%',
                          showTitle: true,
                          titlePositionPercentageOffset:
                              percentage < 5 ? 1.4 : 0.5,
                          radius: 50,
                          titleStyle: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color: percentage < 5
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      );

                      legendWidgets.add(
                        ListTile(
                          leading:
                              CircleAvatar(backgroundColor: color, radius: 10),
                          title: Text(catName),
                          trailing: Text(
                            '₹${sum.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      );
                    });

                    // Build 7 bar groups: x = 0 (6 days ago) to x = 6 (Today)
                    final barGroups = <BarChartGroupData>[];
                    for (var x = 0; x < 7; x++) {
                      final daysAgo = 6 - x;
                      final isSelected = _selectedDaysAgo == daysAgo;
                      final rodValue = dailySums[daysAgo] ?? 0.0;

                      barGroups.add(
                        BarChartGroupData(
                          x: x,
                          barRods: [
                            BarChartRodData(
                              toY: rodValue,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : (_selectedDaysAgo != null
                                      ? AppTheme.expense
                                          .withValues(alpha: 0.35)
                                      : AppTheme.expense),
                              width: 22,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: chartMaxY,
                                color: isSelected
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.15)
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.04),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView(
                      padding: const EdgeInsets.all(24.0),
                      children: [
                        intelligenceAsync.when(
                          data: (intelligence) {
                            return Card(
                              color: AppTheme.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Merchant Intelligence',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary)),
                                    const SizedBox(height: 16),
                                    Text(
                                        'Most Visited: ${intelligence['mostFrequentMerchant']} (${intelligence['maxVisits']} visits)',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary)),
                                    const SizedBox(height: 8),
                                    Text(
                                        'Highest Spend: ${intelligence['topSpendingMerchant']} (₹${intelligence['maxSpent'].toStringAsFixed(2)})',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary)),
                                  ],
                                ),
                              ),
                            );
                          },
                          loading: () => const SizedBox(),
                          error: (err, stack) => const SizedBox(),
                        ),
                        const SizedBox(height: 32),
                        Text('Weekly Trend (Last 7 Days)',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: chartMaxY,
                              barTouchData: BarTouchData(
                                enabled: true,
                                handleBuiltInTouches: true,
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipColor: (group) => Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  tooltipPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  tooltipBorderRadius: BorderRadius.circular(8),
                                  getTooltipItem:
                                      (group, groupIndex, rod, rodIndex) {
                                    final daysAgo = 6 - group.x;
                                    final date = today
                                        .subtract(Duration(days: daysAgo));
                                    final dateStr = daysAgo == 0
                                        ? 'Today'
                                        : DateFormat('EEE, MMM d').format(date);
                                    final sum = dailySums[daysAgo] ?? 0.0;
                                    return BarTooltipItem(
                                      '$dateStr\n₹${sum.toStringAsFixed(2)}',
                                      TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                ),
                                touchCallback: (FlTouchEvent event,
                                    BarTouchResponse? touchResponse) {
                                  if (event is! FlTapDownEvent &&
                                      event is! FlTapUpEvent) {
                                    return;
                                  }
                                  if (touchResponse?.spot == null) {
                                    return;
                                  }
                                  final nowTime = DateTime.now();
                                  if (nowTime
                                          .difference(_lastTouchTime)
                                          .inMilliseconds <
                                      250) {
                                    return;
                                  }
                                  _lastTouchTime = nowTime;

                                  final touchedX =
                                      touchResponse!.spot!.touchedBarGroup.x;
                                  final tappedDaysAgo = 6 - touchedX;
                                  _onBarTapped(tappedDaysAgo);
                                },
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 32,
                                    getTitlesWidget: (value, meta) {
                                      final x = value.toInt();
                                      if (x < 0 || x > 6) {
                                        return const SizedBox();
                                      }
                                      final daysAgo = 6 - x;
                                      final date = today
                                          .subtract(Duration(days: daysAgo));
                                      final weekDay = [
                                        'M',
                                        'T',
                                        'W',
                                        'T',
                                        'F',
                                        'S',
                                        'S'
                                      ][date.weekday - 1];
                                      final isSelected =
                                          _selectedDaysAgo == daysAgo;
                                      final label =
                                          daysAgo == 0 ? 'Today' : weekDay;

                                      return GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => _onBarTapped(daysAgo),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            label,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
                                                  color: isSelected
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: barGroups,
                            ),
                          ),
                        ),

                        // Selected Day Expense Banner
                        if (_selectedDaysAgo != null) ...[
                          const SizedBox(height: 16),
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.25),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.calendar_today_rounded,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$dayTitle Expense',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '₹${displayTotal.toStringAsFixed(2)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.expense,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _selectedDaysAgo = null;
                                      });
                                    },
                                    icon: const Icon(Icons.close_rounded,
                                        size: 18),
                                    label: const Text('Show All'),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),
                        Text(
                          _selectedDaysAgo != null
                              ? 'Category Breakdown ($dayTitle)'
                              : 'Category Breakdown',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        if (pieSections.isNotEmpty)
                          SizedBox(
                            height: 250,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 60,
                                sections: pieSections,
                              ),
                            ),
                          )
                        else
                          Container(
                            height: 140,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.pie_chart_outline_rounded,
                                  size: 40,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _selectedDaysAgo != null
                                      ? 'No expenses recorded on $dayTitle.'
                                      : 'No expenses recorded.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 32),
                        Text(
                          _selectedDaysAgo != null
                              ? 'Category Legends ($dayTitle)'
                              : 'Category Legends',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        if (legendWidgets.isNotEmpty)
                          ...legendWidgets
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'No categories to display.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ),

                        // List of that day's individual transactions
                        if (_selectedDaysAgo != null &&
                            displayExpenses.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          Text(
                            'Transactions ($dayTitle)',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ...displayExpenses.map((tx) {
                            final cat = categories
                                .where((c) => c.id == tx.categoryId)
                                .firstOrNull;
                            final txTime = DateFormat('hh:mm a')
                                .format(tx.transactionDate.toLocal());
                            final title = (tx.merchant != null &&
                                    tx.merchant!.trim().isNotEmpty)
                                ? tx.merchant!
                                : (tx.notes != null &&
                                        tx.notes!.trim().isNotEmpty
                                    ? tx.notes!
                                    : (cat?.name ?? 'Expense'));

                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 8.0),
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.expense
                                      .withValues(alpha: 0.12),
                                  child: const Icon(Icons.arrow_upward_rounded,
                                      color: AppTheme.expense, size: 20),
                                ),
                                title: Text(title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                  '${cat?.name ?? 'Uncategorized'} • $txTime',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                                trailing: Text(
                                  '-₹${tx.amount.toStringAsFixed(2)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: AppTheme.expense,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
