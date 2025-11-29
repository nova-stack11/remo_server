import '../../../extension/object_ext.dart';
import '../datasource/farm_datasource.dart';
import '../model/user_farm_plant.dart';

class FarmRepository {
  FarmRepository({required this.datasource});

  final FarmDataSource datasource;


  Future<List<Map<String, dynamic>>> getFarmByUserId(String userId) async {
    final rows = await datasource.getFarmByUserId(userId);
    return rows.sanitizeMapList();
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

  Future<Map<String, dynamic>?> insertPlant({
    required String gardenId,
    required String seedId,
  }) async {
    final now = DateTime.now().toUtc();
    final plant = await datasource.insertPlant(
      gardenId: gardenId,
      seedId: seedId,
      stage: 1,
      now: now,
    );
    return plant;
  }
}