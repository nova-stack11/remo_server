import 'package:dart_frog/dart_frog.dart';

import '../../../src/api/data/repositories/garden_repository.dart';
import '../../../src/extension/object_ext.dart';
import '../../../src/extension/request_context_ext.dart';
import '../../../src/infrastructure/controller/api_response_factory.dart';
import '../../../src/infrastructure/extenssions/request_context_ext.dart';
import '../../../src/game/state/garden_plot_state.dart';
import '../../../src/util/string_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  final gardenRepo = context.read<GardenRepository>();

  switch (context.request.method) {
    case HttpMethod.get:
      return _handleGetGarden(context, gardenRepo);

    case HttpMethod.post:
      return _handleUpdateState(context, gardenRepo);

    default:
      return ApiResponseFactory.methodNotAllow();
  }
}

/// ===============================
/// GET: /garden  → lấy toàn bộ garden plots của user
/// ===============================
Future<Response> _handleGetGarden(
    RequestContext context,
    GardenRepository repo,
    ) async {
  final userId = context.userIdFromJwt;
  if (userId == null) {
    return ApiResponseFactory.error(
      message: "Missing user-id header",
      statusCode: 400,
    );
  }

  final data = await repo.getGarden(userId);

  return ApiResponseFactory.success(data: data.sanitizedList());
}

/// ===============================
/// POST: /garden  → update plot state
/// body: { "x": 1, "y": 3, "state": "unlocked" }
/// ===============================
Future<Response> _handleUpdateState(
    RequestContext context,
    GardenRepository repo,
    ) async {
  final body = await context.bodyAsMap();
  final userId = context.userIdFromJwt;

  final x = body['x'] as int?;
  final y = body['y'] as int?;
  final state = (body['state'] as String?)?.sanitized;

  if (userId == null || x == null || y == null || state == null) {
    return ApiResponseFactory.error(
      message: "Missing required fields",
      statusCode: 400,
    );
  }

  // Validate state using enum
  final allowed = GardenPlotState.values.map((e) => e.name).toSet();

  if (!allowed.contains(state)) {
    return ApiResponseFactory.error(
      message: "Invalid state. Allowed values: ${allowed.join(', ')}",
      statusCode: 400,
    );
  }

  final ok = await repo.updatePlotState(
    userId: userId,
    x: x,
    y: y,
    state: state,
  );

  if (!ok) {
    return ApiResponseFactory.error(message: "Update failed");
  }

  return ApiResponseFactory.success(data: true);
}