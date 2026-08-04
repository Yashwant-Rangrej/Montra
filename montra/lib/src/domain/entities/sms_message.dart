class SmsMessage {
  final String sender;
  final String body;
  final DateTime receivedAt;
  final String? subscriptionId;

  const SmsMessage({
    required this.sender,
    required this.body,
    required this.receivedAt,
    this.subscriptionId,
  });

  factory SmsMessage.fromMap(Map<String, dynamic> map) {
    return SmsMessage(
      sender: map['sender'] ?? '',
      body: map['body'] ?? '',
      receivedAt: map['receivedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['receivedAt'] as int)
          : DateTime.now(),
      subscriptionId: map['subscriptionId']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'body': body,
      'receivedAt': receivedAt.millisecondsSinceEpoch,
      'subscriptionId': subscriptionId,
    };
  }
}
