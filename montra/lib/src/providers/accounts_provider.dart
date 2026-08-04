import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/account_entity.dart';
import 'repository_providers.dart';

final accountsProvider = FutureProvider<List<AccountEntity>>((ref) async {
  final repo = ref.watch(accountRepositoryProvider);
  return await repo.getAllAccounts();
});
