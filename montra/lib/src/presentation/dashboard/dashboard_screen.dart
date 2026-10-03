import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/sms_providers.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/empty_state_widget.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/services.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with WidgetsBindingObserver {
  bool _isBalanceVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkAndRequestSmsPermission();
      // Refresh transactions when screen first loads
      ref.invalidate(transactionsProvider);

      // Listen for background SMS processing notifications
      const MethodChannel bgChannel = MethodChannel('com.montra.app/sms_background');
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

  void _handleBalanceTap() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
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
          decoration: const InputDecoration(
            hintText: 'Enter your name',
          ),
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
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(Icons.person, size: 40, color: Theme.of(context).colorScheme.primary),
                ),
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, child) {
                  final name = ref.watch(usernameProvider);
                  return Text(name, style: Theme.of(context).textTheme.headlineSmall);
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
            Text(_getGreeting(), style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            Text(userName, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
        GestureDetector(
          onTap: _showProfileModal,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
            ),
          ),
        )
      ],
    );
  }


  Widget _buildBalanceCard(AsyncValue<Map<String, double>> statsAsync) {
    return statsAsync.when(
      data: (stats) {
        return GestureDetector(
          onTap: _handleBalanceTap,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_isBalanceVisible) ...[
                  Text('Total Spend', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.7))),
                  const SizedBox(height: 8),
                  Text('₹${stats['balance']?.toStringAsFixed(2)}', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Theme.of(context).colorScheme.onSecondary)),
                  const SizedBox(height: 32),
                ],
              
              Text('Today', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.7))),
              const SizedBox(height: 8),
              _buildIncomeExpenseStat('Total Expenses', stats['todayExpense'] ?? 0.0, false),
              const SizedBox(height: 16),
              Divider(color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              Text('This Month', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.7))),
              const SizedBox(height: 8),
              _buildIncomeExpenseStat('Total Expenses', stats['monthlyExpense'] ?? 0.0, false),
            ],
          ),
        ));
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
            color: isIncome ? Colors.white : AppTheme.expense,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.7))),
            Text('₹${amount.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondary)),
          ],
        ),
      ],
    );
  }

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

  Widget _buildRecentTransactions(AsyncValue<List<dynamic>> transactionsAsync, AsyncValue<List<dynamic>> categoriesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Transactions', style: Theme.of(context).textTheme.titleLarge),
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
                categoriesAsync.whenData((categories) {
                  catName = categories.where((c) => c.id == tx.categoryId).firstOrNull?.name;
                });
                final iconData = _getIconForCategory(catName);

                return ListTile(
                  contentPadding: EdgeInsets.zero,
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
                    ),
                  ),
                  subtitle: Text('${tx.type} • ${tx.paymentMethod ?? "Cash"}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  trailing: Text(
                    '-₹${tx.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: tx.type == 'Ignored' ? Theme.of(context).colorScheme.outline : AppTheme.expense,
                      decoration: tx.type == 'Ignored' ? TextDecoration.lineThrough : null,
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
