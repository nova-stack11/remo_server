class GroupActionRequest {
  final String action; // 'create', 'add_member', 'remove_member', 'leave', 'update_info'
  final String? groupId; // Required for all actions except 'create'
  final String? groupName; // Required for 'create' and 'update_info'
  final String? avatarUrl; // Optional for 'create' and 'update_info'
  final List<String>? memberIds; // Required for 'create' and 'add_member'
  final String? targetUserId; // Required for 'remove_member'
  final Map<String, dynamic>? metadata; // Additional data

  GroupActionRequest({
    required this.action,
    this.groupId,
    this.groupName,
    this.avatarUrl,
    this.memberIds,
    this.targetUserId,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'action': action,
      if (groupId != null) 'groupId': groupId,
      if (groupName != null) 'groupName': groupName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (memberIds != null) 'memberIds': memberIds,
      if (targetUserId != null) 'targetUserId': targetUserId,
      if (metadata != null) 'metadata': metadata,
    };
  }

  factory GroupActionRequest.fromMap(Map<String, dynamic> map) {
    return GroupActionRequest(
      action: map['action'] as String,
      groupId: map['groupId'] as String?,
      groupName: map['groupName'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      memberIds: (map['memberIds'] as List<dynamic>?)?.cast<String>(),
      targetUserId: map['targetUserId'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }
}
