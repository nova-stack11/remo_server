import 'package:bonfire_socket_server/bonfire_socket_server.dart';
import 'package:shared_events/shared_events.dart';

import '../../../app_injector.dart';
import '../../api/data/repositories/friend_repository.dart';
import '../../api/data/repositories/presence_repository.dart';
import '../../api/data/repositories/user_ws_repository.dart';
import '../../infrastructure/websocket/websocket_provider.dart';

class FriendEventHandler {
  FriendEventHandler({
    required this.userClients,
  });

  // Map of userId to WebsocketClient for direct messaging
  final Map<String, WebsocketClient> userClients;

  late final FriendRepository friendRepository = AppInject.I.friendRepository;
  late final PresenceRepository presenceRepository =
      AppInject.I.presenceRepository;
  late final UserWsRepository userRepository = AppInject.I.userRepository;

  /// Handle friend request actions (send, accept, decline, cancel)
  Future<void> handleFriendRequest(
    WebsocketClient client,
    FriendRequestEvent event,
    String userId,
  ) async {
    try {
      print('👥 Friend action: ${event.action} by $userId');

      switch (event.action) {
        case 'send':
          await _handleSendRequest(client, event, userId);
          break;
        case 'accept':
          await _handleAcceptRequest(client, event, userId);
          break;
        case 'decline':
          await _handleDeclineRequest(client, event, userId);
          break;
        case 'cancel':
          await _handleCancelRequest(client, event, userId);
          break;
        default:
          print('⚠️  Unknown friend action: ${event.action}');
      }
    } catch (e, st) {
      print('❌ Error handling friend request: $e\n$st');
      // Could send error response back to client
    }
  }

  Future<void> _handleSendRequest(
    WebsocketClient client,
    FriendRequestEvent event,
    String userId,
  ) async {
    final request = await friendRepository.sendRequest(
      fromUserId: userId,
      toUserId: event.targetUserId!,
      message: event.message,
    );

    // Get sender info
    final sender = await userRepository.getUserById(userId);

    // Notify the recipient
    final recipientClient = userClients[event.targetUserId!];
    if (recipientClient != null) {
      recipientClient.send(
        UserServerEventType.FRIEND_REQUEST_RECEIVED.name,
        FriendEventResponse(
          type: 'request_received',
          data: {
            'requestId': request['id'],
            'fromUserId': userId,
            'fromUsername': sender?['username'] ?? '',
            'fromCharacterName': sender?['character_name'],
            'message': event.message,
            'createdAt': request['created_at'],
          },
        ),
      );
    }

    // Confirm to sender
    client.send(
      UserServerEventType.FRIEND_REQUEST_RECEIVED.name,
      FriendEventResponse(
        type: 'request_sent',
        data: {
          'requestId': request['id'],
          'toUserId': event.targetUserId,
          'status': request['status'],
        },
      ),
    );

    print('✅ Friend request sent from $userId to ${event.targetUserId}');
  }

  Future<void> _handleAcceptRequest(
    WebsocketClient client,
    FriendRequestEvent event,
    String userId,
  ) async {
    await friendRepository.acceptRequest(
      requestId: event.requestId!,
      currentUserId: userId,
    );

    // Get the request details to find the sender
    final request =
        await friendRepository.datasource.getRequestById(event.requestId!);
    if (request == null) return;

    final fromUserId = request['from_user_id'] as String;
    final toUserId = request['to_user_id'] as String;

    // Get user info
    final accepter = await userRepository.getUserById(userId);
    final sender = await userRepository.getUserById(fromUserId);

    // Notify the sender that request was accepted
    final senderClient = userClients[fromUserId];
    if (senderClient != null) {
      senderClient.send(
        UserServerEventType.FRIEND_REQUEST_RECEIVED.name,
        FriendEventResponse(
          type: 'request_accepted',
          data: {
            'requestId': event.requestId,
            'acceptedBy': userId,
            'username': accepter?['username'] ?? '',
            'characterName': accepter?['character_name'],
          },
        ),
      );

      // Also send friend status changed event
      senderClient.send(
        UserServerEventType.FRIEND_STATUS_CHANGED.name,
        FriendEventResponse(
          type: 'friend_added',
          data: {
            'userId': userId,
            'username': accepter?['username'] ?? '',
            'characterName': accepter?['character_name'],
            'status': 'online', // TODO: Get real status
          },
        ),
      );
    }

    // Confirm to accepter
    client.send(
      UserServerEventType.FRIEND_REQUEST_RECEIVED.name,
      FriendEventResponse(
        type: 'request_accepted',
        data: {
          'requestId': event.requestId,
          'friendId': fromUserId,
        },
      ),
    );

    // Send friend status to accepter
    client.send(
      UserServerEventType.FRIEND_STATUS_CHANGED.name,
      FriendEventResponse(
        type: 'friend_added',
        data: {
          'userId': fromUserId,
          'username': sender?['username'] ?? '',
          'characterName': sender?['character_name'],
          'status': 'online', // TODO: Get real status
        },
      ),
    );

    print('✅ Friend request accepted: $fromUserId ↔ $toUserId');
  }

  Future<void> _handleDeclineRequest(
    WebsocketClient client,
    FriendRequestEvent event,
    String userId,
  ) async {
    await friendRepository.rejectRequest(
      requestId: event.requestId!,
      currentUserId: userId,
    );

    // Get the request details
    final request =
        await friendRepository.datasource.getRequestById(event.requestId!);
    if (request == null) return;

    final fromUserId = request['from_user_id'] as String;

    // Notify the sender (optional - could be silent)
    final senderClient = userClients[fromUserId];
    if (senderClient != null) {
      senderClient.send(
        UserServerEventType.FRIEND_REQUEST_RECEIVED.name,
        FriendEventResponse(
          type: 'request_declined',
          data: {
            'requestId': event.requestId,
            'declinedBy': userId,
          },
        ),
      );
    }

    // Confirm to decliner
    client.send(
      UserServerEventType.FRIEND_REQUEST_RECEIVED.name,
      FriendEventResponse(
        type: 'request_declined',
        data: {
          'requestId': event.requestId,
        },
      ),
    );

    print('✅ Friend request declined');
  }

  Future<void> _handleCancelRequest(
    WebsocketClient client,
    FriendRequestEvent event,
    String userId,
  ) async {
    await friendRepository.cancelRequest(
      requestId: event.requestId!,
      currentUserId: userId,
    );

    // Get the request details
    final request =
        await friendRepository.datasource.getRequestById(event.requestId!);
    if (request == null) return;

    final toUserId = request['to_user_id'] as String;

    // Notify the recipient (optional)
    final recipientClient = userClients[toUserId];
    if (recipientClient != null) {
      recipientClient.send(
        UserServerEventType.FRIEND_REQUEST_RECEIVED.name,
        FriendEventResponse(
          type: 'request_canceled',
          data: {
            'requestId': event.requestId,
            'canceledBy': userId,
          },
        ),
      );
    }

    // Confirm to canceler
    client.send(
      UserServerEventType.FRIEND_REQUEST_RECEIVED.name,
      FriendEventResponse(
        type: 'request_canceled',
        data: {
          'requestId': event.requestId,
        },
      ),
    );

    print('✅ Friend request canceled');
  }

  /// Broadcast status change to all friends
  Future<void> broadcastStatusChange({
    required String userId,
    required String status,
  }) async {
    try {
      // Get user's friends
      final friends = await friendRepository.listFriends(userId);
      final user = await userRepository.getUserById(userId);

      // Notify each friend
      for (final friend in friends) {
        final friendId = friend['friend_id'] as String;
        final friendClient = userClients[friendId];

        if (friendClient != null) {
          friendClient.send(
            UserServerEventType.FRIEND_STATUS_CHANGED.name,
            FriendEventResponse(
              type: 'status_changed',
              data: {
                'userId': userId,
                'username': user?['username'] ?? '',
                'characterName': user?['character_name'],
                'status': status,
                'lastSeenAt': DateTime.now().toIso8601String(),
              },
            ),
          );
        }
      }

      print('✅ Status change broadcasted: $userId -> $status');
    } catch (e) {
      print('⚠️  Error broadcasting status change: $e');
    }
  }
}
