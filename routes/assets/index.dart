import 'dart:io';
import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:path/path.dart' as p;
import '../../src/infrastructure/controller/api_response_factory.dart';
import '../../src/util/string_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  try {
    if (context.request.method != HttpMethod.get) {
      return ApiResponseFactory.methodNotAllow();
    }
    // Validate API key from header
    final apiKey = context.request.headers['x-api-key']?.sanitized;
    final validApiKey = Platform.environment['ASSET_API_KEY']?.sanitized;

    if (apiKey == null || apiKey != validApiKey) {
      return ApiResponseFactory.error(
        message: 'Invalid API key',
        statusCode: 401,
      );
    }

    final publicDir = Directory(p.join(Directory.current.path, 'public'));
    final bundlesDir = Directory(p.join(publicDir.path, 'bundles'));
    final fingerprintFile = File(p.join(publicDir.path, 'assets_fingerprint.json'));

    if (!fingerprintFile.existsSync()) {
      return ApiResponseFactory.error(
        message: 'fingerprint.json not found',
        statusCode: 500,
      );
    }

    // Load fingerprint.json
    final fingerprintJson =
    json.decode(await fingerprintFile.readAsString()) as Map<String, dynamic>;

    final bundlesFingerprint =
        fingerprintJson["bundles"] as Map<String, dynamic>? ?? {};

    final List<Map<String, dynamic>> result = [];

    if (bundlesDir.existsSync()) {
      for (var entry in bundlesFingerprint.entries) {
        final name = entry.key;
        final checksum = entry.value;

        final expectedFile = "$name.bundle.zip";

        File? matchedFile;
        for (var entity in bundlesDir.listSync()) {
          if (entity is File && p.basename(entity.path) == expectedFile) {
            matchedFile = entity;
            break;
          }
        }

        if (matchedFile != null) {
          result.add({
            "file": expectedFile,
            "size": matchedFile.lengthSync(),
            "checksum": checksum,
          });
        }
      }
    }

    return ApiResponseFactory.success(data: result);
  } catch (e, s) {
    print("ERROR /assets/index => $e\n$s");
    return ApiResponseFactory.error(
      message: e.toString(),
      statusCode: 500,
    );
  }
}