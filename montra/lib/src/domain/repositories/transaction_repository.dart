import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<List<TransactionEntity>> getAllTransactions();
  Future<List<TransactionEntity>> getTransactionsByBank(String bankName);
  Future<TransactionEntity?> getTransactionById(int id);
  Future<int> insertTransaction(TransactionEntity transaction);
  Future<bool> updateTransaction(TransactionEntity transaction);
  Future<int> deleteTransaction(int id);
}
