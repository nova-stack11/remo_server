import 'package:postgres/postgres.dart';
import '../../../database/database.dart';
abstract class FarmDataSource {
  Future<Map<String, dynamic>?> plantSeed({
    required String userId,
    required int tileX,
    required int tileY,
    required int seedId,
    required DateTime now,
  });

  Future<bool> waterPlant({
    required String userId,
    required String plantId,
    required DateTime now,
  });

  Future<Map<String, dynamic>?> getSeedById(int seedId);
  Future<Map<String, dynamic>?> getPlantByTile({
    required String userId,
    required int tileX,
    required int tileY,
  });
}

/// Triển khai datasource cho farm, kết nối PostgreSQL qua DatabaseService
class FarmDataSourceImpl implements FarmDataSource {
  FarmDataSourceImpl(this.db);
  final DatabaseService db;

  @override
  Future<Map<String, dynamic>?> getSeedById(int seedId) async {
    final query = Sql.named('SELECT * FROM seed WHERE seed_id=@id LIMIT 1');
    final result = await db.connection.execute(query, parameters: {'id': seedId});

    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  @override
  Future<Map<String, dynamic>?> getPlantByTile({
    required String userId,
    required int tileX,
    required int tileY,
  }) async {
    final query = Sql.named(
        '''
      SELECT * FROM user_farm_plants
      WHERE user_id=@userId AND tile_x=@x AND tile_y=@y
      LIMIT 1
      '''
    );

    final result = await db.connection.execute(query, parameters: {
      'userId': userId,
      'x': tileX,
      'y': tileY,
    });

    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  @override
  Future<Map<String, dynamic>?> plantSeed({
    required String userId,
    required int tileX,
    required int tileY,
    required int seedId,
    required DateTime now,
  }) async {
    final seed = await getSeedById(seedId);
    if (seed == null) return null;

    final query = Sql.named(
        '''
      INSERT INTO user_farm_plants 
        (user_id, tile_x, tile_y, seed_id,
         planted_at, last_watered_at, 
         grow_duration, water_interval)
      VALUES
        (@userId, @x, @y, @seedId,
         @now, @now,
         @grow, @water)
      RETURNING *
      '''
    );

    final result = await db.connection.execute(query, parameters: {
      'userId': userId,
      'x': tileX,
      'y': tileY,
      'seedId': seedId,
      'now': now,
      'grow': seed['grow_duration'],
      'water': seed['water_interval'],
    });

    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  @override
  Future<bool> waterPlant({
    required String userId,
    required String plantId,
    required DateTime now,
  }) async {
    final query = Sql.named(
        '''
      UPDATE user_farm_plants
      SET last_watered_at=@now
      WHERE id=@id AND user_id=@userId AND is_dead=FALSE
      '''
    );

    final result = await db.connection.execute(query, parameters: {
      'id': plantId,
      'userId': userId,
      'now': now,
    });

    return result.affectedRows > 0;
  }
}