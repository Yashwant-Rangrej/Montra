import '../entities/account_entity.dart';

abstract class AccountRepository {
  Future<List<AccountEntity>> getAllAccounts();
  Future<AccountEntity?> getAccountById(int id);
  Future<AccountEntity?> getAccountByBankName(String bankName);
  Future<int> insertAccount(AccountEntity account);
  Future<void> updateAccount(AccountEntity account);
  Future<void> deleteAccount(int id);
}
