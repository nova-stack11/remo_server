class ChatMessageRequest {
  final String conversationId;
  final String? receiverId; // For direct messages (can help find/create conversation)
  final String content;
  final String type; // 'text', 'image', 'gif', 'voice', 'gift'
  final Map<String, dynamic>? metadata;
  final String? replyToMessageId;

  ChatMessageRequest({
    required this.conversationId,
    this.receiverId,
    required this.content,
    required this.type,
    this.metadata,
    this.replyToMessageId,
  });

  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      if (receiverId != null) 'receiverId': receiverId,
      'content': content,
      'type': type,
      if (metadata != null) 'metadata': metadata,
      if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
    };
  }

  factory ChatMessageRequest.fromMap(Map<String, dynamic> map) {
    return ChatMessageRequest(
      conversationId: map['conversationId'] as String,
      receiverId: map['receiverId'] as String?,
      content: map['content'] as String,
      type: map['type'] as String,
      metadata: map['metadata'] as Map<String, dynamic>?,
      replyToMessageId: map['replyToMessageId'] as String?,
    );
  }
}
