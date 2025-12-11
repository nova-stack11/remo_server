import 'package:bonfire_socket_server/bonfire_socket_server.dart';
import 'package:shared_events/shared_events.dart';

import '../../../app_injector.dart';
import '../../api/data/repositories/chat_repository.dart';
import '../../api/data/repositories/presence_repository.dart';
import '../../infrastructure/websocket/websocket_provider.dart';

class ChatEventHandler {
  ChatEventHandler({
    required this.userClients,
  });

  // Map of userId to WebsocketClient for direct messaging
  final Map<String, WebsocketClient> userClients;

  late final ChatRepository chatRepository = AppInject.I.chatRepository;
  late final PresenceRepository presenceRepository =
      AppInject.I.presenceRepository;

  /// Handle incoming chat message
  Future<void> handleChatMessage(
    WebsocketClient client,
    ChatMessageRequest event,
    String senderId,
  ) async {
    try {
      print('📨 Chat message from $senderId to conversation ${event.conversationId}');

      // Send message via repository (validates membership)
      final message = await chatRepository.sendMessage(
        conversationId: event.conversationId,
        fromUserId: senderId,
        content: event.content,
        type: event.type,
        metadata: event.metadata,
        replyToMessageId: event.replyToMessageId,
      );

      // Get conversation members to broadcast
      final memberIds = await chatRepository.getConversationMemberIds(
        conversationId: event.conversationId,
      );

      // Create response
      final response = ChatMessageResponse(
        id: message['id'] as String,
        conversationId: message['conversation_id'] as String,
        fromUserId: message['from_user_id'] as String,
        content: message['content'] as String,
        type: message['type'] as String,
        metadata: event.metadata,
        replyToMessageId: message['reply_to_message_id'] as String?,
        timestamp: message['created_at'] as String,
        status: 'sent',
      );

      // Send to all conversation members
      for (final memberId in memberIds) {
        final memberClient = userClients[memberId];
        if (memberClient != null) {
          memberClient.send(
            UserServerEventType.CHAT_MESSAGE_RECEIVED.name,
            response,
          );

          // If not the sender, mark as delivered
          if (memberId != senderId) {
            // Update status to delivered for this user
            // (In a real system, you might batch these)
          }
        }
      }

      print('✅ Message sent to ${memberIds.length} members');
    } catch (e, st) {
      print('❌ Error handling chat message: $e\n$st');
      // Could send error response back to client
    }
  }

  /// Handle mark messages as read
  Future<void> handleMarkRead(
    WebsocketClient client,
    MarkReadRequest event,
    String userId,
  ) async {
    try {
      print('👁️  Mark read: conversation ${event.conversationId} by $userId');

      // Mark conversation as read
      await chatRepository.markMessagesAsRead(
        conversationId: event.conversationId,
        userId: userId,
      );

      // Get conversation members to notify sender
      final memberIds = await chatRepository.getConversationMemberIds(
        conversationId: event.conversationId,
      );

      // Notify other members that messages were seen
      final statusUpdate = ChatMessageStatusUpdate(
        messageId: event.messageId ?? '', // If specific message, otherwise all
        status: 'seen',
        userId: userId,
        timestamp: DateTime.now().toIso8601String(),
      );

      for (final memberId in memberIds) {
        if (memberId != userId) {
          final memberClient = userClients[memberId];
          if (memberClient != null) {
            memberClient.send(
              UserServerEventType.CHAT_MESSAGE_STATUS.name,
              statusUpdate,
            );
          }
        }
      }

      print('✅ Marked conversation as read');
    } catch (e, st) {
      print('❌ Error handling mark read: $e\n$st');
    }
  }

  /// Handle group actions (create, add_member, remove_member, leave, update_info)
  Future<void> handleGroupAction(
    WebsocketClient client,
    GroupActionRequest event,
    String userId,
  ) async {
    try {
      print('👥 Group action: ${event.action} by $userId');

      switch (event.action) {
        case 'create':
          await _handleCreateGroup(client, event, userId);
          break;
        case 'add_member':
          await _handleAddMember(client, event, userId);
          break;
        case 'remove_member':
          await _handleRemoveMember(client, event, userId);
          break;
        case 'leave':
          await _handleLeaveGroup(client, event, userId);
          break;
        case 'update_info':
          await _handleUpdateGroupInfo(client, event, userId);
          break;
        default:
          print('⚠️  Unknown group action: ${event.action}');
      }
    } catch (e, st) {
      print('❌ Error handling group action: $e\n$st');
    }
  }

  Future<void> _handleCreateGroup(
    WebsocketClient client,
    GroupActionRequest event,
    String userId,
  ) async {
    final conversation = await chatRepository.createGroupConversation(
      name: event.groupName!,
      createdBy: userId,
      memberIds: event.memberIds!,
      avatarUrl: event.avatarUrl,
    );

    // Notify all members about new group
    final memberIds = event.memberIds!;
    if (!memberIds.contains(userId)) {
      memberIds.add(userId);
    }

    final groupEvent = {
      'type': 'group_created',
      'conversation': conversation,
    };

    for (final memberId in memberIds) {
      final memberClient = userClients[memberId];
      if (memberClient != null) {
        memberClient.send(
          UserServerEventType.GROUP_EVENT.name,
          FriendEventResponse(type: 'group_created', data: groupEvent),
        );
      }
    }

    print('✅ Group created: ${conversation['id']}');
  }

  Future<void> _handleAddMember(
    WebsocketClient client,
    GroupActionRequest event,
    String userId,
  ) async {
    await chatRepository.addGroupMember(
      groupId: event.groupId!,
      userId: event.targetUserId!,
      addedBy: userId,
    );

    // Notify all members
    final memberIds = await chatRepository.getConversationMemberIds(
      conversationId: event.groupId!,
    );

    final addEvent = {
      'type': 'member_added',
      'groupId': event.groupId,
      'userId': event.targetUserId,
      'addedBy': userId,
    };

    for (final memberId in memberIds) {
      final memberClient = userClients[memberId];
      if (memberClient != null) {
        memberClient.send(
          UserServerEventType.GROUP_EVENT.name,
          FriendEventResponse(type: 'member_added', data: addEvent),
        );
      }
    }

    print('✅ Member added to group');
  }

  Future<void> _handleRemoveMember(
    WebsocketClient client,
    GroupActionRequest event,
    String userId,
  ) async {
    await chatRepository.removeGroupMember(
      groupId: event.groupId!,
      userId: event.targetUserId!,
      removedBy: userId,
    );

    // Notify remaining members + removed user
    final memberIds = await chatRepository.getConversationMemberIds(
      conversationId: event.groupId!,
    );
    final allNotify = {...memberIds, event.targetUserId!};

    final removeEvent = {
      'type': 'member_removed',
      'groupId': event.groupId,
      'userId': event.targetUserId,
      'removedBy': userId,
    };

    for (final memberId in allNotify) {
      final memberClient = userClients[memberId];
      if (memberClient != null) {
        memberClient.send(
          UserServerEventType.GROUP_EVENT.name,
          FriendEventResponse(type: 'member_removed', data: removeEvent),
        );
      }
    }

    print('✅ Member removed from group');
  }

  Future<void> _handleLeaveGroup(
    WebsocketClient client,
    GroupActionRequest event,
    String userId,
  ) async {
    await chatRepository.leaveGroup(
      groupId: event.groupId!,
      userId: userId,
    );

    // Notify remaining members
    final memberIds = await chatRepository.getConversationMemberIds(
      conversationId: event.groupId!,
    );

    final leaveEvent = {
      'type': 'member_left',
      'groupId': event.groupId,
      'userId': userId,
    };

    for (final memberId in memberIds) {
      final memberClient = userClients[memberId];
      if (memberClient != null) {
        memberClient.send(
          UserServerEventType.GROUP_EVENT.name,
          FriendEventResponse(type: 'member_left', data: leaveEvent),
        );
      }
    }

    // Also notify the user who left
    client.send(
      UserServerEventType.GROUP_EVENT.name,
      FriendEventResponse(type: 'member_left', data: leaveEvent),
    );

    print('✅ User left group');
  }

  Future<void> _handleUpdateGroupInfo(
    WebsocketClient client,
    GroupActionRequest event,
    String userId,
  ) async {
    await chatRepository.updateGroupInfo(
      groupId: event.groupId!,
      updatedBy: userId,
      name: event.groupName,
      avatarUrl: event.avatarUrl,
    );

    // Notify all members
    final memberIds = await chatRepository.getConversationMemberIds(
      conversationId: event.groupId!,
    );

    final updateEvent = {
      'type': 'group_updated',
      'groupId': event.groupId,
      'name': event.groupName,
      'avatarUrl': event.avatarUrl,
      'updatedBy': userId,
    };

    for (final memberId in memberIds) {
      final memberClient = userClients[memberId];
      if (memberClient != null) {
        memberClient.send(
          UserServerEventType.GROUP_EVENT.name,
          FriendEventResponse(type: 'group_updated', data: updateEvent),
        );
      }
    }

    print('✅ Group info updated');
  }

  /// Handle typing indicator
  Future<void> handleTypingIndicator(
    WebsocketClient client,
    String conversationId,
    String userId,
    bool isTyping,
  ) async {
    try {
      // Get conversation members
      final memberIds = await chatRepository.getConversationMemberIds(
        conversationId: conversationId,
      );

      // Notify other members about typing status
      final typingEvent = {
        'conversationId': conversationId,
        'userId': userId,
        'isTyping': isTyping,
      };

      for (final memberId in memberIds) {
        if (memberId != userId) {
          final memberClient = userClients[memberId];
          if (memberClient != null) {
            memberClient.send(
              UserServerEventType.TYPING_INDICATOR.name,
              typingEvent,
            );
          }
        }
      }
    } catch (e) {
      // Typing indicators are non-critical, just log
      print('⚠️  Error handling typing indicator: $e');
    }
  }
}
