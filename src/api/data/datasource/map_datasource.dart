import 'package:postgres/postgres.dart';
import '../../../database/database.dart';

abstract class MapDatasource {
  Future<List<Map<String, dynamic>>> getAllMaps();
  Future<Map<String, dynamic>?> getMapById(String id);
  Future<Map<String, dynamic>> createMap({required String name, required String type, required int capacity});
}

/// Triển khai datasource cho map
class MapDatasourceImpl implements MapDatasource {
  MapDatasourceImpl(this.db);
  final DatabaseService db;

  @override
  Future<List<Map<String, dynamic>>> getAllMaps() async {
    final query = Sql.named(
        '''
      SELECT *
      FROM maps
      ORDER BY id ASC
      '''
    );

    final result = await db.connection.execute(query);
    return result.map((row) => row.toColumnMap()).toList();
  }

  @override
  Future<Map<String, dynamic>?> getMapById(String id) async {
    final query = Sql.named(
        '''
      SELECT *
      FROM maps
      WHERE id=@id
      LIMIT 1
      '''
    );

    final result = await db.connection.execute(
      query,
      parameters: {'id': id},
    );

    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  @override
  Future<Map<String, dynamic>> createMap({required String name, required String type, required int capacity}) async {
    final query = Sql.named(
        '''
      INSERT INTO maps (name, type, dynamic_index, capacity)
      VALUES (@name, @type, (SELECT COALESCE(MAX(dynamic_index),0)+1 FROM maps WHERE type=@type), @capacity)
      RETURNING id, name, type, dynamic_index, capacity
      '''
    );

    final result = await db.connection.execute(
      query,
      parameters: {'name': name, 'type': type, 'capacity': capacity},
    );

    return result.first.toColumnMap();
  }
}