import 'package:drift/drift.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../database/database.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AppDatabase db;

  AccountRepositoryImpl(this.db);

  AccountEntity _mapToEntity(Account account) {
    return AccountEntity(
      id: account.id,
      name: account.name,
      type: account.type,
      initialBalance: account.initialBalance,
      color: account.color,
      icon: account.icon,
      createdAt: account.createdAt,
    );
  }

  @override
  Future<List<AccountEntity>> getAllAccounts() async {
    final accounts = await db.select(db.accounts).get();
    return accounts.map(_mapToEntity).toList();
  }

  @override
  Future<AccountEntity?> getAccountById(int id) async {
    final query = db.select(db.accounts)..where((a) => a.id.equals(id));
    final account = await query.getSingleOrNull();
    return account != null ? _mapToEntity(account) : null;
  }

  @override
  Future<int> insertAccount(AccountEntity account) async {
    return await db.into(db.accounts).insert(AccountsCompanion.insert(
      name: account.name,
      type: account.type,
      initialBalance: account.initialBalance,
      color: Value(account.color),
      icon: Value(account.icon),
      createdAt: account.createdAt,
    ));
  }

  @override
  Future<bool> updateAccount(AccountEntity account) async {
    return await db.update(db.accounts).replace(AccountsCompanion(
      id: Value(account.id),
      name: Value(account.name),
      type: Value(account.type),
      initialBalance: Value(account.initialBalance),
      color: Value(account.color),
      icon: Value(account.icon),
      createdAt: Value(account.createdAt),
    ));
  }

  @override
  Future<int> deleteAccount(int id) async {
    return await (db.delete(db.accounts)..where((a) => a.id.equals(id))).go();
  }
}
