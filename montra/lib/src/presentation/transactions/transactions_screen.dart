import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/transactions_provider.dart';
import '../../core/theme/app_theme.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(transactionsProvider);
        },
        child: transactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return const Center(child: Text('No transactions yet.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final isIncome = tx.type == 'Income';
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isIncome ? AppTheme.primaryContainer : const Color(0xFFFEE2E2),
                      child: Icon(
                        isIncome ? Icons.attach_money : Icons.shopping_bag,
                        color: isIncome ? AppTheme.income : AppTheme.expense,
                      ),
                    ),
                    title: Text(tx.merchant ?? tx.notes ?? 'Transaction', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${tx.type} • ${tx.transactionDate.day}/${tx.transactionDate.month}/${tx.transactionDate.year}'),
                    trailing: Text(
                      '${isIncome ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isIncome ? AppTheme.income : AppTheme.expense,
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}
