class FriendEventResponse {
  final String type; // 'request_received', 'request_accepted', 'request_declined', 'status_changed', 'unfriended'
  final Map<String, dynamic> data; // User info, request details, status info

  FriendEventResponse({
    required this.type,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'data': data,
    };
  }

  factory FriendEventResponse.fromMap(Map<String, dynamic> map) {
    return FriendEventResponse(
      type: map['type'] as String,
      data: map['data'] as Map<String, dynamic>,
    );
  }
}
