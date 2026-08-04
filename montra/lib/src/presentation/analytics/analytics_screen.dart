import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/transactions_provider.dart';
import '../../providers/categories_provider.dart';
import '../../core/theme/app_theme.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _selectedType = 'Expense'; // 'Income' or 'Expense'

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Expense', label: Text('Expense')),
                ButtonSegment(value: 'Income', label: Text('Income')),
              ],
              selected: {_selectedType},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedType = newSelection.first;
                });
              },
            ),
          ),
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                final filtered = transactions.where((t) => t.type == _selectedType).toList();
                
                if (filtered.isEmpty) {
                  return Center(child: Text('No $_selectedType data for analytics.'));
                }

                return categoriesAsync.when(
                  data: (categories) {
                    // Group by category ID
                    final Map<int, double> categorySums = {};
                    double totalAmount = 0;
                    for (var t in filtered) {
                      final catId = t.categoryId ?? 0; // 0 for uncategorized
                      categorySums[catId] = (categorySums[catId] ?? 0) + t.amount;
                      totalAmount += t.amount;
                    }

                    if (totalAmount == 0) return const Center(child: Text('Total is zero.'));

                    // Generate PieChart sections
                    final List<PieChartSectionData> pieSections = [];
                    int colorIndex = 0;
                    final colors = [
                      AppTheme.primary, AppTheme.expense, AppTheme.income, 
                      Colors.orange, Colors.purple, Colors.teal, Colors.amber
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
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        )
                      );

                      legendWidgets.add(
                        ListTile(
                          leading: CircleAvatar(backgroundColor: color, radius: 10),
                          title: Text(catName),
                          trailing: Text('\$${sum.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        )
                      );
                    });

                    return ListView(
                      padding: const EdgeInsets.all(24.0),
                      children: [
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
                        const Text('Category Breakdown', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
