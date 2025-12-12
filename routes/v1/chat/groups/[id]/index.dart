import 'package:dart_frog/dart_frog.dart';

import '../../../../../src/api/data/repositories/chat_repository.dart';
import '../../../../../src/infrastructure/controller/api_response_factory.dart';
import '../../../../../src/extension/request_context_ext.dart';
import '../../../../../src/infrastructure/extenssions/request_context_ext.dart';
import '../../../../../src/extension/object_ext.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final repo = context.read<ChatRepository>();

  switch (context.request.method) {
    case HttpMethod.put:
      return _handleUpdateGroup(context, repo, id);
    case HttpMethod.delete:
      return _handleLeaveGroup(context, repo, id);
    default:
      return ApiResponseFactory.methodNotAllow();
  }
}

/// PUT /v1/chat/groups/:id
/// Update group information (name, avatar)
/// Body: { "name": "...", "avatarUrl": "..." }
Future<Response> _handleUpdateGroup(
  RequestContext context,
  ChatRepository repo,
  String groupId,
) async {
  final userId = context.userIdFromJwt;
  if (userId == null) {
    return ApiResponseFactory.error(message: 'Unauthorized', statusCode: 401);
  }

  try {
    final body = await context.bodyAsMap();
    final name = body['name'] as String?;
    final avatarUrl = body['avatarUrl'] as String?;

    await repo.updateGroupInfo(
      groupId: groupId,
      updatedBy: userId,
      name: name,
      avatarUrl: avatarUrl,
    );

    return ApiResponseFactory.success(
      data: {'message': 'Group updated successfully'},
    );
  } catch (e, st) {
    final msg = e.toString().replaceFirst('Exception: ', '');
    print('PUT /v1/chat/groups/$groupId error: $e\n$st');
    return ApiResponseFactory.error(message: msg, statusCode: 400);
  }
}

/// DELETE /v1/chat/groups/:id
/// Leave a group
Future<Response> _handleLeaveGroup(
  RequestContext context,
  ChatRepository repo,
  String groupId,
) async {
  final userId = context.userIdFromJwt;
  if (userId == null) {
    return ApiResponseFactory.error(message: 'Unauthorized', statusCode: 401);
  }

  try {
    await repo.leaveGroup(
      groupId: groupId,
      userId: userId,
    );

    return ApiResponseFactory.success(
      data: {'message': 'Left group successfully'},
    );
  } catch (e, st) {
    final msg = e.toString().replaceFirst('Exception: ', '');
    print('DELETE /v1/chat/groups/$groupId error: $e\n$st');
    return ApiResponseFactory.error(message: msg, statusCode: 400);
  }
}
