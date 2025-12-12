import 'package:postgres/postgres.dart';

import '../../../database/database.dart';

abstract class FriendDataSource {
  Future<Map<String, dynamic>> createRequest({
    required String fromUserId,
    required String toUserId,
    String? message,
  });

  Future<List<Map<String, dynamic>>> getRequests({
    required String toUserId,
    String status = 'pending',
  });

  Future<Map<String, dynamic>?> getRequestById(String requestId);

  Future<void> setRequestStatus({
    required String requestId,
    required String status,
  });

  Future<void> deleteRequest({
    required String requestId,
  });

  Future<bool> hasPendingBetween({
    required String fromUserId,
    required String toUserId,
  });

  Future<String?> findPendingRequestId({
    required String fromUserId,
    required String toUserId,
  });

  Future<bool> isFriends({
    required String a,
    required String b,
  });

  Future<bool> isBlockedEither({
    required String a,
    required String b,
  });

  Future<void> createFriendPair({
    required String a,
    required String b,
  });

  Future<List<Map<String, dynamic>>> listFriends({
    required String userId,
  });
}

class FriendDataSourceImpl implements FriendDataSource {
  FriendDataSourceImpl(this.db);
  final DatabaseService db;

  @override
  Future<Map<String, dynamic>> createRequest({
    required String fromUserId,
    required String toUserId,
    String? message,
  }) async {
    final query = Sql.named('''
      INSERT INTO friend_requests (from_user_id, to_user_id, message)
      VALUES (@from, @to, @message)
      RETURNING 
        id::text AS id,
        from_user_id::text AS from_user_id,
        to_user_id::text   AS to_user_id,
        message,
        status::text       AS status,
        created_at::text    AS created_at,
        updated_at::text    AS updated_at
    ''');
    final res = await db.connection.execute(
      query,
      parameters: {
        'from': fromUserId,
        'to': toUserId,
        'message': message,
      },
    );
    return res.first.toColumnMap();
  }

  @override
  Future<List<Map<String, dynamic>>> getRequests({
    required String toUserId,
    String status = 'pending',
  }) async {
    final query = Sql.named('''
      SELECT
        fr.id::text           AS id,
        fr.from_user_id::text AS from_user_id,
        fr.to_user_id::text   AS to_user_id,
        fr.message            AS message,
        fr.status::text       AS status,
        fr.created_at         AS created_at,
        fr.updated_at         AS updated_at,
        u.username            AS from_username,
        u.character_name      AS from_character_name,
        u.gender              AS from_gender,
        up.status::text       AS from_status,
        up.last_seen_at::text AS from_last_seen_at
      FROM friend_requests fr
      JOIN users u ON u.id = fr.from_user_id
      LEFT JOIN user_presence up ON u.id = up.user_id
      WHERE fr.to_user_id = @to AND fr.status = @status
      ORDER BY fr.created_at DESC
    ''');
    final res = await db.connection.execute(query, parameters: {
      'to': toUserId,
      'status': status,
    });
    return res.map((e) => e.toColumnMap()).toList();
  }

  @override
  Future<Map<String, dynamic>?> getRequestById(String requestId) async {
    final q = Sql.named('''
      SELECT 
        id::text           AS id,
        from_user_id::text AS from_user_id,
        to_user_id::text   AS to_user_id,
        message            AS message,
        status::text       AS status,
        created_at         AS created_at,
        updated_at         AS updated_at
      FROM friend_requests WHERE id=@id LIMIT 1
    ''');
    final r = await db.connection.execute(q, parameters: {'id': requestId});
    if (r.isEmpty) return null;
    return r.first.toColumnMap();
  }

  @override
  Future<void> setRequestStatus({required String requestId, required String status}) async {
    final q = Sql.named('''
      UPDATE friend_requests SET status=@status WHERE id=@id
    ''');
    await db.connection.execute(q, parameters: {
      'status': status,
      'id': requestId,
    });
  }

  @override
  Future<void> deleteRequest({required String requestId}) async {
    final q = Sql.named('DELETE FROM friend_requests WHERE id=@id');
    await db.connection.execute(q, parameters: {'id': requestId});
  }

  @override
  Future<bool> hasPendingBetween({required String fromUserId, required String toUserId}) async {
    final q = Sql.named('''
      SELECT 1 FROM friend_requests 
      WHERE from_user_id=@from AND to_user_id=@to AND status='pending'
      LIMIT 1
    ''');
    final r = await db.connection.execute(q, parameters: {
      'from': fromUserId,
      'to': toUserId,
    });
    return r.isNotEmpty;
  }

  @override
  Future<String?> findPendingRequestId({required String fromUserId, required String toUserId}) async {
    final q = Sql.named('''
      SELECT id FROM friend_requests 
      WHERE from_user_id=@from AND to_user_id=@to AND status='pending'
      LIMIT 1
    ''');
    final r = await db.connection.execute(q, parameters: {
      'from': fromUserId,
      'to': toUserId,
    });
    if (r.isEmpty) return null;
    return r.first.toColumnMap()['id'] as String;
  }

  @override
  Future<bool> isFriends({required String a, required String b}) async {
    final q = Sql.named('''
      SELECT 1 FROM friends WHERE (user_id=@a AND friend_id=@b) OR (user_id=@b AND friend_id=@a) LIMIT 1
    ''');
    final r = await db.connection.execute(q, parameters: {'a': a, 'b': b});
    return r.isNotEmpty;
  }

  @override
  Future<bool> isBlockedEither({required String a, required String b}) async {
    final q = Sql.named('''
      SELECT 1 FROM blocks 
      WHERE (user_id=@a AND blocked_user_id=@b) OR (user_id=@b AND blocked_user_id=@a)
      LIMIT 1
    ''');
    final r = await db.connection.execute(q, parameters: {'a': a, 'b': b});
    return r.isNotEmpty;
  }

  @override
  Future<void> createFriendPair({required String a, required String b}) async {
    // Insert both directions; use transaction to ensure atomicity
    await db.connection.runTx((ctx) async {
      final insert = Sql.named('''
        INSERT INTO friends (user_id, friend_id) VALUES (@u, @f)
        ON CONFLICT (user_id, friend_id) DO NOTHING
      ''');
      await ctx.execute(insert, parameters: {'u': a, 'f': b});
      await ctx.execute(insert, parameters: {'u': b, 'f': a});
    });
  }

  @override
  Future<List<Map<String, dynamic>>> listFriends({required String userId}) async {
    final q = Sql.named('''
      SELECT
        f.friend_id::text AS id,
        u.username,
        u.character_name,
        u.gender,
        u.birthday,
        f.created_at,
        up.status::text      AS status,
        up.last_seen_at::text AS last_seen_at
      FROM friends f
      JOIN users u ON u.id = f.friend_id
      LEFT JOIN user_presence up ON u.id = up.user_id
      WHERE f.user_id=@id
      ORDER BY u.username ASC
    ''');
    final r = await db.connection.execute(q, parameters: {'id': userId});
    return r.map((e) => e.toColumnMap()).toList();
  }
}
