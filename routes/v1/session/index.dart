import 'package:dart_frog/dart_frog.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../src/api/data/repositories/farm_repository.dart';
import '../../../src/api/data/repositories/garden_repository.dart';
import '../../../src/api/data/repositories/seed_repository.dart';
import '../../../src/api/data/repositories/user_repository.dart';
import '../../../src/extension/object_ext.dart';
import '../../../src/extension/request_context_ext.dart';
import '../../../src/infrastructure/controller/api_response_factory.dart';
import '../../../src/util/map_ext.dart';

Future<Response> onRequest(RequestContext context) async {
  final repository = context.read<UserRepository>();
  final gardenRepo = context.read<GardenRepository>();
  final farmRepo = context.read<FarmRepository>();
  final seedRepo = context.read<SeedRepository>();

  switch (context.request.method) {
    case HttpMethod.get:
      final userId = context.userIdFromJwt;
      if (userId == null) {
        return ApiResponseFactory.error(message: "Missing user-id header");
      }

      final user = await repository.getById(userId);
      if (user is Error) {
        return ApiResponseFactory.error(message: "User not found");
      }

      // Load related data
      final gardenPlots = await gardenRepo.getGardenByUserId(userId);
      final farmPlantsRaw = await farmRepo.getUserFarmPlants(userId);
      final userSeedsRaw = await seedRepo.getSeedByUserId(userId);

      return ApiResponseFactory.success(
        data: {
          "garden_plots": gardenPlots.sanitizedList(),
          "farm_plants": farmPlantsRaw.sanitizedList(),
          "seeds": userSeedsRaw.sanitizedList(),
        },
      );

    default:
      return ApiResponseFactory.methodNotAllow();
  }
}
