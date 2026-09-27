import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/repository_providers.dart';
import '../../domain/entities/account_entity.dart';
import 'edit_account_screen.dart'; // We will create this next

import '../widgets/empty_state_widget.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Accounts'),
      ),
      body: accountsAsync.when(
        data: (accounts) {
          final visibleAccounts = accounts.where((a) => !a.isHidden).toList();
          if (visibleAccounts.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.account_balance_outlined,
              title: 'No Accounts Yet',
              message: 'Your bank accounts will appear automatically when SMS transactions are processed.',
            );
          }
          return ListView.builder(
            itemCount: visibleAccounts.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final account = visibleAccounts[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.account_balance), // simplified icon logic for now
                  ),
                  title: Text(account.bankName),
                  subtitle: Text('${account.totalTransactions} transactions'),
                  trailing: Text('₹${account.availableBalance?.toStringAsFixed(2) ?? (account.totalIncome - account.totalExpenses).toStringAsFixed(2)}'),
                  onTap: () {
                    // Navigate to edit account screen
                    Navigator.push(context, MaterialPageRoute(builder: (_) => EditAccountScreen(account: account)));
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAccountDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Bank Account'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Account Name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final newAcc = AccountEntity(
                  id: 0,
                  bankName: name,
                  totalTransactions: 0,
                  totalIncome: 0,
                  totalExpenses: 0,
                  lastTransactionDate: DateTime.now(),
                  icon: 'account_balance',
                  color: '#4CAF50',
                  isHidden: false,
                );
                Navigator.pop(context);
                
                await ref.read(accountRepositoryProvider).insertAccount(newAcc);
                ref.invalidate(accountsProvider);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
