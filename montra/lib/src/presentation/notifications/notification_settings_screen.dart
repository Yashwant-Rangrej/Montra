import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/repositories/notification_repository.dart';
import '../../providers/notification_providers.dart';
import '../../providers/sms_providers.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.notification.status;
    setState(() {
      _permissionGranted = status.isGranted;
    });
  }

  Future<void> _requestPermission() async {
    final service = ref.read(notificationPermissionServiceProvider);
    final granted = await service.requestPermission();
    setState(() {
      _permissionGranted = granted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notification Settings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        children: [
          if (!_permissionGranted)
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications Disabled',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onErrorContainer),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please enable notifications in your device settings to receive alerts and summaries.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onErrorContainer),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _requestPermission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                    child: const Text('Enable Notifications'),
                  ),
                ],
              ),
            ),
          _buildSectionHeader('Summaries'),
          _buildSwitchTile(
            title: 'Daily Summary',
            subtitle: 'Delivered at 9:00 PM',
            value: settings.dailySummaryEnabled,
            onChanged: (val) => notifier.updateSettings(settings.copyWith(dailySummaryEnabled: val)),
            isTop: true,
            isBottom: false,
          ),
          _buildDivider(),
          _buildSwitchTile(
            title: 'Weekly Summary',
            subtitle: 'Overview of your week',
            value: settings.weeklySummaryEnabled,
            onChanged: (val) => notifier.updateSettings(settings.copyWith(weeklySummaryEnabled: val)),
            isTop: false,
            isBottom: false,
          ),
          _buildDivider(),
          _buildSwitchTile(
            title: 'Monthly Summary',
            subtitle: 'Deep dive into your month',
            value: settings.monthlySummaryEnabled,
            onChanged: (val) => notifier.updateSettings(settings.copyWith(monthlySummaryEnabled: val)),
            isTop: false,
            isBottom: true,
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Activity Alerts'),
          _buildSwitchTile(
            title: 'SMS Notifications',
            subtitle: 'For automatic detections',
            value: settings.smsDetectionEnabled,
            onChanged: (val) async {
              if (val) {
                final interceptor = ref.read(smsInterceptorProvider);
                final granted = await interceptor.requestPermissions();
                if (granted) {
                  await interceptor.initialize();
                  notifier.updateSettings(settings.copyWith(smsDetectionEnabled: true));
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('SMS Permission denied')),
                    );
                  }
                }
              } else {
                notifier.updateSettings(settings.copyWith(smsDetectionEnabled: false));
              }
            },
            isTop: true,
            isBottom: false,
          ),
          _buildDivider(),
          _buildSwitchTile(
            title: 'Large Expense Alerts',
            subtitle: 'Transactions over ₹500',
            value: settings.largeExpenseAlertsEnabled,
            onChanged: (val) => notifier.updateSettings(settings.copyWith(largeExpenseAlertsEnabled: val)),
            isTop: false,
            isBottom: true,
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Financial Planning'),
          _buildSwitchTile(
            title: 'Budget Alerts',
            subtitle: 'At 50%, 80%, and 100% milestones',
            value: settings.budgetAlertsEnabled,
            onChanged: (val) => notifier.updateSettings(settings.copyWith(budgetAlertsEnabled: val)),
            isTop: true,
            isBottom: false,
          ),
          _buildDivider(),

          const SizedBox(height: 24),
          _buildSectionHeader('Insights'),
          _buildSwitchTile(
            title: 'Smart Insights',
            subtitle: 'Intelligent financial tips and trends',
            value: settings.smartInsightsEnabled,
            onChanged: (val) => notifier.updateSettings(settings.copyWith(smartInsightsEnabled: val)),
            isTop: true,
            isBottom: true,
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Preferences'),
          _buildSwitchTile(
            title: 'Quiet Hours',
            subtitle: '10:00 PM - 7:00 AM',
            value: settings.quietHoursEnabled,
            onChanged: (val) => notifier.updateSettings(settings.copyWith(quietHoursEnabled: val)),
            isTop: true,
            isBottom: true,
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Diagnostics'),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              title: const Text('Test Notification Alerts'),
              subtitle: Text(
                'Simulate alerts and test background triggers',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/developer-notification-test'),
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Theme.of(context).colorScheme.surfaceContainerHighest),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isTop,
    required bool isBottom,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: isTop ? const Radius.circular(16) : Radius.zero,
          bottom: isBottom ? const Radius.circular(16) : Radius.zero,
        ),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              )
            : null,
        value: value,
        onChanged: onChanged,
        activeThumbColor: Theme.of(context).colorScheme.onPrimary,
        activeTrackColor: Theme.of(context).colorScheme.primary,
        inactiveThumbColor: Theme.of(context).colorScheme.surface,
        inactiveTrackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
