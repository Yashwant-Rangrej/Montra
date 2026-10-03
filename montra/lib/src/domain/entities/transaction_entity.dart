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

  TransactionEntity copyWith({
    int? id,
    double? amount,
    String? type,
    String? merchant,
    int? categoryId,
    String? paymentMethod,
    int? accountId,
    int? targetAccountId,
    double? availableBalance,
    DateTime? transactionDate,
    String? notes,
    String? originalSms,
    String? bankTransactionId,
    String? receiptAttachment,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      merchant: merchant ?? this.merchant,
      categoryId: categoryId ?? this.categoryId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      accountId: accountId ?? this.accountId,
      targetAccountId: targetAccountId ?? this.targetAccountId,
      availableBalance: availableBalance ?? this.availableBalance,
      transactionDate: transactionDate ?? this.transactionDate,
      notes: notes ?? this.notes,
      originalSms: originalSms ?? this.originalSms,
      bankTransactionId: bankTransactionId ?? this.bankTransactionId,
      receiptAttachment: receiptAttachment ?? this.receiptAttachment,
    );
  }
}
