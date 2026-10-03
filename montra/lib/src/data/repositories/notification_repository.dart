import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../../data/database/database.dart';
import '../../providers/repository_providers.dart';

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
  final double largeExpenseThreshold;

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
    this.largeExpenseThreshold = 10000.0,
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
      largeExpenseThreshold: (json['largeExpenseThreshold'] as num?)?.toDouble() ?? 10000.0,
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
      'largeExpenseThreshold': largeExpenseThreshold,
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
    double? largeExpenseThreshold,
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
      largeExpenseThreshold: largeExpenseThreshold ?? this.largeExpenseThreshold,
    );
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return NotificationRepository(db);
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
  final AppDatabase _db;
  
  // Keep an in-memory cache for synchronous access
  NotificationSettings _cachedSettings = NotificationSettings();

  NotificationRepository(this._db);

  Future<NotificationSettings> loadSettings() async {
    final setting = await (_db.select(_db.notificationSettingsDb)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();

    if (setting != null) {
      _cachedSettings = NotificationSettings(
        dailySummaryEnabled: setting.dailySummaryEnabled,
        weeklySummaryEnabled: setting.weeklySummaryEnabled,
        monthlySummaryEnabled: setting.monthlySummaryEnabled,
        budgetAlertsEnabled: setting.budgetAlertsEnabled,
        goalRemindersEnabled: setting.goalRemindersEnabled,
        smsDetectionEnabled: setting.smsDetectionEnabled,
        largeExpenseAlertsEnabled: setting.largeExpenseAlertsEnabled,
        smartInsightsEnabled: setting.smartInsightsEnabled,
        quietHoursEnabled: setting.quietHoursEnabled,
        largeExpenseThreshold: setting.largeExpenseThreshold,
      );
    }
    return _cachedSettings;
  }

  Future<void> saveSettings(NotificationSettings settings) async {
    _cachedSettings = settings;
    await _db.into(_db.notificationSettingsDb).insertOnConflictUpdate(
          NotificationSettingsDbCompanion(
            id: const drift.Value(1),
            dailySummaryEnabled: drift.Value(settings.dailySummaryEnabled),
            weeklySummaryEnabled: drift.Value(settings.weeklySummaryEnabled),
            monthlySummaryEnabled: drift.Value(settings.monthlySummaryEnabled),
            budgetAlertsEnabled: drift.Value(settings.budgetAlertsEnabled),
            goalRemindersEnabled: drift.Value(settings.goalRemindersEnabled),
            smsDetectionEnabled: drift.Value(settings.smsDetectionEnabled),
            largeExpenseAlertsEnabled: drift.Value(settings.largeExpenseAlertsEnabled),
            smartInsightsEnabled: drift.Value(settings.smartInsightsEnabled),
            quietHoursEnabled: drift.Value(settings.quietHoursEnabled),
            largeExpenseThreshold: drift.Value(settings.largeExpenseThreshold),
          ),
        );
  }

  NotificationSettings getSettings() => _cachedSettings;
}
