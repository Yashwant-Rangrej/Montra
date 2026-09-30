import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/transactions_provider.dart';
import '../../providers/categories_provider.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/empty_state_widget.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
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
                final filtered = transactions.where((t) => t.type == 'Expense').toList();
                
                if (filtered.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.analytics_outlined,
                    title: 'No Data Available',
                    message: 'There are no expense transactions to analyze yet.',
                  );
                }

                return categoriesAsync.when(
                  data: (categories) {
                    // Group by category ID
                    final Map<int, double> categorySums = {};
                    double totalAmount = 0;
                    
                    // Daily sums for last 7 days
                    final Map<int, double> dailySums = {
                      for (var i = 0; i < 7; i++) i: 0.0
                    };
                    
                    final now = DateTime.now();

                    for (var t in filtered) {
                      final catId = t.categoryId ?? 0;
                      categorySums[catId] = (categorySums[catId] ?? 0) + t.amount;
                      totalAmount += t.amount;

                      final daysDifference = now.difference(t.transactionDate).inDays;
                      if (daysDifference >= 0 && daysDifference < 7) {
                        dailySums[daysDifference] = (dailySums[daysDifference] ?? 0) + t.amount;
                      }
                    }

                    if (totalAmount == 0) return const Center(child: Text('Total is zero.'));

                    // Generate PieChart sections
                    final List<PieChartSectionData> pieSections = [];
                    int colorIndex = 0;
                    final colors = [
                      Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.tertiary, Theme.of(context).colorScheme.secondary, 
                      Theme.of(context).colorScheme.error, Theme.of(context).colorScheme.primaryContainer, Theme.of(context).colorScheme.secondaryContainer, Theme.of(context).colorScheme.tertiaryContainer
                    ];

                    final List<Widget> legendWidgets = [];

                    categorySums.forEach((catId, sum) {
                      final category = categories.where((c) => c.id == catId).firstOrNull;
                      final catName = category?.name ?? 'Uncategorized';
                      final color = colors[colorIndex % colors.length];
                      colorIndex++;
                      final percentage = (sum / totalAmount) * 100;

                      pieSections.add(
                        PieChartSectionData(
                          color: color,
                          value: sum,
                          title: '${percentage.toStringAsFixed(1)}%',
                          showTitle: true,
                          titlePositionPercentageOffset: percentage < 5 ? 1.4 : 0.5,
                          radius: 50,
                          titleStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: percentage < 5 ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      );

                      legendWidgets.add(
                        ListTile(
                          leading: CircleAvatar(backgroundColor: color, radius: 10),
                          title: Text(catName),
                          trailing: Text('₹${sum.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium),
                        )
                      );
                    });

                    return ListView(
                      padding: const EdgeInsets.all(24.0),
                      children: [
                        intelligenceAsync.when(
                          data: (intelligence) {
                            return Card(
                              color: AppTheme.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Merchant Intelligence', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
                                    const SizedBox(height: 16),
                                    Text('Most Visited: ${intelligence['mostFrequentMerchant']} (${intelligence['maxVisits']} visits)', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
                                    const SizedBox(height: 8),
                                    Text('Highest Spend: ${intelligence['topSpendingMerchant']} (₹${intelligence['maxSpent'].toStringAsFixed(2)})', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
                                  ],
                                ),
                              ),
                            );
                          },
                          loading: () => const SizedBox(),
                          error: (err, stack) => const SizedBox(),
                        ),
                        const SizedBox(height: 32),
                        Text('Weekly Trend (Last 7 Days)', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final daysAgo = value.toInt();
                                      if (daysAgo < 0 || daysAgo > 6) return const SizedBox();
                                      final date = now.subtract(Duration(days: daysAgo));
                                      final weekDay = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][date.weekday - 1];
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(daysAgo == 0 ? 'Today' : weekDay, style: Theme.of(context).textTheme.labelSmall),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: [
                                for (var i = 6; i >= 0; i--)
                                  BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: dailySums[i] ?? 0,
                                        color: AppTheme.expense,
                                        width: 16,
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text('Category Breakdown', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 250,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 60,
                              sections: pieSections,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text('Category Legends', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 16),
                        ...legendWidgets,
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
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
