class AccountEntity {
  final int id;
  final String bankName;
  final int totalTransactions;
  final double totalIncome;
  final double totalExpenses;
  final DateTime? lastTransactionDate;
  final double? availableBalance;
  final String? icon;
  final String? color;
  final bool isHidden;

  AccountEntity({
    required this.id,
    required this.bankName,
    required this.totalTransactions,
    required this.totalIncome,
    required this.totalExpenses,
    this.lastTransactionDate,
    this.availableBalance,
    this.icon,
    this.color,
    this.isHidden = false,
  });

  AccountEntity copyWith({
    int? id,
    String? bankName,
    int? totalTransactions,
    double? totalIncome,
    double? totalExpenses,
    DateTime? lastTransactionDate,
    double? availableBalance,
    String? icon,
    String? color,
    bool? isHidden,
  }) {
    return AccountEntity(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      lastTransactionDate: lastTransactionDate ?? this.lastTransactionDate,
      availableBalance: availableBalance ?? this.availableBalance,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isHidden: isHidden ?? this.isHidden,
    );
  }
}
