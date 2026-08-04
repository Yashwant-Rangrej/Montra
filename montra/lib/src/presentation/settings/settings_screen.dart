import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAppLockEnabled = ref.watch(appLockEnabledProvider);
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
          const SizedBox(height: 16),
          const Text('Security', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('App Lock (Biometrics/PIN)'),
            subtitle: const Text('Require authentication to open Montra'),
            secondary: const Icon(Icons.security),
            value: isAppLockEnabled,
            onChanged: (value) async {
              // Only allow enabling if they can successfully authenticate right now
              if (value) {
                final authService = ref.read(authServiceProvider);
                final success = await authService.authenticateUser();
                if (success) {
                  ref.read(appLockEnabledProvider.notifier).toggle(true);
                }
              } else {
                ref.read(appLockEnabledProvider.notifier).toggle(false);
              }
            },
          ),
          const Divider(),
          if (kDebugMode) ...[
            ListTile(
              leading: const Icon(Icons.bug_report, color: Colors.red),
              title: const Text('Developer Notification Test', style: TextStyle(color: Colors.red)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                context.push('/developer-notification-test');
              },
            ),
            const Divider(),
          ]
        ],
      ),
    );
  }
}
