import 'package:dart_frog/dart_frog.dart';

import '../../../../src/api/data/repositories/chat_repository.dart';
import '../../../../src/infrastructure/controller/api_response_factory.dart';
import '../../../../src/extension/request_context_ext.dart';
import '../../../../src/infrastructure/extenssions/request_context_ext.dart';
import '../../../../src/extension/object_ext.dart';

Future<Response> onRequest(RequestContext context) async {
  final repo = context.read<ChatRepository>();

  switch (context.request.method) {
    case HttpMethod.get:
      return _handleGetConversations(context, repo);
    case HttpMethod.post:
      return _handleCreateConversation(context, repo);
    default:
      return ApiResponseFactory.methodNotAllow();
  }
}

/// GET /v1/chat/conversations
/// Get all conversations for the authenticated user
Future<Response> _handleGetConversations(
  RequestContext context,
  ChatRepository repo,
) async {
  final userId = context.userIdFromJwt;
  if (userId == null) {
    return ApiResponseFactory.error(message: 'Unauthorized', statusCode: 401);
  }

  try {
    final conversations = await repo.getUserConversations(userId: userId);
    return ApiResponseFactory.success(data: conversations.sanitizeMapList());
  } catch (e, st) {
    print('GET /v1/chat/conversations error: $e\n$st');
    return ApiResponseFactory.error(message: e.toString(), statusCode: 500);
  }
}

/// POST /v1/chat/conversations
/// Create a new direct or group conversation
/// Body: { "type": "direct|group", "name": "...", "memberIds": [...], "avatarUrl": "..." }
Future<Response> _handleCreateConversation(
  RequestContext context,
  ChatRepository repo,
) async {
  final userId = context.userIdFromJwt;
  if (userId == null) {
    return ApiResponseFactory.error(message: 'Unauthorized', statusCode: 401);
  }

  try {
    final body = await context.bodyAsMap();
    final type = body['type'] as String?;
    final name = body['name'] as String?;
    final memberIds = (body['memberIds'] as List?)?.cast<String>() ?? [];
    final avatarUrl = body['avatarUrl'] as String?;

    if (type == null || (type != 'direct' && type != 'group')) {
      return ApiResponseFactory.error(
        message: 'Invalid type. Must be "direct" or "group"',
        statusCode: 400,
      );
    }

    Map<String, dynamic> conversation;

    if (type == 'direct') {
      // For direct chat, we need exactly one other user
      if (memberIds.isEmpty) {
        return ApiResponseFactory.error(
          message: 'memberIds must contain the other user ID',
          statusCode: 400,
        );
      }
      final otherUserId = memberIds.first;
      conversation = await repo.getOrCreateDirectConversation(
        user1Id: userId,
        user2Id: otherUserId,
      );
    } else {
      // Group chat
      if (name == null || name.isEmpty) {
        return ApiResponseFactory.error(
          message: 'Group name is required',
          statusCode: 400,
        );
      }
      conversation = await repo.createGroupConversation(
        name: name,
        createdBy: userId,
        memberIds: memberIds,
        avatarUrl: avatarUrl,
      );
    }

    return ApiResponseFactory.success(
      data: conversation.sanitizeMap(),
      statusCode: 201,
    );
  } catch (e, st) {
    final msg = e.toString().replaceFirst('Exception: ', '');
    print('POST /v1/chat/conversations error: $e\n$st');
    return ApiResponseFactory.error(message: msg, statusCode: 400);
  }
}
