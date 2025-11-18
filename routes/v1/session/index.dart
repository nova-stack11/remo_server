import 'package:dart_frog/dart_frog.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../src/api/data/repositories/farm_repository.dart';
import '../../../src/api/data/repositories/garden_repository.dart';
import '../../../src/api/data/repositories/seed_repository.dart';
import '../../../src/api/data/repositories/user_repository.dart';
import '../../../src/extension/object_ext.dart';
import '../../../src/extension/request_context_ext.dart';
import '../../../src/infrastructure/controller/api_response_factory.dart';

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
      final gardenPlots = await gardenRepo.getGarden(userId);
      final farmPlantsRaw = await farmRepo.getUserFarmPlants(userId);
      final userSeedsRaw = await seedRepo.getUserSeeds(userId);

      // Map farm plants with extra metadata
      final farmPlants = await Future.wait(farmPlantsRaw.map((p) async {
        final seed = await seedRepo.getSeedById(p.seedId);
        return {
          ...p.toMap(),
          "grow_duration": seed?.growDuration,
          "water_interval": seed?.waterInterval,
          "current_stage_image": seed?.getStageImage(p.stage),
        };
      }));

      // Map user seeds with seed image
      final userSeeds = await Future.wait(userSeedsRaw.map((s) async {
        final seed = await seedRepo.getSeedById(s.id);
        return {
          ...s.toMap(),
          "seed_image": seed?.seedImage,
        };
      }));

      if (user.isError()) {
        return ApiResponseFactory.error(message: user.tryGetError()?.toString() ?? "Unknown error");
      }

      final userData = user.tryGetSuccess();
      if (userData == null) {
        return ApiResponseFactory.error(message: "User not found");
      }

      return ApiResponseFactory.success(
        data: {
          "user": userData.toMap(),
          "garden_plots": gardenPlots.sanitizedList(),
          "farm_plants": farmPlants,
          "seeds": userSeeds,
        },
      );

    default:
      return ApiResponseFactory.methodNotAllow();
  }
}
