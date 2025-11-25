// Simple reversible encryption (Base64)
import 'dart:convert';

extension StringCryptoExtension on String {
  /// Encrypt string using Base64
  String get encrypted {
    return base64Encode(utf8.encode(this));
  }

  /// Decrypt Base64 string safely
  String get decrypted {
    try {
      return utf8.decode(base64Decode(this));
    } catch (_) {
      return "";
    }
  }
}

extension StringSanitizedExtension on String? {
  /// Sanitize string before inserting to database
  /// - Trims whitespace
  /// - Converts null → empty string
  /// - Removes dangerous SQL characters
  String get sanitized {
    final s = this ?? "";
    return s
        .trim()
        .replaceAll("'", "")
        .replaceAll("--", "")
        .replaceAll(";", "")
        .replaceAll("/*", "")
        .replaceAll("*/", "");
  }
}

extension StringOrEmptyExtension on String? {
  /// Returns the string if not null, otherwise returns empty string.
  String orEmpty() => this ?? "";
}