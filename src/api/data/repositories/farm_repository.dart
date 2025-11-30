import 'package:shared_events/shared_events.dart';

import '../../../extension/object_ext.dart';
import '../datasource/farm_datasource.dart';
import '../model/user_farm_plant.dart';

class FarmRepository {
  FarmRepository({required this.datasource});

  final FarmDataSource datasource;

  Future<List<Map<String, dynamic>>> getFarmByUserId(String userId) async {
    // 1. Get farm data
    final rows = await datasource.getFarmByUserId(userId);
    final now = DateTime.now().toUtc();
    final updatedRows = <Map<String, dynamic>>[];

    for (final row in rows.sanitizeMapList()) {
      final plantedAtStr = row['planted_at'] as String?;
      final duration = row['grow_duration'] as int? ?? 0;
      final needWater = row['need_water'] as bool? ?? false;
      final isDead = row['is_dead'] as bool? ?? false;

      if (plantedAtStr != null && !isDead) {
        final plantedAt = DateTime.tryParse(plantedAtStr)?.toUtc();
        if (plantedAt != null) {
          final elapsed = now.difference(plantedAt).inSeconds;

          // New grow logic: plant grows fully once elapsed >= duration
          int newStage = row['stage'] as int? ?? 1;

          if (elapsed >= duration) {
            newStage = newStage++; // fully grown
          }

          // If stage increased → set need_water = true
          if (newStage > (row['stage'] as int? ?? 1)) {
            await datasource.updatePlantNeedWater(
              plantId: row['id'] as String,
              needWater: true,
            );
            // row['stage'] = newStage;
            row['need_water'] = true;
          }

          // If need_water true and more than 1 hour → dead
          if (row['need_water'] == true) {
            final growFinishedAt = plantedAt.add(Duration(seconds: duration));
            if (now.difference(growFinishedAt).inHours >= 1) {
              await datasource.markPlantDead(
                plantId: row['id'] as String,
              );
              row['is_dead'] = true;
            }
          }
        }
      }

      updatedRows.add(row);
    }

    // 4. Return updated sanitized data
    return updatedRows.sanitizeMapList();
  }

  // ===========================
  // WATER PLANT
  // ===========================
  Future<bool> waterPlant({
    required String id,
  }) async {
    return datasource.waterPlant(
      id: id,
    );
  }

  Future<bool> needWaterPlant({
    required String id,
  }) async {
    return datasource.needWaterPlant(
      id: id,
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

  Future<FarmModel> getFarmById({
    required String id,
  }) async {
    final plant = await datasource.getFarmById(
      id: id,
    );
    return FarmModel.fromMap(plant?.sanitizeMap() ?? {});
  }
}