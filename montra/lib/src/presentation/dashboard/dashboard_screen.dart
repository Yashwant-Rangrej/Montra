import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/repository_providers.dart';
import '../../providers/sms_providers.dart';
import '../../core/theme/app_theme.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestSmsPermission();
    });
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
                'Montra needs access to your SMS messages to automatically track your expenses and income directly from bank notifications. We value your privacy and this data never leaves your device.'),
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
              _buildRecentTransactions(transactionsAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good Morning,', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            Text('Yashwant', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
        CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
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
              Text('Total Balance', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.7))),
              const SizedBox(height: 8),
              Text('\$${stats['balance']?.toStringAsFixed(2)}', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Theme.of(context).colorScheme.onSecondary)),
              const SizedBox(height: 32),
              
              Text('Today', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.7))),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIncomeExpenseStat('Income', stats['todayIncome'] ?? 0.0, true),
                  _buildIncomeExpenseStat('Expenses', stats['todayExpense'] ?? 0.0, false),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              Text('This Month', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.7))),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIncomeExpenseStat('Income', stats['monthlyIncome'] ?? 0.0, true),
                  _buildIncomeExpenseStat('Expenses', stats['monthlyExpense'] ?? 0.0, false),
                ],
              )
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
          backgroundColor: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.1),
          radius: 20,
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? AppTheme.income : AppTheme.expense,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.7))),
            Text('\$${amount.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(AsyncValue<List<dynamic>> transactionsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Transactions', style: Theme.of(context).textTheme.titleLarge),
            Text('See All', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
          ],
        ),
        const SizedBox(height: 16),
        transactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text('No transactions yet', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length > 5 ? 5 : transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final isIncome = tx.type == 'Income';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: isIncome ? AppTheme.income.withValues(alpha: 0.1) : AppTheme.expense.withValues(alpha: 0.1),
                    child: Icon(
                      isIncome ? Icons.attach_money : Icons.shopping_bag,
                      color: isIncome ? AppTheme.income : AppTheme.expense,
                    ),
                  ),
                  title: Text(tx.merchant ?? tx.notes ?? 'Transaction', style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text(tx.type, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  trailing: Text(
                    '${isIncome ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isIncome ? AppTheme.income : AppTheme.expense,
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error: $err'),
        )
      ],
    );
  }
}
