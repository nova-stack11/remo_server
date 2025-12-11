import 'package:postgres/postgres.dart';

import '../../../database/database.dart';

abstract class PresenceDataSource {
  Future<void> updateUserStatus({
    required String userId,
    required String status,
  });

  Future<Map<String, dynamic>?> getUserStatus({
    required String userId,
  });

  Future<List<Map<String, dynamic>>> getUsersStatus({
    required List<String> userIds,
  });

  Future<void> updateLastSeen({
    required String userId,
  });

  Future<List<Map<String, dynamic>>> getOnlineFriends({
    required String userId,
  });
}

class PresenceDataSourceImpl implements PresenceDataSource {
  PresenceDataSourceImpl(this.db);
  final DatabaseService db;

  @override
  Future<void> updateUserStatus({
    required String userId,
    required String status,
  }) async {
    final query = Sql.named('''
      INSERT INTO user_presence (user_id, status, last_seen_at)
      VALUES (@userId, @status, now())
      ON CONFLICT (user_id)
      DO UPDATE SET
        status = EXCLUDED.status,
        last_seen_at = now(),
        updated_at = now()
    ''');

    await db.connection.execute(
      query,
      parameters: {
        'userId': userId,
        'status': status,
      },
    );
  }

  @override
  Future<Map<String, dynamic>?> getUserStatus({
    required String userId,
  }) async {
    final query = Sql.named('''
      SELECT
        user_id::text     AS user_id,
        status::text      AS status,
        last_seen_at::text AS last_seen_at,
        updated_at::text  AS updated_at
      FROM user_presence
      WHERE user_id = @userId
    ''');

    final res = await db.connection.execute(
      query,
      parameters: {'userId': userId},
    );

    if (res.isEmpty) return null;
    return res.first.toColumnMap();
  }

  @override
  Future<List<Map<String, dynamic>>> getUsersStatus({
    required List<String> userIds,
  }) async {
    if (userIds.isEmpty) return [];

    final query = Sql.named('''
      SELECT
        user_id::text     AS user_id,
        status::text      AS status,
        last_seen_at::text AS last_seen_at,
        updated_at::text  AS updated_at
      FROM user_presence
      WHERE user_id = ANY(@userIds::uuid[])
    ''');

    final res = await db.connection.execute(
      query,
      parameters: {'userIds': userIds},
    );

    return res.map((row) => row.toColumnMap()).toList();
  }

  @override
  Future<void> updateLastSeen({
    required String userId,
  }) async {
    final query = Sql.named('''
      INSERT INTO user_presence (user_id, status, last_seen_at)
      VALUES (@userId, 'offline', now())
      ON CONFLICT (user_id)
      DO UPDATE SET
        last_seen_at = now(),
        updated_at = now()
    ''');

    await db.connection.execute(
      query,
      parameters: {'userId': userId},
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getOnlineFriends({
    required String userId,
  }) async {
    final query = Sql.named('''
      SELECT
        u.id::text            AS user_id,
        u.username,
        u.character_name,
        up.status::text       AS status,
        up.last_seen_at::text AS last_seen_at
      FROM friends f
      INNER JOIN users u ON f.friend_id = u.id
      LEFT JOIN user_presence up ON u.id = up.user_id
      WHERE f.user_id = @userId
        AND up.status = 'online'
      ORDER BY u.username
    ''');

    final res = await db.connection.execute(
      query,
      parameters: {'userId': userId},
    );

    return res.map((row) => row.toColumnMap()).toList();
  }
}
