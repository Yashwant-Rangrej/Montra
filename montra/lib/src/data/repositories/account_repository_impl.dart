import 'package:drift/drift.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../database/database.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AppDatabase _db;

  AccountRepositoryImpl(this._db);

  AccountEntity _mapAccount(Account account) {
    return AccountEntity(
      id: account.id,
      bankName: account.bankName,
      totalTransactions: account.totalTransactions,
      totalIncome: account.totalIncome,
      totalExpenses: account.totalExpenses,
      lastTransactionDate: account.lastTransactionDate,
      availableBalance: account.availableBalance,
      icon: account.icon,
      color: account.color,
      isHidden: account.isHidden,
    );
  }

  @override
  Future<List<AccountEntity>> getAllAccounts() async {
    final query = _db.select(_db.accounts);
    final results = await query.get();
    return results.map(_mapAccount).toList();
  }

  @override
  Future<AccountEntity?> getAccountById(int id) async {
    final query = _db.select(_db.accounts)..where((t) => t.id.equals(id));
    final result = await query.getSingleOrNull();
    return result != null ? _mapAccount(result) : null;
  }

  @override
  Future<AccountEntity?> getAccountByBankName(String bankName) async {
    final query = _db.select(_db.accounts)..where((t) => t.bankName.equals(bankName));
    final result = await query.getSingleOrNull();
    return result != null ? _mapAccount(result) : null;
  }

  @override
  Future<int> insertAccount(AccountEntity account) async {
    return _db.into(_db.accounts).insert(
          AccountsCompanion(
            bankName: Value(account.bankName),
            totalTransactions: Value(account.totalTransactions),
            totalIncome: Value(account.totalIncome),
            totalExpenses: Value(account.totalExpenses),
            lastTransactionDate: Value(account.lastTransactionDate),
            availableBalance: Value(account.availableBalance),
            icon: Value(account.icon),
            color: Value(account.color),
            isHidden: Value(account.isHidden),
          ),
        );
  }

  @override
  Future<void> updateAccount(AccountEntity account) async {
    await _db.update(_db.accounts).replace(
          AccountsCompanion(
            id: Value(account.id),
            bankName: Value(account.bankName),
            totalTransactions: Value(account.totalTransactions),
            totalIncome: Value(account.totalIncome),
            totalExpenses: Value(account.totalExpenses),
            lastTransactionDate: Value(account.lastTransactionDate),
            availableBalance: Value(account.availableBalance),
            icon: Value(account.icon),
            color: Value(account.color),
            isHidden: Value(account.isHidden),
          ),
        );
  }

  @override
  Future<void> deleteAccount(int id) async {
    await (_db.delete(_db.accounts)..where((t) => t.id.equals(id))).go();
  }
}
