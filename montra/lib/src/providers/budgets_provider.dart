import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/budget_entity.dart';
import '../domain/entities/category_entity.dart';
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
  
  // Deduplicate standard monthly budgets by category to only keep the latest one
  final standardBudgets = budgets.where((b) => b.startDate == null || b.endDate == null).toList();
  // Sort descending by id to get the latest
  standardBudgets.sort((a, b) => b.id.compareTo(a.id));
  
  final Map<int?, BudgetEntity> latestBudgets = {};
  for (var b in standardBudgets) {
    if (!latestBudgets.containsKey(b.categoryId)) {
      latestBudgets[b.categoryId] = b;
    }
  }

  final result = budgets.where((b) {
    if (b.startDate != null && b.endDate != null) {
      // Custom date range: show it if we are currently within or before it
      return now.isBefore(b.endDate!.add(const Duration(days: 1))); 
    }
    // Monthly budgets always show and auto-reset for the current month
    // Only show if it is the latest one for its category
    return latestBudgets[b.categoryId]?.id == b.id;
  }).map((budget) {
    CategoryEntity? category;
    double spent = 0;

    // Filter transactions for this specific budget's time period
    final budgetTransactions = transactions.where((t) {
      if (t.type != 'Expense') return false;
      
      if (budget.startDate != null && budget.endDate != null) {
        // Custom range: use its fixed dates
        return t.transactionDate.isAfter(budget.startDate!.subtract(const Duration(days: 1))) && 
               t.transactionDate.isBefore(budget.endDate!.add(const Duration(days: 1)));
      } else {
        // Monthly budget: automatically resets every month by looking only at CURRENT month
        return t.transactionDate.month == now.month && t.transactionDate.year == now.year;
      }
    }).toList();

    if (budget.categoryId != null) {
      category = categories.cast<CategoryEntity?>().firstWhere((c) => c?.id == budget.categoryId, orElse: () => null);
      spent = budgetTransactions.where((t) => t.categoryId == budget.categoryId).fold(0.0, (sum, item) => sum + item.amount);
    } else {
      spent = budgetTransactions.fold(0.0, (sum, item) => sum + item.amount);
    }

    return BudgetWithProgress(
      budget: budget,
      category: category,
      spentAmount: spent,
    );
  }).toList();

  return AsyncValue.data(result);
});
