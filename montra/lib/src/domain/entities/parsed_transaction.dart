class ParsedTransaction {
  final double amount;
  final String merchant;
  final String transactionType; // 'credit' or 'debit'
  final String paymentMethod;
  final DateTime transactionDate;
  final String bankName;
  final String? referenceNumber;
  final double? availableBalance;

  const ParsedTransaction({
    required this.amount,
    required this.merchant,
    required this.transactionType,
    required this.paymentMethod,
    required this.transactionDate,
    required this.bankName,
    this.referenceNumber,
    this.availableBalance,
  });
}
