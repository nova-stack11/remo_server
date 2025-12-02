import 'package:dart_frog/dart_frog.dart';

import '../../../../src/api/data/repositories/friend_repository.dart';
import '../../../../src/infrastructure/controller/api_response_factory.dart';
import '../../../../src/extension/request_context_ext.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final repo = context.read<FriendRepository>();

  switch (context.request.method) {
    case HttpMethod.delete:
      final userId = context.userIdFromJwt;
      if (userId == null) {
        return ApiResponseFactory.error(message: 'Unauthorized', statusCode: 401);
      }
      try {
        await repo.cancelRequest(requestId: id, currentUserId: userId);
        return ApiResponseFactory.success(data: true);
      } catch (e) {
        final raw = e.toString();
        final msg = raw.startsWith('Exception: ') ? raw.substring('Exception: '.length) : raw;
        return ApiResponseFactory.error(message: msg, statusCode: 400);
      }
    default:
      return ApiResponseFactory.methodNotAllow();
  }
}
