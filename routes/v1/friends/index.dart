import 'package:dart_frog/dart_frog.dart';

import '../../../src/api/data/repositories/friend_repository.dart';
import '../../../src/infrastructure/controller/api_response_factory.dart';
import '../../../src/extension/request_context_ext.dart';
import '../../../src/extension/object_ext.dart';

Future<Response> onRequest(RequestContext context) async {
  final repo = context.read<FriendRepository>();

  switch (context.request.method) {
    case HttpMethod.get:
      return _handleGetFriends(context, repo);
    default:
      return ApiResponseFactory.methodNotAllow();
  }
}

Future<Response> _handleGetFriends(RequestContext context, FriendRepository repo) async {
  final userId = context.userIdFromJwt;
  if (userId == null) {
    return ApiResponseFactory.error(message: 'Unauthorized', statusCode: 401);
  }
  try {
    final friends = await repo.listFriends(userId);
    return ApiResponseFactory.success(data: friends.sanitizeMapList());
  } catch (e, st) {
    // Log the error for debugging
    print('GET /v1/friends error: $e\n$st');
    return ApiResponseFactory.error(message: e.toString(), statusCode: 500);
  }
}
