import 'package:postgres/postgres.dart';
import '../../../database/database.dart';

abstract class UserDataSource {
  Future<Map<String, dynamic>?> getUserByUsername({required String username, bool removePassword = true});
  Future<Map<String, dynamic>?> getUserById({required String id});
  Future<void> plusCoin({
    required String userId,
    required int amount,
  });
}

/// Triển khai datasource cho user, kết nối PostgreSQL qua DatabaseService
class UserDataSourceImpl implements UserDataSource {
  UserDataSourceImpl(this.db);
  final DatabaseService db;

  @override
  Future<Map<String, dynamic>?> getUserByUsername({required String username, bool removePassword = true}) async {
    final query = Sql.named('SELECT * FROM users WHERE username=@username LIMIT 1');
    final result = await db.connection.execute(query, parameters: {'username': username});

    if (result.isEmpty) return null;
    final map = result.first.toColumnMap();
    if (removePassword) {
      map.remove('password');
    }
    return map;
  }
  @override
  Future<Map<String, dynamic>?> getUserById({required String id}) async {
    final query = Sql.named('SELECT * FROM users WHERE id=@id LIMIT 1');
    final result = await db.connection.execute(query, parameters: {'id': id});

    if (result.isEmpty) return null;
    final map = result.first.toColumnMap();
    map.remove('password');
    return map;
  }

  @override
  Future<void> plusCoin({
    required String userId,
    required int amount,
  }) async {
    final query = Sql.named(
      '''
      UPDATE users
      SET coin = coin + @amount
      WHERE id = @id
      '''
    );

    await db.connection.execute(
      query,
      parameters: {
        'id': userId,
        'amount': amount,
      },
    );
  }
}