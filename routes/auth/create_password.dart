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

      final passwordConfirm = (body['password_confirm'] as String?)?.sanitized;
      final password = (body['password'] as String?)?.sanitized;
      final username = (body['username'] as String?)?.sanitized;

      if (username == null) {
        return ApiResponseFactory.error(
          message: 'Tên tài khoản là bắt buộc',
          statusCode: 400,
        );
      }

      if (password == null || passwordConfirm == null) {
        return ApiResponseFactory.error(
          message: 'Mật khẩu và xác nhận mật khẩu là bắt buộc',
          statusCode: 400,
        );
      }

      final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[!@#\$&*~]).{8,}$');
      if (!passwordRegex.hasMatch(password)) {
        return ApiResponseFactory.error(
          message:
              'Mật khẩu phải có ít nhất 8 ký tự, gồm 1 chữ in hoa và 1 ký tự đặc biệt',
          statusCode: 400,
        );
      }

      if (password != passwordConfirm) {
        return ApiResponseFactory.error(
          message: 'Mật khẩu xác nhận không trùng khớp',
          statusCode: 400,
        );
      }

      final result = await repository.updateProfile(body: {
        'username': username,
        'password': password,
        'password_confirm': passwordConfirm,
      });

      return result.when(
        (user) => ApiResponseFactory.success(data: user.id != null),
        (error) => ApiResponseFactory.error(message: error.toString()),
      );

    default:
      return ApiResponseFactory.methodNotAllow();
  }
}
