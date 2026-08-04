import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<bool> checkPermission() async {
    var status = await Permission.notification.status;
    return status.isGranted;
  }

  Future<bool> requestPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final bool? granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    var status = await Permission.notification.request();
    return status.isGranted;
  }
}
