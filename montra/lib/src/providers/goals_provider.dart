import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/goal_entity.dart';
import 'repository_providers.dart';

final goalsProvider = StreamProvider<List<GoalEntity>>((ref) {
  final repository = ref.watch(goalRepositoryProvider);
  return repository.watchGoals();
});
