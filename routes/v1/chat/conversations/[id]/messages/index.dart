import 'package:dart_frog/dart_frog.dart';

import '../../../../../../src/api/data/repositories/chat_repository.dart';
import '../../../../../../src/infrastructure/controller/api_response_factory.dart';
import '../../../../../../src/extension/request_context_ext.dart';
import '../../../../../../src/infrastructure/extenssions/request_context_ext.dart';
import '../../../../../../src/extension/object_ext.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final repo = context.read<ChatRepository>();

  switch (context.request.method) {
    case HttpMethod.get:
      return _handleGetMessages(context, repo, id);
    default:
      return ApiResponseFactory.methodNotAllow();
  }
}

/// GET /v1/chat/conversations/:id/messages
/// Get messages for a conversation with pagination
/// Query params: page (default: 1), pageSize (default: 50), before (message ID for cursor pagination)
Future<Response> _handleGetMessages(
  RequestContext context,
  ChatRepository repo,
  String conversationId,
) async {
  final userId = context.userIdFromJwt;
  if (userId == null) {
    return ApiResponseFactory.error(message: 'Unauthorized', statusCode: 401);
  }

  try {
    final params = context.request.uri.queryParameters;
    final beforeMessageId = params['before'];

    List<Map<String, dynamic>> messages;

    if (beforeMessageId != null) {
      // Cursor-based pagination (for scroll to load more)
      final limit = int.tryParse(params['limit'] ?? '50') ?? 50;
      messages = await repo.getMessagesBefore(
        conversationId: conversationId,
        userId: userId,
        beforeMessageId: beforeMessageId,
        limit: limit,
      );
    } else {
      // Page-based pagination
      final page = int.tryParse(params['page'] ?? '1') ?? 1;
      final pageSize = int.tryParse(params['pageSize'] ?? '50') ?? 50;
      messages = await repo.getConversationMessages(
        conversationId: conversationId,
        userId: userId,
        page: page,
        pageSize: pageSize,
      );
    }

    return ApiResponseFactory.success(data: messages.sanitizeMapList());
  } catch (e, st) {
    final msg = e.toString().replaceFirst('Exception: ', '');
    print('GET /v1/chat/conversations/$conversationId/messages error: $e\n$st');
    return ApiResponseFactory.error(message: msg, statusCode: 400);
  }
}
