import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  // Temporary state for UI preview matching the design
  final Map<String, bool> _settings = {
    'daily': true,
    'weekly': true,
    'monthly': false,
    'sms': true,
    'large_expense': true,
    'budget': true,
    'goal': false,
    'quiet': true,
    'sound': true,
    'vibration': false,
  };

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFFDF9EE);
    const textColor = Color(0xFF1B3B7B);
    const primaryColor = Color(0xFF2563EB); // Blue for active switches
    const inactiveColor = Color(0xFFE5E7EB);

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
          _buildSectionHeader('Summaries'),
          _buildSwitchTile(
            title: 'Daily Summary',
            subtitle: 'Delivered at 9:00 PM',
            value: _settings['daily']!,
            onChanged: (val) => setState(() => _settings['daily'] = val),
            isTop: true,
            isBottom: false,
          ),
          _buildDivider(),
          _buildSwitchTile(
            title: 'Weekly Summary',
            subtitle: 'Overview of your week',
            value: _settings['weekly']!,
            onChanged: (val) => setState(() => _settings['weekly'] = val),
            isTop: false,
            isBottom: false,
          ),
          _buildDivider(),
          _buildSwitchTile(
            title: 'Monthly Summary',
            subtitle: 'Deep dive into your month',
            value: _settings['monthly']!,
            onChanged: (val) => setState(() => _settings['monthly'] = val),
            isTop: false,
            isBottom: true,
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Activity Alerts'),
          _buildSwitchTile(
            title: 'SMS Notifications',
            subtitle: 'For automatic detections',
            value: _settings['sms']!,
            onChanged: (val) => setState(() => _settings['sms'] = val),
            isTop: true,
            isBottom: false,
          ),
          _buildDivider(),
          _buildSwitchTile(
            title: 'Large Expense Alerts',
            subtitle: 'Transactions over \$500',
            value: _settings['large_expense']!,
            onChanged: (val) => setState(() => _settings['large_expense'] = val),
            isTop: false,
            isBottom: true,
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Financial Planning'),
          _buildSwitchTile(
            title: 'Budget Alerts',
            subtitle: 'At 50%, 80%, and 100% milestones',
            value: _settings['budget']!,
            onChanged: (val) => setState(() => _settings['budget'] = val),
            isTop: true,
            isBottom: false,
          ),
          _buildDivider(),
          _buildSwitchTile(
            title: 'Goal Reminders',
            subtitle: 'Updates on your savings goals',
            value: _settings['goal']!,
            onChanged: (val) => setState(() => _settings['goal'] = val),
            isTop: false,
            isBottom: true,
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Preferences'),
          _buildSwitchTile(
            title: 'Quiet Hours',
            subtitle: '10:00 PM - 7:00 AM',
            value: _settings['quiet']!,
            onChanged: (val) => setState(() => _settings['quiet'] = val),
            isTop: true,
            isBottom: false,
          ),
          _buildDivider(),
          _buildSwitchTile(
            title: 'Sound',
            subtitle: null,
            value: _settings['sound']!,
            onChanged: (val) => setState(() => _settings['sound'] = val),
            isTop: false,
            isBottom: false,
          ),
          _buildDivider(),
          _buildSwitchTile(
            title: 'Vibration',
            subtitle: null,
            value: _settings['vibration']!,
            onChanged: (val) => setState(() => _settings['vibration'] = val),
            isTop: false,
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
