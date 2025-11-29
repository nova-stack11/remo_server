import 'package:postgres/postgres.dart';
import '../../../database/database.dart';
abstract class FarmDataSource {
  Future<Map<String, dynamic>?> plantSeed({
    required String userId,
    required int x,
    required int y,
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
  Future<List<Map<String, dynamic>>> getFarmByUserId(String userId) async {
    final query = Sql.named(
      '''
      SELECT 
        ufp.id,
        ufp.garden_id,
        ufp.planted_at,
        ufp.last_watered_at,
        ufp.stage,
        ufp.is_dead,
        ufp.withered_at,
        s.name AS seed_name,
        s.grow_duration AS grow_duration,
        s.water_interval AS water_interval,
        s.stage1_image AS stage1_image,
        s.stage2_image AS stage2_image,
        s.stage3_image AS stage3_image,
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
  Future<Map<String, dynamic>?> plantSeed({
    required String userId,
    required int x,
    required int y,
    required int seedId,
    required DateTime now,
  }) async {
    final seed = await getSeedById(seedId);
    if (seed == null) return null;

    final query = Sql.named(
        '''
      INSERT INTO user_farm_plants 
        (user_id, x, y, seed_id,
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
      'x': x,
      'y': y,
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
}