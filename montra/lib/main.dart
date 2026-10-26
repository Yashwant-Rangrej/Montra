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
import 'package:drift/drift.dart' as drift;
import 'src/providers/auth_provider.dart';
import 'src/providers/theme_provider.dart';
import 'src/domain/entities/sms_message.dart';
import 'src/services/sms/sms_parser.dart';
import 'src/services/sms/sms_interceptor.dart';
import 'src/services/notifications/notification_channels.dart';
import 'src/providers/transactions_provider.dart';
import 'src/data/database/database.dart';
import 'src/data/repositories/notification_repository.dart';

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
    // Skip if the pause was triggered by the OS local authentication prompt itself.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      final authService = ref.read(authServiceProvider);
      if (!authService.isAuthenticating && !authService.justFinishedAuthenticating) {
        final isLockEnabled = ref.read(appLockEnabledProvider);
        if (isLockEnabled) {
          ref.read(authStateProvider.notifier).state = false;
        }
      }
    } else if (state == AppLifecycleState.resumed) {
      // Re-trigger query stream so any transaction added while paused appears immediately
      try {
        final db = ref.read(databaseProvider);
        db.notifyUpdates({drift.TableUpdate.onTable(db.transactions)});
        ref.invalidate(allTransactionsProvider);
        ref.invalidate(transactionsProvider);
      } catch (e) {
        debugPrint('Error refreshing transactions on resume: $e');
      }
    }
  }

  Future<void> _initSmsListener() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final interceptor = ref.read(smsInterceptorProvider);
      if (interceptor is NativeSmsInterceptor) {
        interceptor.onForegroundSms = (Map<String, dynamic> args) async {
          try {
            final message = SmsMessage.fromMap(args);
            final parsed = SmsParser.parseSms(message.sender, message.body);
            if (parsed != null) {
              final db = ref.read(databaseProvider);

              // Prevent duplicate transactions if reference number or identical SMS already stored
              if (parsed.referenceNumber != null && parsed.referenceNumber!.isNotEmpty) {
                final existingRef = await (db.select(db.transactions)
                      ..where((t) => t.bankTransactionId.equals(parsed.referenceNumber!)))
                    .getSingleOrNull();
                if (existingRef != null) {
                  return;
                }
              }
              final existingSms = await (db.select(db.transactions)
                    ..where((t) => t.originalSms.equals(message.body)))
                  .getSingleOrNull();
              if (existingSms != null) {
                return;
              }

              final categoryRow = await (db.select(db.categories)
                    ..where((c) => c.name.equals(parsed.category) | c.name.like('${parsed.category}%')))
                  .getSingleOrNull();

              final insertedId = await db.into(db.transactions).insert(
                    TransactionsCompanion.insert(
                      amount: parsed.amount,
                      type: parsed.type,
                      merchant: drift.Value(parsed.merchant),
                      categoryId: drift.Value(categoryRow?.id),
                      accountId: 1,
                      paymentMethod: drift.Value(parsed.paymentMethod),
                      availableBalance: drift.Value(parsed.availableBalance),
                      bankTransactionId: drift.Value(parsed.referenceNumber),
                      transactionDate: message.receivedAt,
                      originalSms: drift.Value(message.body),
                    ),
                  );

              if (parsed.availableBalance != null) {
                await (db.update(db.accounts)..where((a) => a.id.equals(1))).write(
                  AccountsCompanion(
                    availableBalance: drift.Value(parsed.availableBalance),
                    lastTransactionDate: drift.Value(message.receivedAt),
                  ),
                );
              }

              // Instantly refresh UI without requiring app restart or manual refresh
              db.notifyUpdates({drift.TableUpdate.onTable(db.transactions)});
              ref.invalidate(allTransactionsProvider);
              ref.invalidate(transactionsProvider);

              // Show expense detection notification immediately
              final notifService = ref.read(notificationServiceProvider);
              await notifService.showNotification(
                id: (DateTime.now().millisecondsSinceEpoch ~/ 100).remainder(2147483647),
                title: '💳 Expense Detected',
                body:
                    'Spent ₹${parsed.amount.toStringAsFixed(0)} at ${parsed.merchant} via ${parsed.paymentMethod} (${parsed.category})',
                channel: NotificationChannels.transactions,
                payload: NotificationPayload(
                  type: 'transactionDetected',
                  route: '/transactions',
                  data: {'transactionId': insertedId},
                ),
              );

              // Check for Large Expense Alert if applicable
              final notifRepo = ref.read(notificationRepositoryProvider);
              final notifSettings = notifRepo.getSettings();
              if (notifSettings.largeExpenseAlertsEnabled && parsed.amount >= notifSettings.largeExpenseThreshold) {
                final manager = ref.read(notificationManagerProvider);
                await manager.showLargeExpenseAlert(
                  merchant: parsed.merchant,
                  amount: parsed.amount,
                  method: parsed.paymentMethod,
                );
              }

              // Check for Budget Alert if applicable
              if (notifSettings.budgetAlertsEnabled) {
                final budgetRepo = ref.read(budgetRepositoryProvider);
                final transactionRepo = ref.read(transactionRepositoryProvider);
                final now = DateTime.now();
                final budgets = await budgetRepo.getBudgetsByMonthAndYear(now.month, now.year);
                final allTransactions = await transactionRepo.getAllTransactions();
                final currentMonthTx = allTransactions.where((t) =>
                    t.type == 'Expense' &&
                    t.transactionDate.year == now.year &&
                    t.transactionDate.month == now.month).toList();

                final manager = ref.read(notificationManagerProvider);
                for (var b in budgets) {
                  if (b.categoryId == categoryRow?.id || b.categoryId == null) {
                    final spent = currentMonthTx
                        .where((t) => b.categoryId == null || t.categoryId == categoryRow?.id)
                        .fold(0.0, (sum, t) => sum + t.amount);
                    final percent = spent / b.amount;
                    if (percent >= 1.0) {
                      await manager.showBudgetAlert(
                        budgetName: b.categoryId == null ? 'Overall Budget Limit Reached' : '${categoryRow?.name ?? "Category"} Budget Reached',
                        used: spent,
                        remaining: 0,
                      );
                    } else if (percent >= 0.8) {
                      await manager.showBudgetAlert(
                        budgetName: b.categoryId == null ? 'Overall Budget Alert (80%)' : '${categoryRow?.name ?? "Category"} Budget Alert (80%)',
                        used: spent,
                        remaining: b.amount - spent,
                      );
                    }
                  }
                }
              }
            } else {
              if (SmsParser.isFinancialMessage(message.sender, message.body)) {
                final db = ref.read(databaseProvider);
                await db.into(db.unrecognizedSms).insert(
                      UnrecognizedSmsCompanion.insert(
                        sender: message.sender,
                        body: message.body,
                        receivedAt: message.receivedAt,
                        reason: const drift.Value(
                          'Could not extract transaction details from SMS.',
                        ),
                      ),
                    );
              }
            }
          } catch (e, st) {
            debugPrint('Foreground SMS processing error: $e\n$st');
          }
        };
      }
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

    final db = ref.read(databaseProvider);

    // Ensure any previously inserted SMS transactions with missing or 'Cash' paymentMethod are updated to 'UPI'
    try {
      await db.customStatement(
        "UPDATE transactions SET payment_method = 'UPI' WHERE original_sms IS NOT NULL AND (payment_method IS NULL OR payment_method = 'Cash' OR payment_method = '');",
      );
    } catch (e) {
      debugPrint('Error updating legacy SMS transactions: $e');
    }

    // Check if a new month has started and send monthly summary notification
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
