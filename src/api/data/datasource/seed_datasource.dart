import 'package:postgres/postgres.dart';
import '../../../database/database.dart';
abstract class SeedDataSource {
  Future<List<Map<String, dynamic>>> getSeedByUserId(String userId);
  Future<Map<String, dynamic>?> getSeedById(String? seedId);
  Future<List<Map<String, dynamic>>> getFirstSeeds({int limit = 1});
  Future<void> decreaseQuantity(String id);
}

/// Triển khai datasource cho farm, kết nối PostgreSQL qua DatabaseService
class SeedDataSourceImpl implements SeedDataSource {
  SeedDataSourceImpl(this.db);
  final DatabaseService db;

  @override
  Future<List<Map<String, dynamic>>> getSeedByUserId(String userId) async {
    final query = Sql.named(
        '''
      SELECT 
        us.id,
        us.quantity,
        s.name AS name,
        s.seed_image AS seed_image,
        s.grow_duration AS grow_duration,
        s.water_interval AS water_interval,
        s.reward AS reward,        
        s.description AS description        
      FROM user_seeds us
      JOIN seed s ON us.seed_id = s.id
      WHERE us.user_id=@userId
      ORDER BY us.seed_id ASC
      '''
    );

    final result = await db.connection.execute(query, parameters: {
      'userId': userId,
    });

    return result.map((row) => row.toColumnMap()).toList();
  }

  @override
  Future<Map<String, dynamic>?> getSeedById(String? seedId) async {
    final query = Sql.named(
        '''
      SELECT * FROM seed
      WHERE id=@seedId
      LIMIT 1
      '''
    );

    final result = await db.connection.execute(query, parameters: {
      'seedId': seedId,
    });

    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  @override
  Future<List<Map<String, dynamic>>> getFirstSeeds({int limit = 1}) async {
    final query = Sql.named(
      '''
      SELECT *
      FROM seed
      ORDER BY id ASC
      LIMIT @limit
      '''
    );

    final result = await db.connection.execute(
      query,
      parameters: {'limit': limit},
    );

    return result.map((row) => row.toColumnMap()).toList();
  }

  @override
  Future<void> decreaseQuantity(String id) async {
    final query = Sql.named(
      '''
      UPDATE user_seeds
      SET quantity = quantity - 1
      WHERE id=@id AND quantity > 0
      '''
    );

    await db.connection.execute(
      query,
      parameters: {
        'id': id,
      },
    );
  }
}