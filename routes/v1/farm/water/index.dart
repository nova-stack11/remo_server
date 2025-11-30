import 'package:dart_frog/dart_frog.dart';

import '../../../../src/api/data/repositories/farm_repository.dart';
import '../../../../src/infrastructure/controller/api_response_factory.dart';
import '../../../../src/infrastructure/extenssions/request_context_ext.dart';
import '../../../../src/util/string_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  final repository = context.read<FarmRepository>();

  switch (context.request.method) {
    case HttpMethod.post:
      // try {
      //   final body = await context.bodyAsMap();
      //
      //   final plantId = (body['plantId'] as String?)?.sanitized;
      //   final userId = (body['id'] as String?)?.sanitized;
      //   if (userId == null) {
      //     return ApiResponseFactory.error(
      //       message: 'id là bắt buộc',
      //       statusCode: 400,
      //     );
      //   }
      //   if (plantId == null) {
      //     return ApiResponseFactory.error(
      //       message: 'Không tìm thấy cây để tưới',
      //       statusCode: 400,
      //     );
      //   }
      //
      //   final ok = await repository.waterPlant(
      //     id: id,
      //   );
      //
      //   if (!ok) {
      //     return ApiResponseFactory.error(
      //       message: 'Không thể tưới cây',
      //     );
      //   }
      //
      //   return ApiResponseFactory.success(data: {
      //     'plantId': plantId,
      //     'watered': true,
      //   });
      // } catch (e) {
      //   return ApiResponseFactory.error(message: e.toString());
      // }
      return ApiResponseFactory.methodNotAllow();

    default:
      return ApiResponseFactory.methodNotAllow();
  }
}