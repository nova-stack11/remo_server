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

      final username = (body['username'] as String?)?.sanitized;
      final password = (body['password'] as String?)?.sanitized;

      if (username == null || password == null) {
        return ApiResponseFactory.error(
          message: 'username and password are required',
          statusCode: 400,
        );
      }

      final result = await repository.createUser(username, password);

      return result.when(
        (user) async {
          // Initialize user data (garden plots, future expansions)
          // This method should be implemented inside UserRepository
          await repository.initializeNewUserData(user.id ?? '');

          return ApiResponseFactory.success(data: user.toMap());
        },
        (error) => ApiResponseFactory.error(message: error.toString()),
      );

    default:
      return ApiResponseFactory.methodNotAllow();
  }
}
