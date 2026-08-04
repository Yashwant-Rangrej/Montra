import '../entities/budget_entity.dart';

abstract class BudgetRepository {
  Future<List<BudgetEntity>> getAllBudgets();
  Future<List<BudgetEntity>> getBudgetsByMonthAndYear(int month, int year);
  Future<BudgetEntity?> getBudgetById(int id);
  Future<int> insertBudget(BudgetEntity budget);
  Future<bool> updateBudget(BudgetEntity budget);
  Future<int> deleteBudget(int id);
  Stream<List<BudgetEntity>> watchBudgets();
}
