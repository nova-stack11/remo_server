import 'package:postgres/postgres.dart';
import '../../../database/database.dart';

abstract class MapMemberDatasource {
  Future<List<Map<String, dynamic>>> getMembersByMapId(String mapId);
  Future<Map<String, dynamic>?> getMemberByUserId(String userId);
  Future<Map<String, dynamic>> createMember({
    required String userId,
    required String mapId,
    required String slotCode,
  });
}

class MapMemberDatasourceImpl implements MapMemberDatasource {
  MapMemberDatasourceImpl(this.db);
  final DatabaseService db;

  @override
  Future<List<Map<String, dynamic>>> getMembersByMapId(String mapId) async {
    final query = Sql.named(
        '''
      SELECT *
      FROM map_members
      WHERE map_id=@mapId
      ORDER BY slot_code ASC
      '''
    );

    final result = await db.connection.execute(
      query,
      parameters: {'mapId': mapId},
    );

    return result.map((row) => row.toColumnMap()).toList();
  }

  @override
  Future<Map<String, dynamic>?> getMemberByUserId(String userId) async {
    final query = Sql.named(
        '''
      SELECT *
      FROM map_members
      WHERE user_id=@userId
      LIMIT 1
      '''
    );

    final result = await db.connection.execute(
      query,
      parameters: {'userId': userId},
    );

    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  @override
  Future<Map<String, dynamic>> createMember({
    required String userId,
    required String mapId,
    required String slotCode,
  }) async {
    final query = Sql.named(
        '''
      INSERT INTO map_members (user_id, map_id, slot_code)
      VALUES (@userId, @mapId, @slotCode)
      RETURNING *
      '''
    );

    final result = await db.connection.execute(
      query,
      parameters: {
        'userId': userId,
        'mapId': mapId,
        'slotCode': slotCode,
      },
    );

    return result.first.toColumnMap();
  }
}