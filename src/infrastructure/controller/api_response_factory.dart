import 'package:dart_frog/dart_frog.dart';

class ApiResponseFactory {
  static Response success({required dynamic data, int statusCode = 200}) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'success': true,
        'data': data,
      },
    );
  }

  static Response error({required String message, int statusCode = 400}) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'success': false,
        'error': message,
      },
    );
  }


  static Response methodNotAllow() {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }
}