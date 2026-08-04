import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/category_entity.dart';
import 'repository_providers.dart';
import 'transactions_provider.dart';
import 'categories_provider.dart';

class BudgetWithProgress {
  final BudgetEntity budget;
  final CategoryEntity? category;
  final double spentAmount;

  BudgetWithProgress({
    required this.budget,
    this.category,
    required this.spentAmount,
  });
}

final budgetsProvider = StreamProvider<List<BudgetEntity>>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return repository.watchBudgets();
});

final budgetsProgressProvider = Provider<AsyncValue<List<BudgetWithProgress>>>((ref) {
  final budgetsAsync = ref.watch(budgetsProvider);
  final transactionsAsync = ref.watch(transactionsProvider);
  final categoriesAsync = ref.watch(categoriesProvider);

  if (budgetsAsync.isLoading || transactionsAsync.isLoading || categoriesAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (budgetsAsync.hasError) return AsyncValue.error(budgetsAsync.error!, budgetsAsync.stackTrace!);
  if (transactionsAsync.hasError) return AsyncValue.error(transactionsAsync.error!, transactionsAsync.stackTrace!);

  final budgets = budgetsAsync.value ?? [];
  final transactions = transactionsAsync.value ?? [];
  final categories = categoriesAsync.value ?? [];

  final now = DateTime.now();
  final currentMonthTransactions = transactions.where((t) => t.transactionDate.month == now.month && t.transactionDate.year == now.year && t.type == 'Expense').toList();

  final result = budgets.where((b) => b.month == now.month && b.year == now.year).map((budget) {
    CategoryEntity? category;
    double spent = 0;

    if (budget.categoryId != null) {
      category = categories.cast<CategoryEntity?>().firstWhere((c) => c?.id == budget.categoryId, orElse: () => null);
      spent = currentMonthTransactions.where((t) => t.categoryId == budget.categoryId).fold(0.0, (sum, item) => sum + item.amount);
    } else {
      spent = currentMonthTransactions.fold(0.0, (sum, item) => sum + item.amount);
    }

    return BudgetWithProgress(
      budget: budget,
      category: category,
      spentAmount: spent,
    );
  }).toList();

  return AsyncValue.data(result);
});
