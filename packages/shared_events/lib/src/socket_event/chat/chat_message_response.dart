class ChatMessageResponse {
  final String id;
  final String conversationId;
  final String fromUserId;
  final String content;
  final String type; // 'text', 'image', 'gif', 'voice', 'gift'
  final Map<String, dynamic>? metadata;
  final String? replyToMessageId;
  final String timestamp; // ISO 8601 format
  final String status; // 'sent', 'delivered', 'seen'

  ChatMessageResponse({
    required this.id,
    required this.conversationId,
    required this.fromUserId,
    required this.content,
    required this.type,
    this.metadata,
    this.replyToMessageId,
    required this.timestamp,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'fromUserId': fromUserId,
      'content': content,
      'type': type,
      if (metadata != null) 'metadata': metadata,
      if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
      'timestamp': timestamp,
      'status': status,
    };
  }

  factory ChatMessageResponse.fromMap(Map<String, dynamic> map) {
    return ChatMessageResponse(
      id: map['id'] as String,
      conversationId: map['conversationId'] as String,
      fromUserId: map['fromUserId'] as String,
      content: map['content'] as String,
      type: map['type'] as String,
      metadata: map['metadata'] as Map<String, dynamic>?,
      replyToMessageId: map['replyToMessageId'] as String?,
      timestamp: map['timestamp'] as String,
      status: map['status'] as String,
    );
  }
}
