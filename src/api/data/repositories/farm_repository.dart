import '../datasource/farm_datasource.dart';
import '../model/user_farm_plant.dart';

class FarmRepository {
  FarmRepository({required this.datasource});

  final FarmDataSource datasource;


  Future<List<UserFarmPlant>> getUserFarmPlants(String userId) async {
    final rows = await datasource.getUserFarmPlants(userId);
    return rows.map((e) => UserFarmPlant.fromMap(e)).toList();
  }

  // ===========================
  // PLANT SEED
  // ===========================
  Future<Map<String, dynamic>?> plantSeed({
    required String userId,
    required int tileX,
    required int tileY,
    required int seedId,
  }) async {
    final now = DateTime.now().toUtc();

    // Check tile occupied
    final existing = await datasource.getPlantByTile(
      userId: userId,
      x: tileX,
      y: tileY,
    );

    if (existing != null) {
      throw Exception("Tile already has plant");
    }

    final plant = await datasource.plantSeed(
      userId: userId,
      x: tileX,
      y: tileY,
      seedId: seedId,
      now: now,
    );

    return plant;
  }

  // ===========================
  // WATER PLANT
  // ===========================
  Future<bool> waterPlant({
    required String userId,
    required String plantId,
  }) async {
    final now = DateTime.now().toUtc();
    return datasource.waterPlant(
      userId: userId,
      plantId: plantId,
      now: now,
    );
  }
}