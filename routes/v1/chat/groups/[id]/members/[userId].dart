import 'package:dart_frog/dart_frog.dart';

import '../../../../../../src/api/data/repositories/chat_repository.dart';
import '../../../../../../src/infrastructure/controller/api_response_factory.dart';
import '../../../../../../src/extension/request_context_ext.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
  String userId,
) async {
  final repo = context.read<ChatRepository>();

  switch (context.request.method) {
    case HttpMethod.delete:
      return _handleRemoveMember(context, repo, id, userId);
    default:
      return ApiResponseFactory.methodNotAllow();
  }
}

/// DELETE /v1/chat/groups/:id/members/:userId
/// Remove a member from a group
Future<Response> _handleRemoveMember(
  RequestContext context,
  ChatRepository repo,
  String groupId,
  String memberUserId,
) async {
  final currentUserId = context.userIdFromJwt;
  if (currentUserId == null) {
    return ApiResponseFactory.error(message: 'Unauthorized', statusCode: 401);
  }

  try {
    await repo.removeGroupMember(
      groupId: groupId,
      userId: memberUserId,
      removedBy: currentUserId,
    );

    return ApiResponseFactory.success(
      data: {'message': 'Member removed successfully'},
    );
  } catch (e, st) {
    final msg = e.toString().replaceFirst('Exception: ', '');
    print('DELETE /v1/chat/groups/$groupId/members/$memberUserId error: $e\n$st');
    return ApiResponseFactory.error(message: msg, statusCode: 400);
  }
}
