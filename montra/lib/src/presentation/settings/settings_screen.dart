import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const Text('General', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Accounts'),
            leading: const Icon(Icons.account_balance_wallet),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/accounts');
            },
          ),
          ListTile(
            title: const Text('Goals'),
            leading: const Icon(Icons.flag),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/goals');
            },
          ),
          ListTile(
            title: const Text('Budgets'),
            leading: const Icon(Icons.pie_chart),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/budgets');
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
