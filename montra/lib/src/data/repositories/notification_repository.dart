import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../providers/auth_provider.dart';

class NotificationSettings {
  final bool dailySummaryEnabled;
  final bool weeklySummaryEnabled;
  final bool monthlySummaryEnabled;
  final bool budgetAlertsEnabled;
  final bool goalRemindersEnabled;
  final bool smsDetectionEnabled;
  final bool largeExpenseAlertsEnabled;
  final bool smartInsightsEnabled;
  final bool quietHoursEnabled;

  NotificationSettings({
    this.dailySummaryEnabled = true,
    this.weeklySummaryEnabled = true,
    this.monthlySummaryEnabled = false,
    this.budgetAlertsEnabled = true,
    this.goalRemindersEnabled = false,
    this.smsDetectionEnabled = true,
    this.largeExpenseAlertsEnabled = true,
    this.smartInsightsEnabled = true,
    this.quietHoursEnabled = true,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      dailySummaryEnabled: json['dailySummaryEnabled'] ?? true,
      weeklySummaryEnabled: json['weeklySummaryEnabled'] ?? true,
      monthlySummaryEnabled: json['monthlySummaryEnabled'] ?? false,
      budgetAlertsEnabled: json['budgetAlertsEnabled'] ?? true,
      goalRemindersEnabled: json['goalRemindersEnabled'] ?? false,
      smsDetectionEnabled: json['smsDetectionEnabled'] ?? true,
      largeExpenseAlertsEnabled: json['largeExpenseAlertsEnabled'] ?? true,
      smartInsightsEnabled: json['smartInsightsEnabled'] ?? true,
      quietHoursEnabled: json['quietHoursEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dailySummaryEnabled': dailySummaryEnabled,
      'weeklySummaryEnabled': weeklySummaryEnabled,
      'monthlySummaryEnabled': monthlySummaryEnabled,
      'budgetAlertsEnabled': budgetAlertsEnabled,
      'goalRemindersEnabled': goalRemindersEnabled,
      'smsDetectionEnabled': smsDetectionEnabled,
      'largeExpenseAlertsEnabled': largeExpenseAlertsEnabled,
      'smartInsightsEnabled': smartInsightsEnabled,
      'quietHoursEnabled': quietHoursEnabled,
    };
  }

  NotificationSettings copyWith({
    bool? dailySummaryEnabled,
    bool? weeklySummaryEnabled,
    bool? monthlySummaryEnabled,
    bool? budgetAlertsEnabled,
    bool? goalRemindersEnabled,
    bool? smsDetectionEnabled,
    bool? largeExpenseAlertsEnabled,
    bool? smartInsightsEnabled,
    bool? quietHoursEnabled,
  }) {
    return NotificationSettings(
      dailySummaryEnabled: dailySummaryEnabled ?? this.dailySummaryEnabled,
      weeklySummaryEnabled: weeklySummaryEnabled ?? this.weeklySummaryEnabled,
      monthlySummaryEnabled: monthlySummaryEnabled ?? this.monthlySummaryEnabled,
      budgetAlertsEnabled: budgetAlertsEnabled ?? this.budgetAlertsEnabled,
      goalRemindersEnabled: goalRemindersEnabled ?? this.goalRemindersEnabled,
      smsDetectionEnabled: smsDetectionEnabled ?? this.smsDetectionEnabled,
      largeExpenseAlertsEnabled: largeExpenseAlertsEnabled ?? this.largeExpenseAlertsEnabled,
      smartInsightsEnabled: smartInsightsEnabled ?? this.smartInsightsEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
    );
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return NotificationRepository(storage);
});

final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return NotificationSettingsNotifier(repo);
});

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final NotificationRepository _repository;

  NotificationSettingsNotifier(this._repository) : super(NotificationSettings()) {
    _load();
  }

  Future<void> _load() async {
    state = await _repository.loadSettings();
  }

  Future<void> updateSettings(NotificationSettings newSettings) async {
    state = newSettings;
    await _repository.saveSettings(newSettings);
  }
}

class NotificationRepository {
  final FlutterSecureStorage _storage;
  static const _key = 'notification_settings_key';
  
  // Keep an in-memory cache for synchronous access
  NotificationSettings _cachedSettings = NotificationSettings();

  NotificationRepository(this._storage);

  Future<NotificationSettings> loadSettings() async {
    final data = await _storage.read(key: _key);
    if (data != null) {
      try {
        _cachedSettings = NotificationSettings.fromJson(jsonDecode(data));
      } catch (_) {
        _cachedSettings = NotificationSettings();
      }
    }
    return _cachedSettings;
  }

  Future<void> saveSettings(NotificationSettings settings) async {
    _cachedSettings = settings;
    await _storage.write(key: _key, value: jsonEncode(settings.toJson()));
  }

  NotificationSettings getSettings() => _cachedSettings;
}
