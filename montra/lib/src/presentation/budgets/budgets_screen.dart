import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/budgets_provider.dart';
import '../widgets/empty_state_widget.dart';

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
            return EmptyStateWidget(
              icon: Icons.pie_chart_outline,
              title: 'No Budgets Created',
              message: 'Create budgets for different categories to start tracking your spending.',
              buttonText: 'Create Budget',
              onButtonPressed: () => context.push('/add-budget'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final bp = budgets[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: GestureDetector(
                  onTap: () => context.push('/add-budget', extra: bp.budget),
                  child: _buildBudgetCard(
                    context,
                    bp.category?.name ?? 'Overall',
                    bp.spentAmount,
                    bp.budget.amount,
                    bp.category?.color != null ? Color(int.parse(bp.category!.color!.replaceFirst('#', '0xFF'))) : Theme.of(context).colorScheme.primary,
                  ),
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

  Widget _buildBudgetCard(BuildContext context, String title, double spent, double total, Color color) {
    final double percentage = (spent / total).clamp(0.0, 1.0);
    final bool isOverBudget = spent > total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).cardTheme.shadowColor ?? Colors.black.withValues(alpha: 0.05),
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
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              if (isOverBudget)
                Icon(Icons.warning, color: Theme.of(context).colorScheme.error, size: 20)
            ],
          ),
          const SizedBox(height: 16),
          Text('₹${spent.toStringAsFixed(0)} spent of ₹${total.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 12,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(isOverBudget ? Theme.of(context).colorScheme.error : color),
            ),
          )
        ],
      ),
    );
  }
}
