import 'package:dart_frog/dart_frog.dart';
import '../../src/api/data/repositories/user_repository.dart';
import '../../src/infrastructure/controller/api_response_factory.dart';
import '../../src/infrastructure/extenssions/request_context_ext.dart';
import '../../src/util/string_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  final repository = context.read<UserRepository>();

  switch (context.request.method) {
    case HttpMethod.post:
      final body = await context.bodyAsMap();
      final refreshToken = (body['refresh_token'] as String?)?.sanitized;

      if (refreshToken == null) {
        return ApiResponseFactory.error(
          message: 'refresh_token is required',
          statusCode: 400,
        );
      }

      final result =
          await repository.refreshAccessToken(refreshToken: refreshToken);

      return result.when(
        (user) => ApiResponseFactory.success(data: user.toMap()),
        (error) => ApiResponseFactory.error(message: error.toString()),
      );

    default:
      return ApiResponseFactory.methodNotAllow();
  }
}
