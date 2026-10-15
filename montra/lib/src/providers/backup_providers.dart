import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/backup/backup_service.dart';
import 'repository_providers.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.watch(databaseProvider);
  return BackupService(db);
});

final availableBackupsProvider = FutureProvider<List<BackupFileMetadata>>((ref) async {
  final service = ref.watch(backupServiceProvider);
  return service.getAvailableBackups();
});

class AutoBackupNotifier extends StateNotifier<bool> {
  final BackupService _service;

  AutoBackupNotifier(this._service) : super(true) {
    _loadState();
  }

  Future<void> _loadState() async {
    state = await _service.isAutoBackupEnabled();
  }

  Future<void> toggle(bool enabled) async {
    state = enabled;
    await _service.setAutoBackupEnabled(enabled);
  }
}

final autoBackupEnabledProvider =
    StateNotifierProvider<AutoBackupNotifier, bool>((ref) {
  final service = ref.watch(backupServiceProvider);
  return AutoBackupNotifier(service);
});
