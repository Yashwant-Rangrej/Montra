class CategoryEntity {
  final int id;
  final String name;
  final String type; // Income, Expense
  final String? color;
  final String? icon;

  CategoryEntity({
    required this.id,
    required this.name,
    required this.type,
    this.color,
    this.icon,
  });
}
