class NotificationPayload {
  final String type;
  final String route;
  final Map<String, dynamic>? data;

  const NotificationPayload({
    required this.type,
    required this.route,
    this.data,
  });

  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    return NotificationPayload(
      type: json['type'] as String,
      route: json['route'] as String,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'route': route,
      'data': data,
    };
  }
}

enum NotificationType {
  dailySummary,
  transactionDetected,
  budgetAlert,
  weeklySummary,
  monthlySummary,
  largeExpense,
  smartInsight,
  backupReminder,
  test
}
