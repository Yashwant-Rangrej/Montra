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
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good Morning,', style: TextStyle(color: Colors.grey, fontSize: 16)),
            Text('Yashwant', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        CircleAvatar(
          backgroundColor: AppTheme.primaryContainer,
          child: Icon(Icons.person, color: AppTheme.primary),
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
            color: AppTheme.secondary,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 8),
              Text('\$${stats['balance']?.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              
              const Text('Today', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIncomeExpenseStat('Income', stats['todayIncome'] ?? 0.0, true),
                  _buildIncomeExpenseStat('Expenses', stats['todayExpense'] ?? 0.0, false),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),
              const Text('This Month', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
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
          backgroundColor: Colors.white24,
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
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            Text('\$${amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(AsyncValue<List<dynamic>> transactionsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Transactions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('See All', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 16),
        transactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No transactions yet', style: TextStyle(color: Colors.grey)),
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
                    backgroundColor: isIncome ? AppTheme.primaryContainer : const Color(0xFFFEE2E2),
                    child: Icon(
                      isIncome ? Icons.attach_money : Icons.shopping_bag,
                      color: isIncome ? AppTheme.income : AppTheme.expense,
                    ),
                  ),
                  title: Text(tx.merchant ?? tx.notes ?? 'Transaction', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(tx.type),
                  trailing: Text(
                    '${isIncome ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
