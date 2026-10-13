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
      accountId: transaction.accountId,
      targetAccountId: transaction.targetAccountId,
      availableBalance: transaction.availableBalance,
      transactionDate: transaction.transactionDate,
      notes: transaction.notes,
      originalSms: transaction.originalSms,
      bankTransactionId: transaction.bankTransactionId,
      receiptAttachment: transaction.receiptAttachment,
      paymentMethod: transaction.paymentMethod,
    );
  }

  @override
  Future<List<TransactionEntity>> getAllTransactions() async {
    final transactions = await db.select(db.transactions).get();
    return transactions.map(_mapToEntity).toList();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByAccount(int accountId) async {
    final query = db.select(db.transactions)..where((t) => t.accountId.equals(accountId));
    final transactions = await query.get();
    return transactions.map(_mapToEntity).toList();
  }

  @override
  Future<TransactionEntity?> getTransactionById(int id) async {
    final transaction = await (db.select(db.transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
    return transaction != null ? _mapToEntity(transaction) : null;
  }

  String _resolvePaymentMethod(TransactionEntity transaction) {
    final method = transaction.paymentMethod?.trim();
    if (transaction.originalSms != null) {
      if (method != null && method.isNotEmpty) {
        if (method == 'Cash') {
          final smsLower = transaction.originalSms!.toLowerCase();
          final isAtm = smsLower.contains('atm') ||
              smsLower.contains('cash withdrawal') ||
              smsLower.contains('wtd') ||
              smsLower.contains('withdrawn');
          return isAtm ? 'Cash' : 'UPI';
        }
        return method;
      }
      return 'UPI';
    }
    return (method != null && method.isNotEmpty) ? method : 'Cash';
  }

  @override
  Future<int> insertTransaction(TransactionEntity transaction) async {
    final resolvedMethod = _resolvePaymentMethod(transaction);
    return await db.into(db.transactions).insert(
      TransactionsCompanion.insert(
        amount: transaction.amount,
        type: transaction.type,
        merchant: Value(transaction.merchant),
        categoryId: Value(transaction.categoryId),
        paymentMethod: Value(resolvedMethod),
        accountId: transaction.accountId,
        targetAccountId: Value(transaction.targetAccountId),
        availableBalance: Value(transaction.availableBalance),
        transactionDate: transaction.transactionDate,
        notes: Value(transaction.notes),
        originalSms: Value(transaction.originalSms),
        bankTransactionId: Value(transaction.bankTransactionId),
      ),
    );
  }

  @override
  Future<bool> updateTransaction(TransactionEntity transaction) async {
    final resolvedMethod = _resolvePaymentMethod(transaction);
    return await db.update(db.transactions).replace(
      TransactionsCompanion(
        id: Value(transaction.id),
        amount: Value(transaction.amount),
        type: Value(transaction.type),
        merchant: Value(transaction.merchant),
        categoryId: Value(transaction.categoryId),
        paymentMethod: Value(resolvedMethod),
        accountId: Value(transaction.accountId),
        targetAccountId: Value(transaction.targetAccountId),
        availableBalance: Value(transaction.availableBalance),
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

  @override
  Stream<List<TransactionEntity>> watchTransactions() {
    return (db.select(db.transactions)
        ..orderBy([(t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc)]))
        .watch()
        .map((txList) => txList.map(_mapToEntity).toList());
  }
}
