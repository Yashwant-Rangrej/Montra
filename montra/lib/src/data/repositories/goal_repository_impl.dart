import 'package:drift/drift.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/goal_repository.dart';
import '../database/database.dart';

class GoalRepositoryImpl implements GoalRepository {
  final AppDatabase _db;

  GoalRepositoryImpl(this._db);

  GoalEntity _mapGoalToEntity(Goal goal) {
    return GoalEntity(
      id: goal.id,
      name: goal.name,
      targetAmount: goal.targetAmount,
      savedAmount: goal.savedAmount,
      targetDate: goal.targetDate,
      color: goal.color,
      icon: goal.icon,
      createdAt: goal.createdAt,
    );
  }

  GoalsCompanion _mapEntityToGoal(GoalEntity entity) {
    return GoalsCompanion(
      id: entity.id == 0 ? const Value.absent() : Value(entity.id),
      name: Value(entity.name),
      targetAmount: Value(entity.targetAmount),
      savedAmount: Value(entity.savedAmount),
      targetDate: Value(entity.targetDate),
      color: Value(entity.color),
      icon: Value(entity.icon),
      createdAt: Value(entity.createdAt),
    );
  }

  @override
  Future<List<GoalEntity>> getGoals() async {
    final goals = await _db.select(_db.goals).get();
    return goals.map(_mapGoalToEntity).toList();
  }

  @override
  Future<GoalEntity?> getGoalById(int id) async {
    final query = _db.select(_db.goals)..where((t) => t.id.equals(id));
    final goal = await query.getSingleOrNull();
    if (goal == null) return null;
    return _mapGoalToEntity(goal);
  }

  @override
  Future<int> insertGoal(GoalEntity goal) async {
    final companion = _mapEntityToGoal(goal);
    return await _db.into(_db.goals).insert(companion);
  }

  @override
  Future<bool> updateGoal(GoalEntity goal) async {
    final companion = _mapEntityToGoal(goal);
    return await _db.update(_db.goals).replace(companion);
  }

  @override
  Future<int> deleteGoal(int id) async {
    return await (_db.delete(_db.goals)..where((t) => t.id.equals(id))).go();
  }

  @override
  Stream<List<GoalEntity>> watchGoals() {
    return _db.select(_db.goals).watch().map((goals) {
      return goals.map(_mapGoalToEntity).toList();
    });
  }
}
