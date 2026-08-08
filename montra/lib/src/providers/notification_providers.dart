import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repository_providers.dart';
import '../services/notifications/notification_service.dart';
import '../services/notifications/notification_permission_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final notificationPermissionServiceProvider = Provider<NotificationPermissionService>((ref) {
  return NotificationPermissionService();
});

final dbNotificationsProvider = FutureProvider<List<dynamic>>((ref) async {
  final db = ref.watch(databaseProvider);
  return await db.select(db.notifications).get();
});
