import 'package:dart_frog/dart_frog.dart';

import '../../../../../src/api/data/repositories/chat_repository.dart';
import '../../../../../src/infrastructure/controller/api_response_factory.dart';
import '../../../../../src/extension/request_context_ext.dart';
import '../../../../../src/extension/object_ext.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final repo = context.read<ChatRepository>();

  switch (context.request.method) {
    case HttpMethod.get:
      return _handleGetConversation(context, repo, id);
    default:
      return ApiResponseFactory.methodNotAllow();
  }
}

/// GET /v1/chat/conversations/:id
/// Get a specific conversation details
Future<Response> _handleGetConversation(
  RequestContext context,
  ChatRepository repo,
  String conversationId,
) async {
  final userId = context.userIdFromJwt;
  if (userId == null) {
    return ApiResponseFactory.error(message: 'Unauthorized', statusCode: 401);
  }

  try {
    final conversation = await repo.getConversation(
      conversationId: conversationId,
    );

    if (conversation == null) {
      return ApiResponseFactory.error(
        message: 'Conversation not found',
        statusCode: 404,
      );
    }

    return ApiResponseFactory.success(data: conversation.sanitizeMap());
  } catch (e, st) {
    print('GET /v1/chat/conversations/$conversationId error: $e\n$st');
    return ApiResponseFactory.error(message: e.toString(), statusCode: 500);
  }
}
