import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/sms_providers.dart';
import '../../providers/repository_providers.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/category_icon_helper.dart';
import '../widgets/empty_state_widget.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/services.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkAndRequestSmsPermission();
      // Refresh transactions when screen first loads
      ref.invalidate(transactionsProvider);

      // Listen for background SMS processing notifications
      const MethodChannel bgChannel = MethodChannel(
        'com.montra.app/sms_background',
      );
      bgChannel.setMethodCallHandler((call) async {
        if (call.method == 'smsProcessed') {
          // Refresh transactions when a new SMS is processed
          ref.invalidate(transactionsProvider);
        }
        return null;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh transactions when returning to the app
      ref.invalidate(transactionsProvider);
    }
  }

  Future<void> _checkAndRequestSmsPermission() async {
    final status = await Permission.sms.status;
    if (status.isDenied) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('SMS Access Required'),
            content: const Text(
              'Montra needs access to your SMS messages to automatically track your expenses and income directly from bank notifications. We value your privacy and this data never leaves your device.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Later'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final result = await Permission.sms.request();
                  if (result.isGranted) {
                    ref.read(smsInterceptorProvider).initialize();
                  }
                },
                child: const Text('Grant Access'),
              ),
            ],
          ),
        );
      }
    } else if (status.isGranted) {
      ref.read(smsInterceptorProvider).initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final transactionsAsync = ref.watch(transactionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(transactionsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildBalanceCard(statsAsync),
              const SizedBox(height: 32),
              _buildRecentTransactions(transactionsAsync, categoriesAsync),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,';
    } else if (hour < 17) {
      return 'Good Afternoon,';
    } else {
      return 'Good Evening,';
    }
  }

  void _editUserName(String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter your name'),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(usernameProvider.notifier).updateName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showProfileModal() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.5),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, child) {
                  final name = ref.watch(usernameProvider);
                  return Text(
                    name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  );
                },
              ),
              const SizedBox(height: 32),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Profile Name'),
                onTap: () {
                  Navigator.pop(context);
                  _editUserName(ref.read(usernameProvider));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final userName = ref.watch(usernameProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(userName, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
        GestureDetector(
          onTap: _showProfileModal,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(AsyncValue<Map<String, double>> statsAsync) {
    return statsAsync.when(
      data: (stats) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Today',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSecondary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              _buildIncomeExpenseStat(
                'Total Expenses',
                stats['todayExpense'] ?? 0.0,
                false,
              ),
              const SizedBox(height: 16),
              Divider(
                color: Theme.of(
                  context,
                ).colorScheme.onSecondary.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              Text(
                'This Month',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSecondary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              _buildIncomeExpenseStat(
                'Total Expenses',
                stats['monthlyExpense'] ?? 0.0,
                false,
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Error: $err'),
    );
  }

  Widget _buildIncomeExpenseStat(String title, double amount, bool isIncome) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.onSecondary.withValues(alpha: 0.1),
          radius: 20,
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? Colors.white : AppTheme.expense,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSecondary.withValues(alpha: 0.7),
              ),
            ),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCategorySelection(BuildContext context, WidgetRef ref, TransactionEntity tx) {
    final categoriesAsync = ref.read(categoriesProvider);
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                    child: Text(
                      'Select Category for ${tx.merchant ?? "Transaction"}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final iconData = CategoryIconHelper.getIcon(cat.name, cat.icon);
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.2),
                            child: Icon(iconData, color: Theme.of(context).colorScheme.primary),
                          ),
                          title: Text(cat.name),
                          onTap: () async {
                            final updatedTx = tx.copyWith(categoryId: cat.id);
                            await ref.read(transactionRepositoryProvider).updateTransaction(updatedTx);
                            ref.invalidate(transactionsProvider);
                            if (context.mounted) Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, s) => Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text('Error: $e'),
            ),
          ),
        );
      },
    );
  }

  void _showLongPressMenu(BuildContext context, TransactionEntity tx) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            tx.type == 'Ignored'
                ? ListTile(
                    leading: const Icon(Icons.restore),
                    title: const Text('Restore this transaction'),
                    subtitle: const Text('It will be counted in your stats again'),
                    onTap: () async {
                      final updatedTx = tx.copyWith(type: 'Expense');
                      await ref.read(transactionRepositoryProvider).updateTransaction(updatedTx);
                      ref.invalidate(transactionsProvider);
                      if (context.mounted) Navigator.pop(context);
                    },
                  )
                : ListTile(
                    leading: const Icon(Icons.visibility_off),
                    title: const Text('Ignore this transaction'),
                    subtitle: const Text('It will not be counted in your stats'),
                    onTap: () async {
                      final updatedTx = tx.copyWith(type: 'Ignored');
                      await ref.read(transactionRepositoryProvider).updateTransaction(updatedTx);
                      ref.invalidate(transactionsProvider);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('Change Category'),
              subtitle: const Text('Assign or change the category for this transaction'),
              onTap: () {
                Navigator.pop(context);
                _showCategorySelection(context, ref, tx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_calendar_outlined),
              title: const Text('Edit Details & Date'),
              subtitle: const Text('Customize amount, date, time, and category'),
              onTap: () {
                Navigator.pop(context);
                context.push('/add-transaction', extra: tx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete transaction', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Transaction'),
                    content: Text('Are you sure you want to delete ${tx.merchant ?? "this transaction"}?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(transactionRepositoryProvider).deleteTransaction(tx.id);
                  ref.invalidate(transactionsProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transaction deleted')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(
    AsyncValue<List<dynamic>> transactionsAsync,
    AsyncValue<List<dynamic>> categoriesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        transactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.receipt_long_outlined,
                title: 'No Transactions',
                message: 'Your recent transactions will appear here.',
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length > 5 ? 5 : transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                String? catName;
                String? catIcon;
                categoriesAsync.whenData((categories) {
                  final cat = categories
                      .where((c) => c.id == tx.categoryId)
                      .firstOrNull;
                  catName = cat?.name;
                  catIcon = cat?.icon;
                });
                final iconData = CategoryIconHelper.getIcon(catName, catIcon);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onDoubleTap: () => _showCategorySelection(context, ref, tx),
                    onLongPress: () => _showLongPressMenu(context, tx),
                    child: ListTile(
                      onTap: () => context.push('/add-transaction', extra: tx),
                      leading: GestureDetector(
                        onTap: () => _showCategorySelection(context, ref, tx),
                        child: CircleAvatar(
                          backgroundColor: tx.type == 'Ignored'
                              ? Theme.of(context).colorScheme.surfaceContainerHighest
                              : AppTheme.expense.withValues(alpha: 0.1),
                          child: Icon(
                            iconData,
                            color: tx.type == 'Ignored'
                                ? Theme.of(context).colorScheme.outline
                                : AppTheme.expense,
                          ),
                        ),
                      ),
                      title: Text(
                        tx.merchant ?? tx.notes ?? 'Transaction',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          decoration: tx.type == 'Ignored'
                              ? TextDecoration.lineThrough
                              : null,
                          color: tx.type == 'Ignored'
                              ? Theme.of(context).colorScheme.outline
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        '${tx.type} • ${(tx.originalSms != null && (tx.paymentMethod == null || tx.paymentMethod == "Cash")) ? "UPI" : (tx.paymentMethod ?? "Cash")} • ${DateFormat('dd MMM, hh:mm a').format(tx.transactionDate)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Text(
                        '-₹${tx.amount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: tx.type == 'Ignored'
                              ? Theme.of(context).colorScheme.outline
                              : AppTheme.expense,
                          decoration: tx.type == 'Ignored'
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error: $err'),
        ),
      ],
    );
  }
}
