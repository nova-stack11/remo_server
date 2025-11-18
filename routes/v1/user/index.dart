import 'package:dart_frog/dart_frog.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../src/api/data/exceptions/create_user_exception.dart';
import '../../../src/api/data/model/user_model.dart';
import '../../../src/api/data/repositories/user_repository.dart';
import '../../../src/infrastructure/controller/api_response_factory.dart';

Future<Response> onRequest(RequestContext context) async {
  final repository = context.read<UserRepository>();

  // switch (context.request.method) {
  //   case HttpMethod.post:
  //     // Tạo mới user
  //     final body = await context.request.json() as Map<String, dynamic>;
  //     final result = await repository.createUser(body: body);
  //
  //     if (result is Success<UserModel, Exception>) {
  //       return ApiResponseFactory.success(data: result.value.toMap());
  //     } else if (result is Error<UserModel, Exception>) {
  //       return ApiResponseFactory.error(message: result.error.toString());
  //     }
  //     break;
  //
  //   case HttpMethod.get:
  //     // Lấy danh sách tất cả user
  //     final result = await repository.getAllUsers();
  //     return ApiResponseFactory.success(
  //         data: result.map((e) => e.toMap()).toList());
  //
  //   default:
  //     return ApiResponseFactory.methodNotAllow();
  // }

  return ApiResponseFactory.methodNotAllow();
}
