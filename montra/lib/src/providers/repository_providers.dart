import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../data/database/database.dart';
import '../data/repositories/account_repository_impl.dart';
import '../data/repositories/budget_repository_impl.dart';
import '../data/repositories/category_repository_impl.dart';
import '../data/repositories/transaction_repository_impl.dart';
import '../domain/repositories/account_repository.dart';
import '../domain/repositories/budget_repository.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/repositories/transaction_repository.dart';
import '../domain/repositories/goal_repository.dart';

import '../data/repositories/goal_repository_impl.dart';

// Database Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Repository Providers
final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepositoryImpl(ref.watch(databaseProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(databaseProvider));
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(ref.watch(databaseProvider));
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepositoryImpl(ref.watch(databaseProvider));
});

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepositoryImpl(ref.watch(databaseProvider));
});

