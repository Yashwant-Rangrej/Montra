import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/providers/notification_providers.dart';
import 'src/services/notifications/notification_models.dart';
import 'src/providers/sms_providers.dart';
import 'src/data/repositories/notification_repository.dart';

import 'src/core/routing/app_router.dart';
import 'src/core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: MontraApp(),
    ),
  );
}

class MontraApp extends ConsumerStatefulWidget {
  const MontraApp({super.key});

  @override
  ConsumerState<MontraApp> createState() => _MontraAppState();
}

class _MontraAppState extends ConsumerState<MontraApp> {
  @override
  void initState() {
    super.initState();
    _initNotifications();
    _initSmsListener();
  }

  Future<void> _initSmsListener() async {
    final settings = ref.read(notificationSettingsProvider);
    if (settings.smsDetectionEnabled && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final interceptor = ref.read(smsInterceptorProvider);
        await interceptor.initialize();
      } catch (e) {
        debugPrint('SMS interceptor initialization error: $e');
      }
    }
  }

  Future<void> _initNotifications() async {
    final service = ref.read(notificationServiceProvider);
    await service.init((NotificationPayload payload) {
      final router = ref.read(appRouterProvider);
      // Ensure we navigate to the route specified in the payload
      router.push(payload.route);
    });
  }

  @override
  Widget build(BuildContext context) {
    final goRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Montra',
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
