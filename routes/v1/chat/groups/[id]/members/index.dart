import 'package:dart_frog/dart_frog.dart';

import '../../../../../../src/api/data/repositories/chat_repository.dart';
import '../../../../../../src/infrastructure/controller/api_response_factory.dart';
import '../../../../../../src/extension/request_context_ext.dart';
import '../../../../../../src/infrastructure/extenssions/request_context_ext.dart';
import '../../../../../../src/extension/object_ext.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final repo = context.read<ChatRepository>();

  switch (context.request.method) {
    case HttpMethod.post:
      return _handleAddMember(context, repo, id);
    default:
      return ApiResponseFactory.methodNotAllow();
  }
}

/// POST /v1/chat/groups/:id/members
/// Add a member to a group
/// Body: { "userId": "..." }
Future<Response> _handleAddMember(
  RequestContext context,
  ChatRepository repo,
  String groupId,
) async {
  final currentUserId = context.userIdFromJwt;
  if (currentUserId == null) {
    return ApiResponseFactory.error(message: 'Unauthorized', statusCode: 401);
  }

  try {
    final body = await context.bodyAsMap();
    final userId = body['userId'] as String?;

    if (userId == null || userId.isEmpty) {
      return ApiResponseFactory.error(
        message: 'userId is required',
        statusCode: 400,
      );
    }

    await repo.addGroupMember(
      groupId: groupId,
      userId: userId,
      addedBy: currentUserId,
    );

    return ApiResponseFactory.success(
      data: {'message': 'Member added successfully'},
      statusCode: 201,
    );
  } catch (e, st) {
    final msg = e.toString().replaceFirst('Exception: ', '');
    print('POST /v1/chat/groups/$groupId/members error: $e\n$st');
    return ApiResponseFactory.error(message: msg, statusCode: 400);
  }
}
