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
    const bgColor = Color(0xFFFDF9EE);
    const textColor = Color(0xFF1B3B7B);
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
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
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF87171)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notifications Disabled',
                    style: TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please enable notifications in your device settings to receive alerts and summaries.',
                    style: TextStyle(color: Color(0xFF991B1B), fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _requestPermission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
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
                final smsService = ref.read(smsServiceProvider);
                final granted = await smsService.requestPermissions();
                if (granted) {
                  smsService.startListening();
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
            subtitle: 'Transactions over \$500',
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
          _buildSwitchTile(
            title: 'Goal Reminders',
            subtitle: 'Updates on your savings goals',
            value: settings.goalRemindersEnabled,
            onChanged: (val) => notifier.updateSettings(settings.copyWith(goalRemindersEnabled: val)),
            isTop: false,
            isBottom: true,
          ),

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
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const Divider(height: 1, color: Color(0xFFF3F4F6)),
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
    const textColor = Color(0xFF1B3B7B);
    const subTextColor = Color(0xFF4B5563);
    const primaryColor = Color(0xFF2563EB); // Blue for active switches

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: isTop ? const Radius.circular(16) : Radius.zero,
          bottom: isBottom ? const Radius.circular(16) : Radius.zero,
        ),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  color: subTextColor,
                  fontSize: 12,
                ),
              )
            : null,
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: primaryColor,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: const Color(0xFFE5E7EB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
