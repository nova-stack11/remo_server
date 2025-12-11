class MarkReadRequest {
  final String conversationId;
  final String? messageId; // If provided, mark all messages up to this ID as read

  MarkReadRequest({
    required this.conversationId,
    this.messageId,
  });

  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      if (messageId != null) 'messageId': messageId,
    };
  }

  factory MarkReadRequest.fromMap(Map<String, dynamic> map) {
    return MarkReadRequest(
      conversationId: map['conversationId'] as String,
      messageId: map['messageId'] as String?,
    );
  }
}
