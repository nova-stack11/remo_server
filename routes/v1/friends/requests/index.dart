import 'package:dart_frog/dart_frog.dart';

import '../../../../src/api/data/repositories/friend_repository.dart';
import '../../../../src/infrastructure/controller/api_response_factory.dart';
import '../../../../src/extension/request_context_ext.dart';
import '../../../../src/infrastructure/extenssions/request_context_ext.dart';
import '../../../../src/extension/object_ext.dart';

Future<Response> onRequest(RequestContext context) async {
  final repo = context.read<FriendRepository>();

  switch (context.request.method) {
    case HttpMethod.post:
      return _handleSend(context, repo);
    case HttpMethod.get:
      return _handleList(context, repo);
    default:
      return ApiResponseFactory.methodNotAllow();
  }
}

Future<Response> _handleSend(RequestContext context, FriendRepository repo) async {
  final body = await context.bodyAsMap();
  final fromUserId = context.userIdFromJwt;
  final toUserId = body['toUserId'] as String?;
  final message = body['message'] as String?;

  if (fromUserId == null) {
    return ApiResponseFactory.error(message: 'Unauthorized', statusCode: 401);
  }
  if (toUserId == null || toUserId.isEmpty) {
    return ApiResponseFactory.error(message: 'Missing toUserId');
  }

  try {
    final created = await repo.sendRequest(
      fromUserId: fromUserId,
      toUserId: toUserId,
      message: message,
    );
    return ApiResponseFactory.success(data: created.sanitizeMap(), statusCode: 201);
  } catch (e, st) {
    // Map domain errors to 400 with clean message; keep 500 for truly unexpected later if needed
    final raw = e.toString();
    final msg = raw.startsWith('Exception: ') ? raw.substring('Exception: '.length) : raw;
    print('POST /v1/friends/requests error: $raw\n$st');
    return ApiResponseFactory.error(message: msg, statusCode: 400);
  }
}

Future<Response> _handleList(RequestContext context, FriendRepository repo) async {
  final userId = context.userIdFromJwt;
  if (userId == null) {
    return ApiResponseFactory.error(message: 'Unauthorized', statusCode: 401);
  }
  try {
    final status = context.request.uri.queryParameters['status'] ?? 'pending';
    final list = await repo.getIncomingRequests(userId: userId, status: status);
    return ApiResponseFactory.success(data: list.sanitizeMapList());
  } catch (e, st) {
    print('GET /v1/friends/requests error: $e\n$st');
    return ApiResponseFactory.error(message: e.toString(), statusCode: 500);
  }
}
