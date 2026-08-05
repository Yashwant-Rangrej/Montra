import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import 'notification_service.dart';
import 'notification_channels.dart';
import 'notification_models.dart';
import '../../providers/notification_providers.dart';
import '../../data/repositories/notification_repository.dart';

final notificationManagerProvider = Provider<NotificationManager>((ref) {
  final service = ref.watch(notificationServiceProvider);
  final repo = ref.watch(notificationRepositoryProvider);
  return NotificationManager(service, repo);
});

class NotificationManager {
  final NotificationService _service;
  final NotificationRepository _repository;
  final Random _random = Random();

  NotificationManager(this._service, this._repository);

  int _generateId() => _random.nextInt(100000);

  bool _isQuietHours() {
    // Simple logic to check quiet hours (10 PM to 7 AM)
    final settings = _repository.getSettings();
    if (settings.quietHoursEnabled) {
      final now = DateTime.now();
      final hour = now.hour;
      if (hour >= 22 || hour < 7) {
        return true;
      }
    }
    return false;
  }

  Future<void> showDailySummary({
    required double spentToday,
    required int txCount,
    required String biggestExpense,
    required double remainingBudget,
    bool force = false,
  }) async {
    final settings = _repository.getSettings();
    if (!force && (!settings.dailySummaryEnabled || _isQuietHours())) return;

    await _service.showNotification(
      id: _generateId(),
      title: 'Daily Summary',
      body: 'Spent ₹${spentToday.toStringAsFixed(0)} across $txCount transactions. Biggest: $biggestExpense. ₹${remainingBudget.toStringAsFixed(0)} left today.',
      channel: NotificationChannels.dailySummary,
      payload: const NotificationPayload(type: 'dailySummary', route: '/'),
    );
  }

  Future<void> showTransactionDetected({
    required String merchant,
    required double amount,
    required String category,
    bool force = false,
  }) async {
    final settings = _repository.getSettings();
    if (!force && !settings.smsDetectionEnabled) return;

    await _service.showNotification(
      id: _generateId(),
      title: 'New Transaction Detected',
      body: '$merchant - ₹${amount.toStringAsFixed(0)}. Category: $category. Added automatically.',
      channel: NotificationChannels.transactions,
      payload: const NotificationPayload(type: 'transactionDetected', route: '/transactions'),
    );
  }

  Future<void> showBudgetAlert({
    required String budgetName,
    required double used,
    required double remaining,
    bool force = false,
  }) async {
    final settings = _repository.getSettings();
    if (!force && !settings.budgetAlertsEnabled) return;

    // Critical alerts bypass quiet hours!
    await _service.showNotification(
      id: _generateId(),
      title: 'Budget Alert: $budgetName',
      body: '₹${used.toStringAsFixed(0)} used. ₹${remaining.toStringAsFixed(0)} remaining. Review your spending.',
      channel: NotificationChannels.budgets,
      payload: const NotificationPayload(type: 'budgetAlert', route: '/budgets'),
    );
  }

  Future<void> showSmartInsight({
    required String insight,
    bool force = false,
  }) async {
    final settings = _repository.getSettings();
    if (!force && (!settings.smartInsightsEnabled || _isQuietHours())) return;

    await _service.showNotification(
      id: _generateId(),
      title: 'Smart Insight',
      body: insight,
      channel: NotificationChannels.insights,
      payload: const NotificationPayload(type: 'smartInsight', route: '/analytics'),
    );
  }

  Future<void> showLargeExpenseAlert({
    required String merchant,
    required double amount,
    required String method,
    bool force = false,
  }) async {
    final settings = _repository.getSettings();
    if (!force && !settings.largeExpenseAlertsEnabled) return;

    await _service.showNotification(
      id: _generateId(),
      title: 'Large Expense Alert',
      body: '₹${amount.toStringAsFixed(0)} at $merchant via $method. Tap to review.',
      channel: NotificationChannels.transactions,
      payload: const NotificationPayload(type: 'largeExpense', route: '/transactions'),
    );
  }
}
