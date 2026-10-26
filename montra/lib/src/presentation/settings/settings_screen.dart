import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/repository_providers.dart';
import '../../services/update/update_service.dart';
import '../../services/monthly_summary_service.dart';
import '../../services/notifications/notification_manager.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAppLockEnabled = ref.watch(appLockEnabledProvider);

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
                title: 'Categories',
                icon: Icons.category_outlined,
                iconColor: Colors.blue,
                onTap: () => context.push('/categories'),
              ),

              _buildSettingsTile(
                context,
                title: 'Notifications',
                icon: Icons.notifications_outlined,
                iconColor: Colors.deepPurple,
                onTap: () => context.push('/notification-settings'),
              ),
              _buildSettingsTile(
                context,
                title: 'Ignored SMS',
                icon: Icons.sms_failed_outlined,
                iconColor: Colors.orange,
                onTap: () => context.push('/ignored-sms'),
              ),
              _buildSettingsTile(
                context,
                title: 'Check for Updates',
                icon: Icons.system_update_outlined,
                iconColor: Colors.teal,
                isLast: true,
                onTap: () {
                  // This checks github pages for the version.json
                  final updateService = UpdateService();
                  updateService.checkForUpdates(context, showNoUpdateMessage: true);
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'Appearance'),
          _buildSettingsGroup(
            context,
            children: [
              _buildThemeSelectorTile(context, ref),
            ],
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'Security'),
          _buildSettingsGroup(
            context,
            children: [
              _buildSwitchTile(
                context,
                title: 'Mobile Local Authentication',
                subtitle: 'Require device screen lock or biometrics (Fingerprint/PIN) to open Montra',
                icon: Icons.fingerprint_rounded,
                iconColor: Colors.teal,
                value: isAppLockEnabled,
                onChanged: (value) async {
                  final authService = ref.read(authServiceProvider);
                  if (value) {
                    final isSupported = await authService.isDeviceSupported();
                    if (!isSupported) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'No screen lock or biometrics configured on this device. Please set up a screen lock in phone settings.',
                            ),
                          ),
                        );
                      }
                      return;
                    }
                    final success = await authService.authenticateUser(
                      reason: 'Confirm your device screen lock or biometrics to enable App Lock',
                    );
                    if (success) {
                      ref.read(appLockEnabledProvider.notifier).toggle(true);
                    }
                  } else {
                    final success = await authService.authenticateUser(
                      reason: 'Authenticate using your device screen lock or biometrics to disable App Lock',
                    );
                    if (success) {
                      ref.read(appLockEnabledProvider.notifier).toggle(false);
                    }
                  }
                },
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'Reports'),
          _buildSettingsGroup(
            context,
            children: [
              _buildSettingsTile(
                context,
                title: 'Generate Monthly Summary',
                icon: Icons.bar_chart_outlined,
                iconColor: Colors.indigo,
                isLast: true,
                onTap: () async {
                  final db = ref.read(databaseProvider);
                  final notifManager = ref.read(notificationManagerProvider);
                  final service = MonthlySummaryService(db, notifManager);
                  final stats = await service.computeLastMonthStats(DateTime.now());
                  if (stats != null && context.mounted) {
                    context.push('/monthly-summary-report', extra: stats);
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No expenses found for last month.')),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'Data Management'),
          _buildSettingsGroup(
            context,
            children: [
              _buildSettingsTile(
                context,
                title: 'Import & Export Data (Backup & Restore)',
                icon: Icons.import_export_rounded,
                iconColor: Colors.blue,
                isLast: false,
                onTap: () => context.push('/backup'),
              ),
              _buildSettingsTile(
                context,
                title: 'Clear Database',
                icon: Icons.delete_outline,
                iconColor: Colors.red,
                textColor: Colors.red,
                isLast: true,
                onTap: () async {
                  final result = await showDialog<String>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear Database'),
                      content: const Text('Which data would you like to clear?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'cancel'),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'history'),
                          child: const Text('Past History Only', style: TextStyle(color: Colors.blue)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'transactions'),
                          child: const Text('All Transactions', style: TextStyle(color: Colors.orange)),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () => Navigator.pop(context, 'all'),
                          child: const Text('Clear Everything'),
                        ),
                      ],
                    ),
                  );
                  if (result == 'all' || result == 'transactions' || result == 'history') {
                    final db = ref.read(databaseProvider);
                    if (result == 'all') {
                      await db.clearAllData();
          // Notify user that all data has been cleared
          final notifMgr = ref.read(notificationManagerProvider);
          await notifMgr.showDataCleared();
                    } else if (result == 'transactions') {
                      await db.clearTransactions();
                    } else if (result == 'history') {
                      await db.clearMonthlyHistory();
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          result == 'all' ? 'All data cleared successfully.' 
                          : result == 'history' ? 'Past monthly history cleared successfully.' 
                          : 'Transactions cleared successfully.'
                        ),
                      ));
                    }
                  }
                },
              ),
            ],
          ),

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
              fontWeight: FontWeight.w600,
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
          activeThumbColor: Theme.of(context).colorScheme.primary,
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

  Widget _buildThemeSelectorTile(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.brightness_6_outlined, color: Colors.amber, size: 24),
      ),
      title: Text(
        'App Theme',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      trailing: DropdownButton<ThemeMode>(
        value: themeMode,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: ThemeMode.system, child: Text('System Default')),
          DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
          DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
        ],
        onChanged: (mode) {
          if (mode != null) {
            ref.read(themeModeProvider.notifier).updateThemeMode(mode);
          }
        },
      ),
    );
  }
}
