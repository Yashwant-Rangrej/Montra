import 'package:drift/drift.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../database/database.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final AppDatabase db;

  BudgetRepositoryImpl(this.db);

  BudgetEntity _mapToEntity(Budget budget) {
    return BudgetEntity(
      id: budget.id,
      amount: budget.amount,
      month: budget.month,
      year: budget.year,
      categoryId: budget.categoryId,
    );
  }

  @override
  Future<List<BudgetEntity>> getAllBudgets() async {
    final budgets = await db.select(db.budgets).get();
    return budgets.map(_mapToEntity).toList();
  }

  @override
  Future<List<BudgetEntity>> getBudgetsByMonthAndYear(int month, int year) async {
    final query = db.select(db.budgets)..where((b) => b.month.equals(month) & b.year.equals(year));
    final budgets = await query.get();
    return budgets.map(_mapToEntity).toList();
  }

  @override
  Future<BudgetEntity?> getBudgetById(int id) async {
    final budget = await (db.select(db.budgets)..where((b) => b.id.equals(id))).getSingleOrNull();
    return budget != null ? _mapToEntity(budget) : null;
  }

  @override
  Future<int> insertBudget(BudgetEntity budget) async {
    return await db.into(db.budgets).insert(
      BudgetsCompanion.insert(
        amount: budget.amount,
        month: budget.month,
        year: budget.year,
        categoryId: Value(budget.categoryId),
      ),
    );
  }

  @override
  Future<bool> updateBudget(BudgetEntity budget) async {
    return await db.update(db.budgets).replace(
      BudgetsCompanion(
        id: Value(budget.id),
        amount: Value(budget.amount),
        month: Value(budget.month),
        year: Value(budget.year),
        categoryId: Value(budget.categoryId),
      ),
    );
  }

  @override
  Future<int> deleteBudget(int id) async {
    return await (db.delete(db.budgets)..where((b) => b.id.equals(id))).go();
  }

  @override
  Stream<List<BudgetEntity>> watchBudgets() {
    return db.select(db.budgets).watch().map((budgets) {
      return budgets.map(_mapToEntity).toList();
    });
  }
}
