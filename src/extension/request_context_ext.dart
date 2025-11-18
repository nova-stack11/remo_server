import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';

extension RequestContextExt on RequestContext {
  String? get userId => read<String?>();
}

extension JwtUserIdExtractor on RequestContext {
  String? get userIdFromJwt {
    final auth = request.headers['authorization'];
    if (auth == null || !auth.startsWith('Bearer ')) return null;

    final token = auth.substring(7);
    try {
      // Decode JWT (header.payload.signature)
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64.normalize(payload);
      final decoded = utf8.decode(base64.decode(normalized));
      final map = jsonDecode(decoded);

      return map['id'] as String?;
    } catch (_) {
      return null;
    }
  }
}
