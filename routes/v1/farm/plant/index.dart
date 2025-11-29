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
      //   final tileX = body['tileX'] as int?;
      //   final tileY = body['tileY'] as int?;
      //   final seedId = body['seedId'] as int?;
      //   final userId = (body['id'] as String?)?.sanitized;
      //   if (userId == null) {
      //     return ApiResponseFactory.error(
      //       message: 'id là bắt buộc',
      //       statusCode: 400,
      //     );
      //   }
      //
      //   if (tileX == null || tileY == null || seedId == null) {
      //     return ApiResponseFactory.error(
      //       message: 'Không đủ thông tin để trồng hạt giống',
      //       statusCode: 400,
      //     );
      //   }
      //
      //   final result = await repository.plantSeed(
      //     userId: userId,
      //     tileX: tileX,
      //     tileY: tileY,
      //     seedId: seedId,
      //   );
      //
      //   if (result == null) {
      //     return ApiResponseFactory.error(
      //       message: 'Lỗi khi trồng hạt giống',
      //     );
      //   }
      //
      //   return ApiResponseFactory.success(data: result);
      // } catch (e) {
      //   return ApiResponseFactory.error(message: e.toString());
      // }
      return ApiResponseFactory.methodNotAllow();
    default:
      return ApiResponseFactory.methodNotAllow();
  }
}