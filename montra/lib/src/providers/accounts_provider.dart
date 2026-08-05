import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/account_entity.dart';
import 'repository_providers.dart';

final accountsProvider = FutureProvider<List<AccountEntity>>((ref) async {
  final repository = ref.watch(accountRepositoryProvider);
  return repository.getAllAccounts();
});
