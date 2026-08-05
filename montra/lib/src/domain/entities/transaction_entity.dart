class TransactionEntity {
  final int id;
  final double amount;
  final String type; // Expense, Income, Transfer
  final String? merchant;
  final int? categoryId;
  final String? paymentMethod;
  final int accountId;
  final int? targetAccountId;
  final double? availableBalance;
  final DateTime transactionDate;
  final String? notes;
  final String? originalSms;
  final String? bankTransactionId;
  final String? receiptAttachment;

  TransactionEntity({
    required this.id,
    required this.amount,
    required this.type,
    this.merchant,
    this.categoryId,
    this.paymentMethod,
    required this.accountId,
    this.targetAccountId,
    this.availableBalance,
    required this.transactionDate,
    this.notes,
    this.originalSms,
    this.bankTransactionId,
    this.receiptAttachment,
  });
}
