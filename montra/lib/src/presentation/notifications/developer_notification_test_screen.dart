import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/notifications/notification_manager.dart';

class DeveloperNotificationTestScreen extends ConsumerWidget {
  const DeveloperNotificationTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.read(notificationManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Testing: Notifications'),
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Theme.of(context).colorScheme.onError,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('These buttons trigger native notifications for testing purposes only.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => manager.showDailySummary(
              spentToday: 1240,
              txCount: 5,
              biggestExpense: 'Swiggy (₹450)',
              remainingBudget: 580,
              force: true,
            ),
            child: const Text('Trigger Daily Summary'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => manager.showTransactionDetected(
              merchant: 'Amazon',
              amount: 1240,
              category: 'Shopping',
              force: true,
            ),
            child: const Text('Trigger Transaction Detected'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => manager.showBudgetAlert(
              budgetName: 'Food & Dining',
              used: 850,
              remaining: 150,
              force: true,
            ),
            child: const Text('Trigger Budget Alert'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => manager.showGoalReminder(
              goalName: 'Vacation',
              progress: 75.5,
              remaining: 24500,
              force: true,
            ),
            child: const Text('Trigger Goal Reminder'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => manager.showLargeExpenseAlert(
              merchant: 'Apple Store',
              amount: 125000,
              method: 'Credit Card',
              force: true,
            ),
            child: const Text('Trigger Large Expense Alert'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => manager.showSmartInsight(
              insight: 'You spent 18% less than last week. Great job!',
              force: true,
            ),
            child: const Text('Trigger Smart Insight'),
          ),
        ],
      ),
    );
  }
}
