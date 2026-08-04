class GoalEntity {
  final int id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime? targetDate;
  final String? color;
  final String? icon;
  final DateTime createdAt;

  GoalEntity({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    this.targetDate,
    this.color,
    this.icon,
    required this.createdAt,
  });

  GoalEntity copyWith({
    int? id,
    String? name,
    double? targetAmount,
    double? savedAmount,
    DateTime? targetDate,
    String? color,
    String? icon,
    DateTime? createdAt,
  }) {
    return GoalEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      targetDate: targetDate ?? this.targetDate,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
