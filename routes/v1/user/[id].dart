import 'package:dart_frog/dart_frog.dart';

import '../../../src/api/data/repositories/user_repository.dart';
import '../../../src/infrastructure/controller/api_response_factory.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final repository = context.read<UserRepository>();
  // final id = context.request.uri.queryParameters['id'];
  switch (context.request.method) {
    case HttpMethod.put:
      final body = await context.request.json() as Map<String, dynamic>;
      body['id'] = id;

      final result = await repository.updateProfile(body: body);

      return result.when(
        (user) {
          return ApiResponseFactory.success(data: user.toMap());
        },
        (error) => ApiResponseFactory.error(message: error.toString()),
      );
    default:
      return ApiResponseFactory.methodNotAllow();
  }
}
