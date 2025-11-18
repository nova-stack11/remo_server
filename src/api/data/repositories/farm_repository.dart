import '../datasource/farm_datasource.dart';

class FarmRepository {
  FarmRepository({required this.datasource});

  final FarmDataSource datasource;

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
      tileX: tileX,
      tileY: tileY,
    );

    if (existing != null) {
      throw Exception("Tile already has plant");
    }

    final plant = await datasource.plantSeed(
      userId: userId,
      tileX: tileX,
      tileY: tileY,
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