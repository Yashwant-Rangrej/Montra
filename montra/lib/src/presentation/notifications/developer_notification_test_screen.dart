import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/notifications/notification_manager.dart';

class DeveloperNotificationTestScreen extends ConsumerStatefulWidget {
  const DeveloperNotificationTestScreen({super.key});

  @override
  ConsumerState<DeveloperNotificationTestScreen> createState() =>
      _DeveloperNotificationTestScreenState();
}

class _DeveloperNotificationTestScreenState
    extends ConsumerState<DeveloperNotificationTestScreen> {
  bool _hasPermission = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.notification.status;
    if (mounted) {
      setState(() {
        _hasPermission = status.isGranted;
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.notification.request();
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    await _checkPermission();
  }

  Future<void> _trigger(String name, Future<void> Function() action) async {
    try {
      if (!_hasPermission) {
        final status = await Permission.notification.request();
        if (status.isGranted) {
          setState(() => _hasPermission = true);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Notification permission is not granted! Please enable it.',
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
                action: SnackBarAction(
                  label: 'Settings',
                  textColor: Colors.white,
                  onPressed: openAppSettings,
                ),
              ),
            );
          }
          return;
        }
      }

      await action();
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name triggered! Check your notification shade.'),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error triggering $name: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final manager = ref.read(notificationManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Testing: Notifications'),
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Theme.of(context).colorScheme.onError,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: _hasPermission
                ? Colors.green.shade50
                : Colors.red.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: _hasPermission ? Colors.green : Colors.red,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    _hasPermission ? Icons.check_circle : Icons.warning_amber,
                    color: _hasPermission ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _hasPermission
                              ? 'Notifications Allowed'
                              : 'Notification Permission Disabled',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _hasPermission
                                ? Colors.green.shade900
                                : Colors.red.shade900,
                          ),
                        ),
                        Text(
                          _hasPermission
                              ? 'System notifications are active on this device.'
                              : 'Android 13+ requires explicit permission.',
                          style: TextStyle(
                            fontSize: 12,
                            color: _hasPermission
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_hasPermission && !_isLoading)
                    TextButton(
                      onPressed: _requestPermission,
                      child: const Text('Grant'),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'These buttons trigger native notifications for testing purposes only.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _trigger(
              'Daily Summary',
              () => manager.showDailySummary(
                spentToday: 1240,
                txCount: 5,
                biggestExpense: 'Swiggy (₹450)',
                remainingBudget: 580,
                force: true,
              ),
            ),
            child: const Text('Trigger Daily Summary'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _trigger(
              'Transaction Detected',
              () => manager.showTransactionDetected(
                merchant: 'Amazon',
                amount: 1240,
                category: 'Shopping',
                force: true,
              ),
            ),
            child: const Text('Trigger Transaction Detected'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _trigger(
              'Budget Alert',
              () => manager.showBudgetAlert(
                budgetName: 'Food & Dining',
                used: 850,
                remaining: 150,
                force: true,
              ),
            ),
            child: const Text('Trigger Budget Alert'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _trigger(
              'Large Expense Alert',
              () => manager.showLargeExpenseAlert(
                merchant: 'Apple Store',
                amount: 125000,
                method: 'Credit Card',
                force: true,
              ),
            ),
            child: const Text('Trigger Large Expense Alert'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _trigger(
              'Smart Insight',
              () => manager.showSmartInsight(
                insight: 'You spent 18% less than last week. Great job!',
                force: true,
              ),
            ),
            child: const Text('Trigger Smart Insight'),
          ),
        ],
      ),
    );
  }
}
