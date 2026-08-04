import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/goals_provider.dart';
import '../../core/theme/app_theme.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
      ),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              final progress = goal.targetAmount > 0 ? (goal.savedAmount / goal.targetAmount) : 0.0;
              
              return Card(
                elevation: 0,
                color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(goal.name, style: Theme.of(context).textTheme.titleLarge),
                          Text(
                            '\$${goal.savedAmount.toStringAsFixed(0)} / \$${goal.targetAmount.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        color: Theme.of(context).colorScheme.primary,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}% Completed',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-goal'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flag_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'No Goals Yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.outline),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your savings targets.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.outline),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.push('/add-goal'),
            child: const Text('Create Goal'),
          ),
        ],
      ),
    );
  }
}
