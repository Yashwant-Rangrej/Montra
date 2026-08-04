class AccountEntity {
  final int id;
  final String name;
  final String type; // Bank, Cash, Credit Card, Salary, Custom
  final double initialBalance;
  final String? color;
  final String? icon;
  final DateTime createdAt;

  AccountEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.initialBalance,
    this.color,
    this.icon,
    required this.createdAt,
  });
}
