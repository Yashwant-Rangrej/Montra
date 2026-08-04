class BudgetEntity {
  final int id;
  final double amount;
  final int month;
  final int year;
  final int? categoryId; // If null, this is the total budget for the month

  BudgetEntity({
    required this.id,
    required this.amount,
    required this.month,
    required this.year,
    this.categoryId,
  });
}
