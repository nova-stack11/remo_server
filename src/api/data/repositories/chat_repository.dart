import '../datasource/chat_datasource.dart';

class ChatRepository {
  ChatRepository({required this.datasource});

  final ChatDataSource datasource;

  /// Send a message to a conversation
  /// For direct chats, automatically creates conversation if it doesn't exist
  /// For group chats, validates that the sender is a member
  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String fromUserId,
    required String content,
    required String type,
    Map<String, dynamic>? metadata,
    String? replyToMessageId,
    String? receiverId, // For direct chats
  }) async {
    // Check if conversation exists
    final conversation = await datasource.getConversation(
      conversationId: conversationId,
    );

    String actualConversationId = conversationId;

    // If conversation doesn't exist and we have a receiverId, create direct conversation
    if (conversation == null && receiverId != null) {
      final directConv = await getOrCreateDirectConversation(
        user1Id: fromUserId,
        user2Id: receiverId,
      );
      actualConversationId = directConv['id'] as String;
    } else if (conversation != null) {
      // For existing conversations (especially groups), validate membership
      if (conversation['type'] == 'group') {
        final isMember = await datasource.isConversationMember(
          conversationId: conversationId,
          userId: fromUserId,
        );

        if (!isMember) {
          throw Exception('User is not a member of this conversation');
        }
      }
      // For direct chats, no need to validate membership
    } else {
      // Conversation doesn't exist and no receiverId provided
      throw Exception('Conversation not found');
    }

    // Validate reply message exists if specified
    if (replyToMessageId != null) {
      final replyMessage = await datasource.getMessage(
        messageId: replyToMessageId,
      );
      if (replyMessage == null) {
        throw Exception('Reply message not found');
      }
      if (replyMessage['conversation_id'] != actualConversationId) {
        throw Exception('Reply message is not in this conversation');
      }
    }

    // Create the message
    final message = await datasource.createMessage(
      conversationId: actualConversationId,
      fromUserId: fromUserId,
      content: content,
      type: type,
      metadata: metadata,
      replyToMessageId: replyToMessageId,
    );

    return message;
  }

  /// Get or create a direct conversation between two users
  Future<Map<String, dynamic>> getOrCreateDirectConversation({
    required String user1Id,
    required String user2Id,
  }) async {
    if (user1Id == user2Id) {
      throw Exception('Cannot create conversation with yourself');
    }

    // Try to find existing direct conversation
    final existing = await datasource.findDirectConversation(
      user1Id: user1Id,
      user2Id: user2Id,
    );

    if (existing != null) {
      return existing;
    }

    // Create new direct conversation
    final conversation = await datasource.createConversation(
      type: 'direct',
      name: null, // Direct chats don't have names
      avatarUrl: null,
      createdBy: user1Id,
      memberIds: [user1Id, user2Id],
    );

    return conversation;
  }

  /// Get messages for a conversation with pagination
  /// Validates that the user is a member before allowing access
  Future<List<Map<String, dynamic>>> getConversationMessages({
    required String conversationId,
    required String userId,
    int page = 1,
    int pageSize = 50,
  }) async {
    // Validate user is member
    final isMember = await datasource.isConversationMember(
      conversationId: conversationId,
      userId: userId,
    );

    if (!isMember) {
      throw Exception('User is not a member of this conversation');
    }

    final offset = (page - 1) * pageSize;
    return datasource.getMessages(
      conversationId: conversationId,
      limit: pageSize,
      offset: offset,
    );
  }

  /// Get messages before a specific message (for pagination)
  Future<List<Map<String, dynamic>>> getMessagesBefore({
    required String conversationId,
    required String userId,
    required String beforeMessageId,
    int limit = 50,
  }) async {
    // Validate user is member
    final isMember = await datasource.isConversationMember(
      conversationId: conversationId,
      userId: userId,
    );

    if (!isMember) {
      throw Exception('User is not a member of this conversation');
    }

    return datasource.getMessagesBefore(
      conversationId: conversationId,
      beforeMessageId: beforeMessageId,
      limit: limit,
    );
  }

  /// Get all conversations for a user with unread counts
  Future<List<Map<String, dynamic>>> getUserConversations({
    required String userId,
  }) async {
    return datasource.getUserConversations(userId: userId);
  }

  /// Create a group conversation
  Future<Map<String, dynamic>> createGroupConversation({
    required String name,
    required String createdBy,
    required List<String> memberIds,
    String? avatarUrl,
  }) async {
    if (name.isEmpty) {
      throw Exception('Group name cannot be empty');
    }

    if (memberIds.length < 2) {
      throw Exception('Group must have at least 2 members');
    }

    // Ensure creator is in the member list
    if (!memberIds.contains(createdBy)) {
      memberIds.add(createdBy);
    }

    final conversation = await datasource.createConversation(
      type: 'group',
      name: name,
      avatarUrl: avatarUrl,
      createdBy: createdBy,
      memberIds: memberIds,
    );

    return conversation;
  }

  /// Add a member to a group conversation
  /// Validates that the group exists and the requester is a member
  Future<void> addGroupMember({
    required String groupId,
    required String userId,
    required String addedBy,
  }) async {
    // Validate conversation exists and is a group
    final conversation = await datasource.getConversation(
      conversationId: groupId,
    );

    if (conversation == null) {
      throw Exception('Conversation not found');
    }

    if (conversation['type'] != 'group') {
      throw Exception('Can only add members to group conversations');
    }

    // Validate requester is a member
    final isRequesterMember = await datasource.isConversationMember(
      conversationId: groupId,
      userId: addedBy,
    );

    if (!isRequesterMember) {
      throw Exception('Only members can add other members');
    }

    // Check if user is already a member
    final isAlreadyMember = await datasource.isConversationMember(
      conversationId: groupId,
      userId: userId,
    );

    if (isAlreadyMember) {
      throw Exception('User is already a member');
    }

    await datasource.addConversationMember(
      conversationId: groupId,
      userId: userId,
    );
  }

  /// Remove a member from a group conversation
  Future<void> removeGroupMember({
    required String groupId,
    required String userId,
    required String removedBy,
  }) async {
    // Validate conversation exists and is a group
    final conversation = await datasource.getConversation(
      conversationId: groupId,
    );

    if (conversation == null) {
      throw Exception('Conversation not found');
    }

    if (conversation['type'] != 'group') {
      throw Exception('Can only remove members from group conversations');
    }

    // Allow users to remove themselves (leave group)
    // For removing others, validate permissions (could check if admin)
    if (userId != removedBy) {
      // For now, allow any member to remove others
      // TODO: Implement admin/creator permissions
      final isRequesterMember = await datasource.isConversationMember(
        conversationId: groupId,
        userId: removedBy,
      );

      if (!isRequesterMember) {
        throw Exception('Only members can remove other members');
      }
    }

    await datasource.removeConversationMember(
      conversationId: groupId,
      userId: userId,
    );
  }

  /// Leave a group conversation
  Future<void> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    await removeGroupMember(
      groupId: groupId,
      userId: userId,
      removedBy: userId,
    );
  }

  /// Update group information
  Future<void> updateGroupInfo({
    required String groupId,
    required String updatedBy,
    String? name,
    String? avatarUrl,
  }) async {
    // Validate conversation exists and is a group
    final conversation = await datasource.getConversation(
      conversationId: groupId,
    );

    if (conversation == null) {
      throw Exception('Conversation not found');
    }

    if (conversation['type'] != 'group') {
      throw Exception('Can only update group conversations');
    }

    // Validate requester is a member
    final isMember = await datasource.isConversationMember(
      conversationId: groupId,
      userId: updatedBy,
    );

    if (!isMember) {
      throw Exception('Only members can update group info');
    }

    if (name != null && name.isEmpty) {
      throw Exception('Group name cannot be empty');
    }

    await datasource.updateConversation(
      conversationId: groupId,
      name: name,
      avatarUrl: avatarUrl,
    );
  }

  /// Mark all messages in a conversation as read
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) async {
    // Validate user is member
    final isMember = await datasource.isConversationMember(
      conversationId: conversationId,
      userId: userId,
    );

    if (!isMember) {
      throw Exception('User is not a member of this conversation');
    }

    await datasource.markConversationAsRead(
      conversationId: conversationId,
      userId: userId,
    );
  }

  /// Get unread count for a specific conversation
  Future<int> getUnreadCount({
    required String userId,
    required String conversationId,
  }) async {
    return datasource.getUnreadCount(
      userId: userId,
      conversationId: conversationId,
    );
  }

  /// Get total unread count across all conversations
  Future<int> getTotalUnreadCount({
    required String userId,
  }) async {
    return datasource.getTotalUnreadCount(userId: userId);
  }

  /// Get conversation member IDs
  Future<List<String>> getConversationMemberIds({
    required String conversationId,
  }) async {
    return datasource.getConversationMemberIds(
      conversationId: conversationId,
    );
  }

  /// Get a single conversation
  Future<Map<String, dynamic>?> getConversation({
    required String conversationId,
  }) async {
    return datasource.getConversation(conversationId: conversationId);
  }
}
