import 'package:postgres/postgres.dart';
import '../../../database/database.dart';
abstract class SeedDataSource {
  Future<List<Map<String, dynamic>>> getUserSeeds(String userId);
  Future<Map<String, dynamic>?> getSeedById(String seedId);
}

/// Triển khai datasource cho farm, kết nối PostgreSQL qua DatabaseService
class SeedDataSourceImpl implements SeedDataSource {
  SeedDataSourceImpl(this.db);
  final DatabaseService db;

  @override
  Future<List<Map<String, dynamic>>> getUserSeeds(String userId) async {
    final query = Sql.named(
        '''
      SELECT * FROM user_seeds
      WHERE user_id=@userId
      ORDER BY seed_id ASC
      '''
    );

    final result = await db.connection.execute(query, parameters: {
      'userId': userId,
    });

    return result.map((row) => row.toColumnMap()).toList();
  }

  @override
  Future<Map<String, dynamic>?> getSeedById(String seedId) async {
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
}