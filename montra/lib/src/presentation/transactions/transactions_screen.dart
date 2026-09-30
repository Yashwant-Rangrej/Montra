import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/transactions_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/transaction_entity.dart';
import '../widgets/empty_state_widget.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  Future<void> _exportToCSV(BuildContext context, List<TransactionEntity> transactions) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/montra_transactions.csv');
      
      String csvData = 'ID,Amount,Type,Date,Notes,Merchant,CategoryID,AccountID\n';
      for (var tx in transactions) {
        csvData += '${tx.id},${tx.amount},${tx.type},${tx.transactionDate.toIso8601String()},"${tx.notes ?? ''}","${tx.merchant ?? ''}",${tx.categoryId ?? ''},${tx.accountId}\n';
      }
      
      await file.writeAsString(csvData);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported to ${file.path}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(filteredTransactionsProvider);
    final allTransactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export CSV',
            onPressed: () {
              final txs = allTransactionsAsync.valueOrNull;
              if (txs != null && txs.isNotEmpty) {
                _exportToCSV(context, txs);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No transactions to export')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search merchant, note, category...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(transactionsProvider);
              },
              child: transactionsAsync.when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.receipt_long_outlined,
                      title: 'No Transactions Found',
                      message: 'We could not find any transactions matching your search criteria.',
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          onTap: () => context.push('/add-transaction', extra: tx),
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.expense.withValues(alpha: 0.1),
                            child: Icon(
                              Icons.shopping_bag,
                              color: AppTheme.expense,
                            ),
                          ),
                          title: Text(tx.merchant ?? tx.notes ?? 'Transaction', style: Theme.of(context).textTheme.titleMedium),
                          subtitle: Text('${tx.type} • ${tx.transactionDate.day}/${tx.transactionDate.month}/${tx.transactionDate.year}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          trailing: Text(
                            '-₹${tx.amount.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.expense,
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
          ),
        ],
      ),
    );
  }
}
