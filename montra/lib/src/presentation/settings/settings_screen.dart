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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _buildSectionHeader(context, 'General'),
          _buildSettingsGroup(
            context,
            children: [
              _buildSettingsTile(
                context,
                title: 'Accounts',
                icon: Icons.account_balance_wallet,
                iconColor: theme.colorScheme.primary,
                onTap: () => context.push('/accounts'),
              ),

              _buildSettingsTile(
                context,
                title: 'Budgets',
                icon: Icons.pie_chart,
                iconColor: Colors.purple,
                onTap: () => context.push('/budgets'),
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'Security'),
          _buildSettingsGroup(
            context,
            children: [
              _buildSwitchTile(
                context,
                title: 'App Lock (Biometrics/PIN)',
                subtitle: 'Require authentication to open Montra',
                icon: Icons.security,
                iconColor: Colors.teal,
                value: isAppLockEnabled,
                onChanged: (value) async {
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
                isLast: true,
              ),
            ],
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'Developer'),
            _buildSettingsGroup(
              context,
              children: [
                _buildSettingsTile(
                  context,
                  title: 'Developer Notification Test',
                  icon: Icons.bug_report,
                  iconColor: theme.colorScheme.error,
                  textColor: theme.colorScheme.error,
                  onTap: () => context.push('/developer-notification-test'),
                  isLast: true,
                ),
              ],
            ),
          ],
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).cardTheme.shadowColor?.withValues(alpha: 0.05) ?? Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    Color? textColor,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor ?? Theme.of(context).colorScheme.onSurface,
                ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(isLast && childrenCount(context) == 1 ? 24 : 0),
              bottom: Radius.circular(isLast ? 24 : 0),
            ),
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 76, right: 24),
            child: Divider(
              height: 1,
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
          ),
      ],
    );
  }

  int childrenCount(BuildContext context) => 1; // dummy for rounding logic

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return Column(
      children: [
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          secondary: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(isLast && childrenCount(context) == 1 ? 24 : 0),
              bottom: Radius.circular(isLast ? 24 : 0),
            ),
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 76, right: 24),
            child: Divider(
              height: 1,
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
          ),
      ],
    );
  }
}
