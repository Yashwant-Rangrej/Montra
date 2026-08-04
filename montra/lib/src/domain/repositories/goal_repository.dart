import '../entities/goal_entity.dart';

abstract class GoalRepository {
  Future<List<GoalEntity>> getGoals();
  Future<GoalEntity?> getGoalById(int id);
  Future<int> insertGoal(GoalEntity goal);
  Future<bool> updateGoal(GoalEntity goal);
  Future<int> deleteGoal(int id);
  Stream<List<GoalEntity>> watchGoals();
}
