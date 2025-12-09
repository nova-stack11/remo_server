import '../../../database/database.dart';
import 'package:postgres/postgres.dart';

abstract class UserMapStateDataSource {
  Future<Map<String, dynamic>?> getStateByUserId(String userId);
  Future<void> saveState({
    required String userId,
    required String mapId,
    required double posX,
    required double posY,
    required String direction,
  });
}

class UserMapStateDataSourceImpl implements UserMapStateDataSource {
  UserMapStateDataSourceImpl(this.db);
  final DatabaseService db;

  @override
  Future<Map<String, dynamic>?> getStateByUserId(String userId) async {
    final query = Sql.named(
      '''
      SELECT *
      FROM user_map_state
      WHERE user_id = @userId
      LIMIT 1
      ''',
    );

    final result = await db.connection.execute(
      query,
      parameters: {'userId': userId},
    );

    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  @override
  Future<void> saveState({
    required String userId,
    required String mapId,
    required double posX,
    required double posY,
    required String direction,
  }) async {
    final query = Sql.named(
      '''
      INSERT INTO user_map_state (user_id, map_id, pos_x, pos_y, direction)
      VALUES (@userId, @mapId, @posX, @posY, @direction)
      ON CONFLICT (user_id)
      DO UPDATE SET
        map_id = EXCLUDED.map_id,
        pos_x = EXCLUDED.pos_x,
        pos_y = EXCLUDED.pos_y,
        direction = EXCLUDED.direction,
        last_update = NOW();
      ''',
    );

    await db.connection.execute(
      query,
      parameters: {
        'userId': userId,
        'mapId': mapId,
        'posX': posX,
        'posY': posY,
        'direction': direction,
      },
    );
  }
}