import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class TokenService {
  // ⚠️ Nên đưa SECRET_KEY vào file .env (ở đây hardcode để demo)
  static const _secretKey = 'super_secret_key_123';

  /// Sinh access token có thời hạn 1h
  String generateAccessToken({
    required String userId,
    required String username,
  }) {
    final jwt = JWT(
      {
        'id': userId,
        'username': username,
        'type': 'access',
      },
      issuer: 'game_server',
    );
    return jwt.sign(
      SecretKey(_secretKey),
      expiresIn: const Duration(hours: 1),
    );
  }

  /// Sinh refresh token có thời hạn 7 ngày
  String generateRefreshToken({
    required String userId,
    required String username,
  }) {
    final jwt = JWT(
      {
        'id': userId,
        'username': username,
        'type': 'refresh',
      },
      issuer: 'game_server',
    );
    return jwt.sign(
      SecretKey(_secretKey),
      expiresIn: const Duration(days: 7),
    );
  }

  /// Giải mã & xác thực token (JWT.verify)
  Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_secretKey));
      return jwt.payload as Map<String, dynamic>;
    } catch (e) {
      print('❌ Invalid token: $e');
      return null;
    }
  }

  /// Kiểm tra token có hợp lệ và chưa hết hạn không
  bool isTokenValid(String token) {
    try {
      JWT.verify(token, SecretKey(_secretKey));
      return true;
    } catch (_) {
      return false;
    }
  }
}