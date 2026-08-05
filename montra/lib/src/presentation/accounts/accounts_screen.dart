import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/accounts_provider.dart';
import '../../domain/entities/account_entity.dart';
import 'edit_account_screen.dart'; // We will create this next

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
            return const Center(child: Text('No accounts detected yet. They will appear automatically when SMS transactions are processed.'));
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
    );
  }
}
