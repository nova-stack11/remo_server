import 'package:postgres/postgres.dart';
import '../../../database/database.dart';

abstract class UserDataSource {
  Future<Map<String, dynamic>?> getUserByUsername({required String username});
  Future<Map<String, dynamic>?> getUserById({required String id});
}

/// Triển khai datasource cho user, kết nối PostgreSQL qua DatabaseService
class UserDataSourceImpl implements UserDataSource {
  UserDataSourceImpl(this.db);
  final DatabaseService db;

  @override
  Future<Map<String, dynamic>?> getUserByUsername({required String username}) async {
    final query = Sql.named('SELECT * FROM users WHERE username=@username LIMIT 1');
    final result = await db.connection.execute(query, parameters: {'username': username});

    if (result.isEmpty) return null;
    final map = result.first.toColumnMap();
    map.remove('password');
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

}