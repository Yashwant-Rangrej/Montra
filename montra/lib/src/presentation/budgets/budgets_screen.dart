import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildBudgetCard('Shopping', 120, 1000, AppTheme.primary),
          const SizedBox(height: 16),
          _buildBudgetCard('Transportation', 350, 700, AppTheme.transfer),
          const SizedBox(height: 16),
          _buildBudgetCard('Food & Dining', 800, 1000, AppTheme.expense),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBudgetCard(String title, double spent, double total, Color color) {
    final double percentage = (spent / total).clamp(0.0, 1.0);
    final bool isOverBudget = spent > total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.2),
                    radius: 12,
                    child: CircleAvatar(backgroundColor: color, radius: 6),
                  ),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              if (isOverBudget)
                const Icon(Icons.warning, color: AppTheme.error, size: 20)
            ],
          ),
          const SizedBox(height: 16),
          Text('\$${spent.toStringAsFixed(0)} spent of \$${total.toStringAsFixed(0)}',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 12,
              backgroundColor: AppTheme.background,
              valueColor: AlwaysStoppedAnimation<Color>(isOverBudget ? AppTheme.error : color),
            ),
          )
        ],
      ),
    );
  }
}
