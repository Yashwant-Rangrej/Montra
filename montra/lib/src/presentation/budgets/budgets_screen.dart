import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/budgets_provider.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsProgressAsync = ref.watch(budgetsProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
      ),
      body: budgetsProgressAsync.when(
        data: (budgets) {
          if (budgets.isEmpty) {
            return const Center(child: Text('No budgets found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final bp = budgets[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildBudgetCard(
                  bp.category?.name ?? 'Overall',
                  bp.spentAmount,
                  bp.budget.amount,
                  bp.category?.color != null ? Color(int.parse(bp.category!.color!.replaceFirst('#', '0xFF'))) : AppTheme.primary,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-budget');
        },
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
            color: Colors.black.withValues(alpha: 0.05),
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
