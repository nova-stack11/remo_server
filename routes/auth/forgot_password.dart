import 'package:dart_frog/dart_frog.dart';

import '../../src/api/data/repositories/user_repository.dart';
import '../../src/infrastructure/controller/api_response_factory.dart';
import '../../src/infrastructure/extenssions/request_context_ext.dart';

Future<Response> onRequest(RequestContext context) async {
  final repository = context.read<UserRepository>();

  switch (context.request.method) {
    case HttpMethod.post:
      final body = await context.bodyAsMap();
      final username = body['username'] as String?;

      if (username == null) {
        return ApiResponseFactory.error(
          message: 'Tên tài khoản là bắt buộc',
          statusCode: 400,
        );
      }

      final exists = await repository.checkUsernameExists(username);
      return ApiResponseFactory.success(data: exists);
    default:
      return ApiResponseFactory.methodNotAllow();
  }
}
