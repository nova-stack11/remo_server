class FriendRequestEvent {
  final String action; // 'send', 'accept', 'decline', 'cancel'
  final String? targetUserId; // Required for 'send'
  final String? requestId; // Required for 'accept', 'decline', 'cancel'
  final String? message; // Optional message with 'send' request

  FriendRequestEvent({
    required this.action,
    this.targetUserId,
    this.requestId,
    this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'action': action,
      if (targetUserId != null) 'targetUserId': targetUserId,
      if (requestId != null) 'requestId': requestId,
      if (message != null) 'message': message,
    };
  }

  factory FriendRequestEvent.fromMap(Map<String, dynamic> map) {
    return FriendRequestEvent(
      action: map['action'] as String,
      targetUserId: map['targetUserId'] as String?,
      requestId: map['requestId'] as String?,
      message: map['message'] as String?,
    );
  }
}
