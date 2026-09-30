import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/repository_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/transaction_entity.dart';
import '../widgets/empty_state_widget.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final Set<int> _selectedIds = {};
  bool _isSelectionMode = false;


  IconData _getIconForCategory(String? categoryName) {
    if (categoryName == null) return Icons.shopping_bag;
    final name = categoryName.toLowerCase();
    if (name.contains('food') || name.contains('dining') || name.contains('restaurant')) return Icons.restaurant;
    if (name.contains('transport') || name.contains('travel') || name.contains('auto') || name.contains('gas') || name.contains('fuel')) return Icons.directions_car;
    if (name.contains('shop') || name.contains('grocery') || name.contains('market') || name.contains('store')) return Icons.shopping_cart;
    if (name.contains('health') || name.contains('medical') || name.contains('pharmacy') || name.contains('doctor')) return Icons.local_hospital;
    if (name.contains('bill') || name.contains('utility') || name.contains('water') || name.contains('electric') || name.contains('internet')) return Icons.receipt_long;
    if (name.contains('enter') || name.contains('movie') || name.contains('game')) return Icons.movie;
    if (name.contains('educat') || name.contains('school') || name.contains('book')) return Icons.school;
    if (name.contains('home') || name.contains('rent')) return Icons.home;
    if (name.contains('salary') || name.contains('income') || name.contains('wage')) return Icons.attach_money;
    if (name.contains('gift') || name.contains('donate')) return Icons.card_giftcard;
    if (name.contains('sport') || name.contains('gym')) return Icons.fitness_center;
    if (name.contains('subscrip')) return Icons.subscriptions;
    return Icons.category;
  }

  void _showCategorySelection(BuildContext context, WidgetRef ref, TransactionEntity tx) {
    final categoriesAsync = ref.read(categoriesProvider);
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return categoriesAsync.when(
          data: (categories) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text('Select Category for ${tx.merchant ?? "Transaction"}', style: Theme.of(context).textTheme.titleLarge),
                  ),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final iconData = _getIconForCategory(cat.name);
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                            child: Icon(iconData, color: Theme.of(context).colorScheme.primary),
                          ),
                          title: Text(cat.name),
                          onTap: () async {
                            final updatedTx = TransactionEntity(
                              id: tx.id,
                              amount: tx.amount,
                              type: tx.type,
                              merchant: tx.merchant,
                              categoryId: cat.id,
                              paymentMethod: tx.paymentMethod,
                              accountId: tx.accountId,
                              targetAccountId: tx.targetAccountId,
                              availableBalance: tx.availableBalance,
                              transactionDate: tx.transactionDate,
                              notes: tx.notes,
                              originalSms: tx.originalSms,
                              bankTransactionId: tx.bankTransactionId,
                              receiptAttachment: tx.receiptAttachment,
                            );
                            await ref.read(transactionRepositoryProvider).updateTransaction(updatedTx);
                            ref.invalidate(transactionsProvider);
                            if (context.mounted) Navigator.pop(context);
                          },
                        );
                      }
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator())),
          error: (e, s) => Center(child: Padding(padding: const EdgeInsets.all(24.0), child: Text('Error: $e'))),
        );
      }
    );
  }

  void _showLongPressMenu(BuildContext context, TransactionEntity tx) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility_off),
              title: const Text('Ignore this transaction'),
              subtitle: const Text('It will not be counted in your stats'),
              onTap: () async {
                final updatedTx = TransactionEntity(
                  id: tx.id,
                  amount: tx.amount,
                  type: 'Ignored', // Setting type to Ignored will remove it from expense calculations
                  merchant: tx.merchant,
                  categoryId: tx.categoryId,
                  paymentMethod: tx.paymentMethod,
                  accountId: tx.accountId,
                  targetAccountId: tx.targetAccountId,
                  availableBalance: tx.availableBalance,
                  transactionDate: tx.transactionDate,
                  notes: tx.notes,
                  originalSms: tx.originalSms,
                  bankTransactionId: tx.bankTransactionId,
                  receiptAttachment: tx.receiptAttachment,
                );
                await ref.read(transactionRepositoryProvider).updateTransaction(updatedTx);
                ref.invalidate(transactionsProvider);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete transaction(s)'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _isSelectionMode = true;
                  _selectedIds.add(tx.id);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(filteredTransactionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: _isSelectionMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSelectionMode = false;
                    _selectedIds.clear();
                  });
                },
              ),
              title: Text('${_selectedIds.length} Selected'),
              actions: [
                if (_selectedIds.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final repo = ref.read(transactionRepositoryProvider);
                      for (final id in _selectedIds) {
                        await repo.deleteTransaction(id);
                      }
                      ref.invalidate(transactionsProvider);
                      setState(() {
                        _isSelectionMode = false;
                        _selectedIds.clear();
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transactions deleted')));
                      }
                    },
                  ),
              ],
            )
          : AppBar(
              title: const Text('Transactions'),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 8.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  useRootNavigator: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) {
                    return SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Monthly Expenses', style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 16),
                            Consumer(
                              builder: (context, ref, child) {
                                final monthlyStats = ref.watch(monthlyExpensesProvider);
                                return monthlyStats.when(
                                  data: (stats) {
                                    if (stats.isEmpty) {
                                      return const Center(child: Text('No expenses recorded.'));
                                    }
                                    return Flexible(
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        itemCount: stats.length,
                                        separatorBuilder: (context, index) => const Divider(height: 1),
                                        itemBuilder: (context, index) {
                                          final key = stats.keys.elementAt(index);
                                          final amount = stats[key]!;
                                          final parts = key.split('-');
                                          
                                          // Format month/year
                                          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                                          final monthIndex = int.parse(parts[1]) - 1;
                                          final monthName = months[monthIndex];
                                          final year = parts[0];

                                          return ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: CircleAvatar(
                                              backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
                                              child: Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.primary),
                                            ),
                                            title: Text('$monthName $year', style: Theme.of(context).textTheme.titleMedium),
                                            trailing: Text('₹${amount.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.expense, fontWeight: FontWeight.bold)),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  loading: () => const Center(child: CircularProgressIndicator()),
                                  error: (_, _) => const Center(child: Text('Error loading data')),
                                );
                              }
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.history, color: Theme.of(context).colorScheme.onSecondaryContainer, size: 20),
                        const SizedBox(width: 8),
                        Text('View Monthly Expense History', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer)),
                      ],
                    ),
                    Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSecondaryContainer),
                  ],
                ),
              ),
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
                      String? catName;
                      categoriesAsync.whenData((categories) {
                        catName = categories.where((c) => c.id == tx.categoryId).firstOrNull?.name;
                      });
                      final iconData = _getIconForCategory(catName);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onDoubleTap: _isSelectionMode ? null : () => _showCategorySelection(context, ref, tx),
                          onLongPress: _isSelectionMode ? null : () => _showLongPressMenu(context, tx),
                          child: ListTile(
                            onTap: () {
                              if (_isSelectionMode) {
                                setState(() {
                                  if (_selectedIds.contains(tx.id)) {
                                    _selectedIds.remove(tx.id);
                                    if (_selectedIds.isEmpty) _isSelectionMode = false;
                                  } else {
                                    _selectedIds.add(tx.id);
                                  }
                                });
                              } else {
                                context.push('/add-transaction', extra: tx);
                              }
                            },
                            leading: CircleAvatar(
                              backgroundColor: tx.type == 'Ignored' ? Theme.of(context).colorScheme.surfaceContainerHighest : AppTheme.expense.withValues(alpha: 0.1),
                              child: Icon(
                                iconData,
                                color: tx.type == 'Ignored' ? Theme.of(context).colorScheme.outline : AppTheme.expense,
                              ),
                            ),
                            title: Text(
                              tx.merchant ?? tx.notes ?? 'Transaction',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                decoration: tx.type == 'Ignored' ? TextDecoration.lineThrough : null,
                                color: tx.type == 'Ignored' ? Theme.of(context).colorScheme.outline : null,
                              )
                            ),
                            subtitle: Text('${tx.type} • ${tx.transactionDate.day}/${tx.transactionDate.month}/${tx.transactionDate.year}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            trailing: _isSelectionMode
                              ? Checkbox(
                                  value: _selectedIds.contains(tx.id),
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        _selectedIds.add(tx.id);
                                      } else {
                                        _selectedIds.remove(tx.id);
                                        if (_selectedIds.isEmpty) _isSelectionMode = false;
                                      }
                                    });
                                  },
                                )
                              : Text(
                                  '-₹${tx.amount.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: tx.type == 'Ignored' ? Theme.of(context).colorScheme.outline : AppTheme.expense,
                                    decoration: tx.type == 'Ignored' ? TextDecoration.lineThrough : null,
                                  ),
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
