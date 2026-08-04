import '../entities/account_entity.dart';

abstract class AccountRepository {
  Future<List<AccountEntity>> getAllAccounts();
  Future<AccountEntity?> getAccountById(int id);
  Future<int> insertAccount(AccountEntity account);
  Future<bool> updateAccount(AccountEntity account);
  Future<int> deleteAccount(int id);
}
