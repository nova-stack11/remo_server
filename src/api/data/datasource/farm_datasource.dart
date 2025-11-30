import 'package:postgres/postgres.dart';
import '../../../database/database.dart';
abstract class FarmDataSource {
  Future<bool> waterPlant({required String id,});
  Future<bool> needWaterPlant({required String id,});

  Future<Map<String, dynamic>?> getFarmById({required String id});
  Future<Map<String, dynamic>?> getPlantByTile({
    required String userId,
    required int x,
    required int y,
  });

  Future<List<Map<String, dynamic>>> getFarmByUserId(String userId);

  Future<Map<String, dynamic>?> insertPlant({
    required String gardenId,
    required String seedId,
    required int stage,
    required DateTime now,
  });

  Future<void> updatePlantNeedWater({
    required String plantId,
    required bool needWater,
  });

  Future<void> markPlantDead({
    required String plantId,
  });

  Future<void> deletePlantById({
    required String plantId,
  });
}

/// Triển khai datasource cho farm, kết nối PostgreSQL qua DatabaseService
class FarmDataSourceImpl implements FarmDataSource {
  FarmDataSourceImpl(this.db);
  final DatabaseService db;

  @override
  Future<Map<String, dynamic>?> getFarmById({required String id}) async {
    final query = Sql.named(
        '''
      SELECT 
        ufp.id,
        ufp.garden_id,
        ufp.seed_id,
        ufp.planted_at,
        ufp.last_watered_at,
        ufp.stage,
        ufp.is_dead,
        ufp.need_water,
        ufp.withered_at,
        s.name AS seed_name,
        s.grow_duration AS grow_duration,
        s.water_interval AS water_interval,
        s.stage1_image AS stage1_image,
        s.stage2_image AS stage2_image,
        s.stage3_image AS stage3_image,
        s.seed_dead_image AS seed_dead_image,
        g.user_id AS user_id,
        g.x AS x,
        g.y AS y
      FROM user_farm_plants ufp
      JOIN seed s ON ufp.seed_id = s.id
      JOIN user_garden_plots g ON ufp.garden_id = g.id
      WHERE ufp.id=@id
      LIMIT 1
      '''
    );

    final result = await db.connection.execute(query, parameters: {
      'id': id,
    });

    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  @override
  Future<List<Map<String, dynamic>>> getFarmByUserId(String userId) async {
    final query = Sql.named(
      '''
      SELECT 
        ufp.id,
        ufp.garden_id,
        ufp.seed_id,        
        ufp.planted_at,
        ufp.last_watered_at,
        ufp.stage,
        ufp.is_dead,
        ufp.need_water,
        ufp.withered_at,
        s.name AS seed_name,
        s.grow_duration AS grow_duration,
        s.water_interval AS water_interval,
        s.stage1_image AS stage1_image,
        s.stage2_image AS stage2_image,
        s.stage3_image AS stage3_image,
        s.seed_dead_image AS seed_dead_image,
        g.user_id AS user_id,       
        g.x AS x,
        g.y AS y
      FROM user_farm_plants ufp
      JOIN seed s ON ufp.seed_id = s.id
      JOIN user_garden_plots g ON ufp.garden_id = g.id
      WHERE g.user_id=@userId
      ORDER BY g.y ASC, g.x ASC
      '''
    );

    final result = await db.connection.execute(query, parameters: {
      'userId': userId,
    });

    return result.map((row) => row.toColumnMap()).toList();
  }

  @override
  Future<Map<String, dynamic>?> getPlantByTile({
    required String userId,
    required int x,
    required int y,
  }) async {
    final query = Sql.named(
        '''
      SELECT * FROM user_farm_plants
      WHERE user_id=@userId AND x=@x AND y=@y
      LIMIT 1
      '''
    );

    final result = await db.connection.execute(query, parameters: {
      'userId': userId,
      'x': x,
      'y': y,
    });

    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  @override
  Future<bool> needWaterPlant({
    required String id,
  }) async {
    final query = Sql.named(
        '''
      UPDATE user_farm_plants
      SET 
        need_water = TRUE
      WHERE id = @id AND is_dead = FALSE
      '''
    );

    final result = await db.connection.execute(
      query,
      parameters: {
        'id': id,
      },
    );

    return result.affectedRows > 0;
  }

  @override
  Future<bool> waterPlant({
    required String id,
  }) async {
    final now = DateTime.now().toUtc();
    final query = Sql.named(
        '''
      UPDATE user_farm_plants
      SET 
        need_water = FALSE,
        stage = stage + 1,
        planted_at = @now
      WHERE id = @id AND is_dead = FALSE
      '''
    );

    final result = await db.connection.execute(
      query,
      parameters: {
        'id': id,
        'now': now,
      },
    );

    return result.affectedRows > 0;
  }

  @override
  Future<Map<String, dynamic>?> insertPlant({
    required String gardenId,
    required String seedId,
    required int stage,
    required DateTime now,
  }) async {
    final query = Sql.named(
        '''
    INSERT INTO user_farm_plants 
      (garden_id, seed_id, stage, planted_at, last_watered_at)
    VALUES
      (@gardenId, @seedId, @stage, @now, @now)
    RETURNING *
    '''
    );

    final result = await db.connection.execute(
      query,
      parameters: {
        'gardenId': gardenId,
        'seedId': seedId,
        'stage': stage,
        'now': now,
      },
    );

    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  @override
  Future<void> updatePlantNeedWater({
    required String plantId,
    required bool needWater,
  }) async {
    final query = Sql.named(
      '''
      UPDATE user_farm_plants
      SET need_water=@needWater
      WHERE id=@id
      '''
    );

    await db.connection.execute(
      query,
      parameters: {
        'id': plantId,
        'needWater': needWater,
      },
    );
  }

  @override
  Future<void> markPlantDead({
    required String plantId,
  }) async {
    final query = Sql.named(
      '''
      UPDATE user_farm_plants
      SET is_dead=TRUE
      WHERE id=@id
      '''
    );

    await db.connection.execute(
      query,
      parameters: {
        'id': plantId,
      },
    );
  }

  @override
  Future<void> deletePlantById({
    required String plantId,
  }) async {
    final query = Sql.named(
      '''
      DELETE FROM user_farm_plants
      WHERE id=@id
      '''
    );

    await db.connection.execute(
      query,
      parameters: {
        'id': plantId,
      },
    );
  }
}