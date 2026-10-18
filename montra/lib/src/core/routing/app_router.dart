import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../presentation/auth/lock_screen.dart';
import '../../presentation/onboarding/onboarding_screen.dart';
import '../../presentation/splash/splash_screen.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/budget_entity.dart';

import '../../presentation/dashboard/dashboard_screen.dart';
import '../../presentation/transactions/transactions_screen.dart';
import '../../presentation/budgets/budgets_screen.dart';
import '../../presentation/analytics/analytics_screen.dart';
import '../../presentation/settings/settings_screen.dart';
import '../../presentation/notifications/notification_settings_screen.dart';
import '../../presentation/main_scaffold.dart';
import '../../presentation/transactions/add_transaction_screen.dart';
import '../../presentation/transactions/ignored_sms_screen.dart';
import '../../presentation/categories/categories_screen.dart';
import '../../presentation/categories/add_category_screen.dart';
import '../../presentation/budgets/add_budget_screen.dart';
import '../../domain/entities/category_entity.dart';
import '../../presentation/analytics/monthly_summary_screen.dart';
import '../../presentation/backup/backup_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  String _previousLocation = '/';

  String get previousLocation => _previousLocation;

  RouterNotifier(this._ref) {
    _ref.listen<bool>(appLockEnabledProvider, (_, _) => notifyListeners());
    _ref.listen<bool>(authStateProvider, (_, _) => notifyListeners());
    _ref.listen<bool>(onboardingCompletedProvider, (_, _) => notifyListeners());
  }

  void saveLocation(String loc) {
    if (loc != '/auth' && loc != '/splash' && loc.isNotEmpty) {
      _previousLocation = loc;
    }
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);
  final isAppLockEnabled = ref.read(appLockEnabledProvider);
  final isUnlocked = ref.read(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: notifier,
    // On cold launch, if lock is enabled and not yet unlocked → start at /auth.
    // Otherwise start at /splash as normal.
    initialLocation: isAppLockEnabled && !isUnlocked ? '/auth' : '/splash',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final lockEnabled = ref.read(appLockEnabledProvider);
      final unlocked = ref.read(authStateProvider);
      final onboardingDone = ref.read(onboardingCompletedProvider);

      // Save user location whenever on a valid app screen
      if (loc != '/auth' && loc != '/splash') {
        notifier.saveLocation(loc);
      }

      // Lock: if enabled and not unlocked, only /auth is allowed.
      if (lockEnabled && !unlocked) {
        if (loc != '/auth') return '/auth';
        return null;
      }

      // After unlock, restore the exact screen the user was on before lock, or home.
      if (loc == '/auth') {
        final dest = notifier.previousLocation;
        return dest.isNotEmpty && dest != '/auth' && dest != '/splash' ? dest : '/';
      }

      // Splash plays without interruption.
      if (loc == '/splash') return null;

      // Onboarding check.
      if (!onboardingDone && loc != '/onboarding') {
        return '/onboarding';
      }
      if (onboardingDone && loc == '/onboarding') {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LockScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/splash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return MainScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/transactions',
          builder: (context, state) => const TransactionsScreen(),
        ),
        GoRoute(
          path: '/budgets',
          builder: (context, state) => const BudgetsScreen(),
        ),
        GoRoute(
          path: '/analytics',
          builder: (context, state) => const AnalyticsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/notification-settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
    GoRoute(
      path: '/add-transaction',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final tx = state.extra as TransactionEntity?;
        return AddTransactionScreen(transactionToEdit: tx);
      },
    ),
    GoRoute(
      path: '/ignored-sms',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const IgnoredSmsScreen(),
    ),


    GoRoute(
      path: '/add-budget',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final budget = state.extra as BudgetEntity?;
        return AddBudgetScreen(budgetToEdit: budget);
      },
    ),
    GoRoute(
      path: '/categories',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CategoriesScreen(),
    ),
    GoRoute(
      path: '/add-category',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final category = state.extra as CategoryEntity?;
        return AddCategoryScreen(categoryToEdit: category);
      },
    ),
    GoRoute(
      path: '/monthly-summary-report',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final stats = state.extra as Map<String, dynamic>;
        return MonthlySummaryScreen(stats: stats);
      },
    ),
    GoRoute(
      path: '/backup',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BackupScreen(),
    ),
  ],
);
});
