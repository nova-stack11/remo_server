import 'package:postgres/postgres.dart';

import '../../../database/database.dart';

abstract class ChatDataSource {
  // Conversation operations
  Future<Map<String, dynamic>> createConversation({
    required String type,
    String? name,
    String? avatarUrl,
    required String createdBy,
    required List<String> memberIds,
  });

  Future<Map<String, dynamic>?> getConversation({
    required String conversationId,
  });

  Future<Map<String, dynamic>?> findDirectConversation({
    required String user1Id,
    required String user2Id,
  });

  Future<List<Map<String, dynamic>>> getUserConversations({
    required String userId,
  });

  Future<void> updateConversation({
    required String conversationId,
    String? name,
    String? avatarUrl,
  });

  // Conversation member operations
  Future<void> addConversationMember({
    required String conversationId,
    required String userId,
  });

  Future<void> removeConversationMember({
    required String conversationId,
    required String userId,
  });

  Future<List<String>> getConversationMemberIds({
    required String conversationId,
  });

  Future<bool> isConversationMember({
    required String conversationId,
    required String userId,
  });

  Future<void> updateLastReadAt({
    required String conversationId,
    required String userId,
  });

  // Message operations
  Future<Map<String, dynamic>> createMessage({
    required String conversationId,
    required String fromUserId,
    required String content,
    required String type,
    Map<String, dynamic>? metadata,
    String? replyToMessageId,
  });

  Future<Map<String, dynamic>?> getMessage({
    required String messageId,
  });

  Future<List<Map<String, dynamic>>> getMessages({
    required String conversationId,
    int limit = 50,
    int offset = 0,
  });

  Future<List<Map<String, dynamic>>> getMessagesBefore({
    required String conversationId,
    required String beforeMessageId,
    int limit = 50,
  });

  Future<int> getUnreadCount({
    required String userId,
    required String conversationId,
  });

  Future<int> getTotalUnreadCount({
    required String userId,
  });

  // Message status operations
  Future<void> updateMessageStatus({
    required String messageId,
    required String userId,
    required String status,
  });

  Future<void> markConversationAsRead({
    required String conversationId,
    required String userId,
  });

  Future<List<Map<String, dynamic>>> getMessageStatus({
    required String messageId,
  });
}

class ChatDataSourceImpl implements ChatDataSource {
  ChatDataSourceImpl(this.db);
  final DatabaseService db;

  @override
  Future<Map<String, dynamic>> createConversation({
    required String type,
    String? name,
    String? avatarUrl,
    required String createdBy,
    required List<String> memberIds,
  }) async {
    return await db.connection.runTx((ctx) async {
      // Create conversation
      final conversationQuery = Sql.named('''
        INSERT INTO conversations (type, name, avatar_url, created_by)
        VALUES (@type, @name, @avatarUrl, @createdBy)
        RETURNING
          id::text         AS id,
          type::text       AS type,
          name,
          avatar_url       AS avatar_url,
          created_by::text AS created_by,
          created_at::text AS created_at,
          updated_at::text AS updated_at
      ''');

      final conversationRes = await ctx.execute(
        conversationQuery,
        parameters: {
          'type': type,
          'name': name,
          'avatarUrl': avatarUrl,
          'createdBy': createdBy,
        },
      );

      final conversation = conversationRes.first.toColumnMap();
      final conversationId = conversation['id'] as String;

      // Add members
      for (final memberId in memberIds) {
        final memberQuery = Sql.named('''
          INSERT INTO conversation_members (conversation_id, user_id)
          VALUES (@conversationId, @userId)
        ''');

        await ctx.execute(
          memberQuery,
          parameters: {
            'conversationId': conversationId,
            'userId': memberId,
          },
        );
      }

      return conversation;
    });
  }

  @override
  Future<Map<String, dynamic>?> getConversation({
    required String conversationId,
  }) async {
    final query = Sql.named('''
      SELECT
        c.id::text         AS id,
        c.type::text       AS type,
        c.name,
        c.avatar_url       AS avatar_url,
        c.created_by::text AS created_by,
        c.created_at::text AS created_at,
        c.updated_at::text AS updated_at,
        (
          SELECT JSON_AGG(
            JSON_BUILD_OBJECT(
              'id', cmem.user_id::text,
              'username', u.username,
              'character_name', u.character_name,
              'gender', u.gender
            )
          )
          FROM conversation_members cmem
          INNER JOIN users u ON u.id = cmem.user_id
          WHERE cmem.conversation_id = c.id
        )::text AS members
      FROM conversations c
      WHERE c.id = @conversationId
    ''');

    final res = await db.connection.execute(
      query,
      parameters: {'conversationId': conversationId},
    );

    if (res.isEmpty) return null;
    return res.first.toColumnMap();
  }

  @override
  Future<Map<String, dynamic>?> findDirectConversation({
    required String user1Id,
    required String user2Id,
  }) async {
    final query = Sql.named('''
      SELECT
        c.id::text         AS id,
        c.type::text       AS type,
        c.name,
        c.avatar_url       AS avatar_url,
        c.created_by::text AS created_by,
        c.created_at::text AS created_at,
        c.updated_at::text AS updated_at
      FROM conversations c
      WHERE c.type = 'direct'
        AND EXISTS (
          SELECT 1 FROM conversation_members cm1
          WHERE cm1.conversation_id = c.id AND cm1.user_id = @user1Id
        )
        AND EXISTS (
          SELECT 1 FROM conversation_members cm2
          WHERE cm2.conversation_id = c.id AND cm2.user_id = @user2Id
        )
      LIMIT 1
    ''');

    final res = await db.connection.execute(
      query,
      parameters: {
        'user1Id': user1Id,
        'user2Id': user2Id,
      },
    );

    if (res.isEmpty) return null;
    return res.first.toColumnMap();
  }

  @override
  Future<List<Map<String, dynamic>>> getUserConversations({
    required String userId,
  }) async {
    final query = Sql.named('''
      SELECT
        c.id::text         AS id,
        c.type::text       AS type,
        c.name,
        c.avatar_url       AS avatar_url,
        c.created_by::text AS created_by,
        c.created_at::text AS created_at,
        c.updated_at::text AS updated_at,
        cm.is_muted,
        cm.last_read_at::text AS last_read_at,
        (
          SELECT COUNT(*)
          FROM messages m
          WHERE m.conversation_id = c.id
            AND m.created_at > COALESCE(cm.last_read_at, '1970-01-01'::timestamptz)
            AND m.from_user_id != @userId
        ) AS unread_count,
        lm.id::text           AS last_message_id,
        lm.content            AS last_message_content,
        lm.type::text         AS last_message_type,
        lm.from_user_id::text AS last_message_from,
        lm.created_at::text   AS last_message_at,
        (
          SELECT JSON_AGG(
            JSON_BUILD_OBJECT(
              'id', cmem.user_id::text,
              'username', u.username,
              'character_name', u.character_name,
              'gender', u.gender
            )
          )
          FROM conversation_members cmem
          INNER JOIN users u ON u.id = cmem.user_id
          WHERE cmem.conversation_id = c.id
        )::text AS members
      FROM conversations c
      INNER JOIN conversation_members cm ON c.id = cm.conversation_id
      LEFT JOIN LATERAL (
        SELECT *
        FROM messages
        WHERE conversation_id = c.id
        ORDER BY created_at DESC
        LIMIT 1
      ) lm ON true
      WHERE cm.user_id = @userId
      ORDER BY COALESCE(lm.created_at, c.created_at) DESC
    ''');

    final res = await db.connection.execute(
      query,
      parameters: {'userId': userId},
    );

    return res.map((row) => row.toColumnMap()).toList();
  }

  @override
  Future<void> updateConversation({
    required String conversationId,
    String? name,
    String? avatarUrl,
  }) async {
    final query = Sql.named('''
      UPDATE conversations
      SET
        name = COALESCE(@name, name),
        avatar_url = COALESCE(@avatarUrl, avatar_url)
      WHERE id = @conversationId
    ''');

    await db.connection.execute(
      query,
      parameters: {
        'conversationId': conversationId,
        'name': name,
        'avatarUrl': avatarUrl,
      },
    );
  }

  @override
  Future<void> addConversationMember({
    required String conversationId,
    required String userId,
  }) async {
    final query = Sql.named('''
      INSERT INTO conversation_members (conversation_id, user_id)
      VALUES (@conversationId, @userId)
      ON CONFLICT DO NOTHING
    ''');

    await db.connection.execute(
      query,
      parameters: {
        'conversationId': conversationId,
        'userId': userId,
      },
    );
  }

  @override
  Future<void> removeConversationMember({
    required String conversationId,
    required String userId,
  }) async {
    final query = Sql.named('''
      DELETE FROM conversation_members
      WHERE conversation_id = @conversationId
        AND user_id = @userId
    ''');

    await db.connection.execute(
      query,
      parameters: {
        'conversationId': conversationId,
        'userId': userId,
      },
    );
  }

  @override
  Future<List<String>> getConversationMemberIds({
    required String conversationId,
  }) async {
    final query = Sql.named('''
      SELECT user_id::text AS user_id
      FROM conversation_members
      WHERE conversation_id = @conversationId
    ''');

    final res = await db.connection.execute(
      query,
      parameters: {'conversationId': conversationId},
    );

    return res.map((row) => row.toColumnMap()['user_id'] as String).toList();
  }

  @override
  Future<bool> isConversationMember({
    required String conversationId,
    required String userId,
  }) async {
    final query = Sql.named('''
      SELECT 1
      FROM conversation_members
      WHERE conversation_id = @conversationId
        AND user_id = @userId
      LIMIT 1
    ''');

    final res = await db.connection.execute(
      query,
      parameters: {
        'conversationId': conversationId,
        'userId': userId,
      },
    );

    return res.isNotEmpty;
  }

  @override
  Future<void> updateLastReadAt({
    required String conversationId,
    required String userId,
  }) async {
    final query = Sql.named('''
      UPDATE conversation_members
      SET last_read_at = now()
      WHERE conversation_id = @conversationId
        AND user_id = @userId
    ''');

    await db.connection.execute(
      query,
      parameters: {
        'conversationId': conversationId,
        'userId': userId,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> createMessage({
    required String conversationId,
    required String fromUserId,
    required String content,
    required String type,
    Map<String, dynamic>? metadata,
    String? replyToMessageId,
  }) async {
    final query = Sql.named('''
      INSERT INTO messages (
        conversation_id,
        from_user_id,
        content,
        type,
        metadata,
        reply_to_message_id
      )
      VALUES (
        @conversationId,
        @fromUserId,
        @content,
        @type,
        @metadata,
        @replyToMessageId
      )
      RETURNING
        id::text                  AS id,
        conversation_id::text     AS conversation_id,
        from_user_id::text        AS from_user_id,
        content,
        type::text                AS type,
        metadata::text            AS metadata,
        reply_to_message_id::text AS reply_to_message_id,
        created_at::text          AS created_at,
        updated_at::text          AS updated_at
    ''');

    final res = await db.connection.execute(
      query,
      parameters: {
        'conversationId': conversationId,
        'fromUserId': fromUserId,
        'content': content,
        'type': type,
        'metadata': metadata != null ? metadata.toString() : null,
        'replyToMessageId': replyToMessageId,
      },
    );

    return res.first.toColumnMap();
  }

  @override
  Future<Map<String, dynamic>?> getMessage({
    required String messageId,
  }) async {
    final query = Sql.named('''
      SELECT
        id::text                  AS id,
        conversation_id::text     AS conversation_id,
        from_user_id::text        AS from_user_id,
        content,
        type::text                AS type,
        metadata::text            AS metadata,
        reply_to_message_id::text AS reply_to_message_id,
        created_at::text          AS created_at,
        updated_at::text          AS updated_at
      FROM messages
      WHERE id = @messageId
    ''');

    final res = await db.connection.execute(
      query,
      parameters: {'messageId': messageId},
    );

    if (res.isEmpty) return null;
    return res.first.toColumnMap();
  }

  @override
  Future<List<Map<String, dynamic>>> getMessages({
    required String conversationId,
    int limit = 50,
    int offset = 0,
  }) async {
    final query = Sql.named('''
      SELECT
        id::text                  AS id,
        conversation_id::text     AS conversation_id,
        from_user_id::text        AS from_user_id,
        content,
        type::text                AS type,
        metadata::text            AS metadata,
        reply_to_message_id::text AS reply_to_message_id,
        created_at::text          AS created_at,
        updated_at::text          AS updated_at
      FROM messages
      WHERE conversation_id = @conversationId
      ORDER BY created_at DESC
      LIMIT @limit OFFSET @offset
    ''');

    final res = await db.connection.execute(
      query,
      parameters: {
        'conversationId': conversationId,
        'limit': limit,
        'offset': offset,
      },
    );

    return res.map((row) => row.toColumnMap()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getMessagesBefore({
    required String conversationId,
    required String beforeMessageId,
    int limit = 50,
  }) async {
    final query = Sql.named('''
      SELECT
        m.id::text                  AS id,
        m.conversation_id::text     AS conversation_id,
        m.from_user_id::text        AS from_user_id,
        m.content,
        m.type::text                AS type,
        m.metadata::text            AS metadata,
        m.reply_to_message_id::text AS reply_to_message_id,
        m.created_at::text          AS created_at,
        m.updated_at::text          AS updated_at
      FROM messages m
      WHERE m.conversation_id = @conversationId
        AND m.created_at < (
          SELECT created_at FROM messages WHERE id = @beforeMessageId
        )
      ORDER BY m.created_at DESC
      LIMIT @limit
    ''');

    final res = await db.connection.execute(
      query,
      parameters: {
        'conversationId': conversationId,
        'beforeMessageId': beforeMessageId,
        'limit': limit,
      },
    );

    return res.map((row) => row.toColumnMap()).toList();
  }

  @override
  Future<int> getUnreadCount({
    required String userId,
    required String conversationId,
  }) async {
    final query = Sql.named('''
      SELECT COUNT(*)
      FROM messages m
      INNER JOIN conversation_members cm
        ON cm.conversation_id = m.conversation_id
        AND cm.user_id = @userId
      WHERE m.conversation_id = @conversationId
        AND m.created_at > COALESCE(cm.last_read_at, '1970-01-01'::timestamptz)
        AND m.from_user_id != @userId
    ''');

    final res = await db.connection.execute(
      query,
      parameters: {
        'userId': userId,
        'conversationId': conversationId,
      },
    );

    return res.first.toColumnMap()['count'] as int? ?? 0;
  }

  @override
  Future<int> getTotalUnreadCount({
    required String userId,
  }) async {
    final query = Sql.named('''
      SELECT COUNT(*)
      FROM messages m
      INNER JOIN conversation_members cm
        ON cm.conversation_id = m.conversation_id
        AND cm.user_id = @userId
      WHERE m.created_at > COALESCE(cm.last_read_at, '1970-01-01'::timestamptz)
        AND m.from_user_id != @userId
    ''');

    final res = await db.connection.execute(
      query,
      parameters: {'userId': userId},
    );

    return res.first.toColumnMap()['count'] as int? ?? 0;
  }

  @override
  Future<void> updateMessageStatus({
    required String messageId,
    required String userId,
    required String status,
  }) async {
    final query = Sql.named('''
      INSERT INTO message_status (message_id, user_id, status)
      VALUES (@messageId, @userId, @status)
      ON CONFLICT (message_id, user_id)
      DO UPDATE SET
        status = EXCLUDED.status,
        updated_at = now()
    ''');

    await db.connection.execute(
      query,
      parameters: {
        'messageId': messageId,
        'userId': userId,
        'status': status,
      },
    );
  }

  @override
  Future<void> markConversationAsRead({
    required String conversationId,
    required String userId,
  }) async {
    // Update last_read_at to current time
    await updateLastReadAt(
      conversationId: conversationId,
      userId: userId,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getMessageStatus({
    required String messageId,
  }) async {
    final query = Sql.named('''
      SELECT
        message_id::text AS message_id,
        user_id::text    AS user_id,
        status::text     AS status,
        updated_at::text AS updated_at
      FROM message_status
      WHERE message_id = @messageId
    ''');

    final res = await db.connection.execute(
      query,
      parameters: {'messageId': messageId},
    );

    return res.map((row) => row.toColumnMap()).toList();
  }
}
