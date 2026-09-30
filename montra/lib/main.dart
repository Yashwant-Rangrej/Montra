import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/providers/notification_providers.dart';
import 'src/services/notifications/notification_models.dart';
import 'src/services/notifications/notification_manager.dart';
import 'src/services/monthly_summary_service.dart';
import 'src/services/monthly_summary_worker.dart';
import 'src/providers/repository_providers.dart';
import 'src/providers/sms_providers.dart';

import 'src/core/routing/app_router.dart';
import 'src/core/theme/app_theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/providers/auth_provider.dart';
import 'src/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // If first run after an install/reinstall, clear secure storage
  if (prefs.getBool('is_first_run') ?? true) {
    const storage = FlutterSecureStorage();
    await storage.deleteAll();
    await prefs.setBool('is_first_run', false);
  }

  // Pre-seed prefs from secure storage for existing installs
  const storage = FlutterSecureStorage();
  if (!prefs.containsKey('app_lock_enabled')) {
    final val = await storage.read(key: 'app_lock_enabled');
    if (val != null) {
      await prefs.setBool('app_lock_enabled', val == 'true');
    }
  }
  if (!prefs.containsKey('onboarding_completed')) {
    final val = await storage.read(key: 'onboarding_completed');
    if (val != null) {
      await prefs.setBool('onboarding_completed', val == 'true');
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MontraApp(),
    ),
  );
}

class MontraApp extends ConsumerStatefulWidget {
  const MontraApp({super.key});

  @override
  ConsumerState<MontraApp> createState() => _MontraAppState();
}

class _MontraAppState extends ConsumerState<MontraApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Use addPostFrameCallback to ensure ref.read works after the widget tree
    // is fully built. This guarantees the callback handle is always stored
    // on every app launch — even after updates — so the background SMS receiver
    // can spin up a Dart engine without needing the main app to be running.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initNotifications();
      _initSmsListener();
      // Register the background monthly summary WorkManager task.
      // This persists across reboots and fires every 12h;
      // the worker itself only sends a notification on the 1st of the month.
      registerMonthlySummaryWorker();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the app is sent to the phone home screen or background,
    // reset the auth session so the lock screen shows on next launch.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      final isLockEnabled = ref.read(appLockEnabledProvider);
      if (isLockEnabled) {
        ref.read(authStateProvider.notifier).state = false;
      }
    }
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
      router.push(payload.route);
    });

    // Check if a new month has started and send monthly summary notification
    final db = ref.read(databaseProvider);
    final notifManager = ref.read(notificationManagerProvider);
    final summaryService = MonthlySummaryService(db, notifManager);
    summaryService.checkAndSend();
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
