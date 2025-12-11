class ChatMessageStatusUpdate {
  final String messageId;
  final String status; // 'delivered', 'seen'
  final String userId; // Who updated the status
  final String timestamp; // ISO 8601 format

  ChatMessageStatusUpdate({
    required this.messageId,
    required this.status,
    required this.userId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'status': status,
      'userId': userId,
      'timestamp': timestamp,
    };
  }

  factory ChatMessageStatusUpdate.fromMap(Map<String, dynamic> map) {
    return ChatMessageStatusUpdate(
      messageId: map['messageId'] as String,
      status: map['status'] as String,
      userId: map['userId'] as String,
      timestamp: map['timestamp'] as String,
    );
  }
}
