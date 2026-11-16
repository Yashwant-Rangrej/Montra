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
