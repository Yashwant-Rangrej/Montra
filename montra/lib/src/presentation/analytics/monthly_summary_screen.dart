import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../providers/repository_providers.dart';
import '../../data/database/database.dart';
import 'package:drift/drift.dart' as drift;

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

  @override
  void initState() {
    super.initState();
    _stats = widget.stats;
    if (_stats == null) {
      _loadStats();
    }
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    // Dynamic import to avoid cyclic dependency if needed, but we can just use the service.
    // Wait, MonthlySummaryService needs NotificationManager, which is a riverpod provider.
    // We can just re-implement the DB query or use the service via ref in a microtask.
    Future.microtask(() async {
      final db = ref.read(databaseProvider);
      // We can just query it directly to avoid needing the service
      int month = DateTime.now().month - 1;
      int year = DateTime.now().year;
      if (month == 0) {
        month = 12;
        year -= 1;
      }

      final allTx = await db.select(db.transactions).get();
      final lastMonthTx = allTx.where((t) =>
        t.transactionDate.year == year &&
        t.transactionDate.month == month &&
        t.type.toLowerCase() == 'expense'
      ).toList();

      if (lastMonthTx.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
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
        final topCatId = byCategory.entries.reduce((a, b) => a.value > b.value ? a : b).key;
        topCategoryAmount = byCategory[topCatId]!;
        final catRow = await (db.select(db.categories)..where((c) => c.id.equals(topCatId))).getSingleOrNull();
        if (catRow != null) topCategory = catRow.name;
      }

      String? topMerchant;
      if (byMerchant.isNotEmpty) {
        topMerchant = byMerchant.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      }

      if (mounted) {
        setState(() {
          _stats = {
            'month': month,
            'year': year,
            'totalExpense': totalExpense,
            'topCategory': topCategory,
            'topCategoryAmount': topCategoryAmount,
            'topMerchant': topMerchant,
            'txCount': lastMonthTx.length,
            'byCategory': byCategory,
          };
          _isLoading = false;
        });
      }
    });
  }

  String _monthName(int month) {
    const names = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[month];
  }

  Future<void> _saveSummary() async {
    if (_stats == null) return;
    
    setState(() => _isSaving = true);
    final db = ref.read(databaseProvider);
    
    try {
      await db.into(db.savedSummaries).insert(
        SavedSummariesCompanion.insert(
          month: _stats!['month'] as int,
          year: _stats!['year'] as int,
          totalExpense: _stats!['totalExpense'] as double,
          topCategory: _stats!['topCategory'] as String,
          topCategoryAmount: _stats!['topCategoryAmount'] as double,
          topMerchant: drift.Value(_stats!['topMerchant'] as String?),
          transactionCount: _stats!['txCount'] as int,
        ),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report saved to database!')),
        );
        context.pop(); // Close the screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save report')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    if (_stats == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Monthly Summary')),
        body: const Center(child: Text('No expenses found for last month.')),
      );
    }
    
    final month = _stats!['month'] as int;
    final year = _stats!['year'] as int;
    final totalExpense = _stats!['totalExpense'] as double;
    final topCategory = _stats!['topCategory'] as String;
    final topCategoryAmount = _stats!['topCategoryAmount'] as double;
    final txCount = _stats!['txCount'] as int;
    final Map<int, double> byCategory = _stats!['byCategory'] as Map<int, double>;

    // Generate PieChart sections
    final List<PieChartSectionData> pieSections = [];
    final colors = [
      Colors.indigo,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.teal,
    ];
    
    int colorIndex = 0;
    for (final entry in byCategory.entries) {
      pieSections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: entry.value,
          title: '${((entry.value / totalExpense) * 100).toStringAsFixed(0)}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${_monthName(month)} $year Summary'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Total Card
            Card(
              elevation: 0,
              color: Colors.indigo.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      'Total Spent',
                      style: TextStyle(fontSize: 16, color: Colors.indigo),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${totalExpense.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$txCount Transactions',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Pie Chart
            if (pieSections.isNotEmpty) ...[
              const Text(
                'Expense Breakdown',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: pieSections,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Top Category Card
            Card(
              elevation: 0,
              color: Colors.orange.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.star, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Highest Spend Category',
                            style: TextStyle(color: Colors.deepOrange),
                          ),
                          Text(
                            topCategory,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${topCategoryAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text('Discard', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _saveSummary,
                    icon: _isSaving 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save),
                    label: const Text('Save Report'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
