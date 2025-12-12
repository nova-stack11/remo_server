import 'package:dart_frog/dart_frog.dart';

import '../../../../../src/api/data/repositories/chat_repository.dart';
import '../../../../../src/infrastructure/controller/api_response_factory.dart';
import '../../../../../src/extension/request_context_ext.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final repo = context.read<ChatRepository>();

  switch (context.request.method) {
    case HttpMethod.put:
      return _handleMarkAsRead(context, repo, id);
    default:
      return ApiResponseFactory.methodNotAllow();
  }
}

/// PUT /v1/chat/conversations/:id/read
/// Mark all messages in a conversation as read
Future<Response> _handleMarkAsRead(
  RequestContext context,
  ChatRepository repo,
  String conversationId,
) async {
  final userId = context.userIdFromJwt;
  if (userId == null) {
    return ApiResponseFactory.error(message: 'Unauthorized', statusCode: 401);
  }

  try {
    await repo.markMessagesAsRead(
      conversationId: conversationId,
      userId: userId,
    );

    return ApiResponseFactory.success(
      data: {'message': 'Conversation marked as read'},
    );
  } catch (e, st) {
    final msg = e.toString().replaceFirst('Exception: ', '');
    print('PUT /v1/chat/conversations/$conversationId/read error: $e\n$st');
    return ApiResponseFactory.error(message: msg, statusCode: 400);
  }
}
