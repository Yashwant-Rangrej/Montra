import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../presentation/auth/lock_screen.dart';

import '../../presentation/dashboard/dashboard_screen.dart';
import '../../presentation/transactions/transactions_screen.dart';
import '../../presentation/budgets/budgets_screen.dart';
import '../../presentation/analytics/analytics_screen.dart';
import '../../presentation/settings/settings_screen.dart';
import '../../presentation/main_scaffold.dart';
import '../../presentation/transactions/add_transaction_screen.dart';
import '../../presentation/accounts/accounts_screen.dart';
import '../../presentation/accounts/add_account_screen.dart';
import '../../presentation/goals/goals_screen.dart';
import '../../presentation/goals/add_goal_screen.dart';
import '../../presentation/budgets/add_budget_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final appRouterProvider = Provider<GoRouter>((ref) {
  final isAppLockEnabled = ref.watch(appLockEnabledProvider);
  final isUnlocked = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      if (isAppLockEnabled && !isUnlocked && state.matchedLocation != '/auth') {
        return '/auth';
      }
      if (isUnlocked && state.matchedLocation == '/auth') {
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
      path: '/add-transaction',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddTransactionScreen(),
    ),
    GoRoute(
      path: '/accounts',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AccountsScreen(),
    ),
    GoRoute(
      path: '/add-account',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddAccountScreen(),
    ),
    GoRoute(
      path: '/goals',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const GoalsScreen(),
    ),
    GoRoute(
      path: '/add-goal',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddGoalScreen(),
    ),
    GoRoute(
      path: '/add-budget',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddBudgetScreen(),
    ),
  ],
);
});
