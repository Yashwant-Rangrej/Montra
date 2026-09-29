import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/providers/notification_providers.dart';
import 'src/services/notifications/notification_models.dart';
import 'src/providers/sms_providers.dart';

import 'src/core/routing/app_router.dart';
import 'src/core/theme/app_theme.dart';
import 'src/providers/theme_provider.dart';

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
    // Use addPostFrameCallback to ensure ref.read works after the widget tree
    // is fully built. This guarantees the callback handle is always stored
    // on every app launch — even after updates — so the background SMS receiver
    // can spin up a Dart engine without needing the main app to be running.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initNotifications();
      _initSmsListener();
    });
  }

  Future<void> _initSmsListener() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      // Always re-register the callback handle on every launch so the
      // background SmsReceiver always has a valid handle even after app updates.
      final interceptor = ref.read(smsInterceptorProvider);
      await interceptor.initialize();
    } catch (e) {
      debugPrint('SMS interceptor initialization error: $e');
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
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Montra',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
