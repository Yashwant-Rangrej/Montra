import 'package:drift/drift.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../database/database.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final AppDatabase db;

  TransactionRepositoryImpl(this.db);

  TransactionEntity _mapToEntity(Transaction transaction) {
    return TransactionEntity(
      id: transaction.id,
      amount: transaction.amount,
      type: transaction.type,
      merchant: transaction.merchant,
      categoryId: transaction.categoryId,
      paymentMethod: transaction.paymentMethod,
      accountId: transaction.accountId,
      targetAccountId: transaction.targetAccountId,
      transactionDate: transaction.transactionDate,
      notes: transaction.notes,
      originalSms: transaction.originalSms,
      bankTransactionId: transaction.bankTransactionId,
      receiptAttachment: transaction.receiptAttachment,
    );
  }

  @override
  Future<List<TransactionEntity>> getAllTransactions() async {
    final transactions = await db.select(db.transactions).get();
    return transactions.map(_mapToEntity).toList();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByAccountId(int accountId) async {
    final query = db.select(db.transactions)..where((t) => t.accountId.equals(accountId) | t.targetAccountId.equals(accountId));
    final transactions = await query.get();
    return transactions.map(_mapToEntity).toList();
  }

  @override
  Future<TransactionEntity?> getTransactionById(int id) async {
    final transaction = await (db.select(db.transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
    return transaction != null ? _mapToEntity(transaction) : null;
  }

  @override
  Future<int> insertTransaction(TransactionEntity transaction) async {
    return await db.into(db.transactions).insert(
      TransactionsCompanion.insert(
        amount: transaction.amount,
        type: transaction.type,
        merchant: Value(transaction.merchant),
        categoryId: Value(transaction.categoryId),
        paymentMethod: Value(transaction.paymentMethod),
        accountId: transaction.accountId,
        targetAccountId: Value(transaction.targetAccountId),
        transactionDate: transaction.transactionDate,
        notes: Value(transaction.notes),
        originalSms: Value(transaction.originalSms),
        bankTransactionId: Value(transaction.bankTransactionId),
      ),
    );
  }

  @override
  Future<bool> updateTransaction(TransactionEntity transaction) async {
    return await db.update(db.transactions).replace(
      TransactionsCompanion(
        id: Value(transaction.id),
        amount: Value(transaction.amount),
        type: Value(transaction.type),
        merchant: Value(transaction.merchant),
        categoryId: Value(transaction.categoryId),
        paymentMethod: Value(transaction.paymentMethod),
        accountId: Value(transaction.accountId),
        targetAccountId: Value(transaction.targetAccountId),
        transactionDate: Value(transaction.transactionDate),
        notes: Value(transaction.notes),
        originalSms: Value(transaction.originalSms),
        bankTransactionId: Value(transaction.bankTransactionId),
      ),
    );
  }

  @override
  Future<int> deleteTransaction(int id) async {
    return await (db.delete(db.transactions)..where((t) => t.id.equals(id))).go();
  }
}
