import 'dart:io';

import 'package:postgres/postgres.dart';

class DatabaseService {
  late final Connection _connection;

  Future<void> connect() async {

    final host = Platform.environment['DATABASE_HOST'] ?? 'localhost';
    final port = int.tryParse(Platform.environment['DATABASE_PORT'] ?? '') ?? 5432;
    final database = Platform.environment['DATABASE_NAME'] ?? '';
    final user = Platform.environment['DATABASE_USER'] ?? '';
    final password = Platform.environment['DATABASE_PASSWORD'] ?? '';

    _connection = await Connection.open(
      Endpoint(
        host: host,
        port: port,
        database: database,
        username: user,
        password: password,
      ),
      settings: const ConnectionSettings(
        sslMode: SslMode.disable, // ✅ tắt SSL cho môi trường Docker
      ),
    );
    print('✅ Connected to PostgreSQL at $host:$port');
  }

  Connection get connection => _connection;
}