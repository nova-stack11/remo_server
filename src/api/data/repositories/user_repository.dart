import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../../infrastructure/controller/rest_controller.dart';
import '../../../util/map_ext.dart';
import '../../../util/string_helper.dart';
import '../../service/token_service.dart';
import '../../service/user/user_initializer_service.dart';
import '../datasource/datasource.dart';
import '../datasource/user_datasource.dart';
import '../exceptions/create_user_exception.dart';
import '../exceptions/get_user_exception.dart';
import '../model/user_model.dart';

class UserRepository {
  UserRepository(this.datasource, this.userDataSource, this.userService,);

  Uuid uuid = const Uuid();

  final Datasource datasource;
  final UserDataSource userDataSource;
  final UserInitializerService userService;
  Future<Result<UserModel, GetUserException>> getUserByLogin(
    String login,
    String password,
  ) async {
    final userMap = await userDataSource.getUserByUsername(username: login);
    if (userMap == null) {
      return Error(NotFoundUserException());
    }
    return Success(UserModel.fromMap(userMap));
  }

  Future<bool> checkUsernameExists(String username) async {
    try {
      final userMap = await userDataSource.getUserByUsername(username: username);
      return userMap != null;
    } catch (e) {
      print('❌ checkUsernameExists error: $e');
      return false;
    }
  }

  Future<Result<UserModel, GetUserException>> loginUser(
    String username,
    String password,
  ) async {
    try {
      final userMap = await userDataSource.getUserByUsername(username: username, removePassword: false);
      if (userMap == null) {
        return Error(NotFoundUserException());
      }

      // 🔹 Kiểm tra password
      final dbPassword = userMap.getOrNull('password')?.toString() ?? '';
      final decrypted = dbPassword.decrypted;
      if (decrypted != password) {
        return Error(WrongPasswordException());
      }

      final userId = userMap.getOrNull('id')?.toString() ?? '';

      final tokenService = TokenService();
      final accessToken = tokenService.generateAccessToken(
        userId: userId,
        username: username,
      );
      final refreshToken = tokenService.generateRefreshToken(
        userId: userId,
        username: username,
      );

      await datasource.update(
        document: UserModel.document,
        data: {
          'id': userId,
          'token': accessToken,
          'refresh_token': refreshToken,
        },
      );

      final updatedUser =
          await userDataSource.getUserByUsername(username: username);
      if (updatedUser == null) {
        return Error(NotFoundUserException());
      }

      return Success(UserModel.fromMap(updatedUser));
    } catch (e) {
      print('❌ loginUser error: $e');
      return Error(NotFoundUserException());
    }
  }

  Future<Result<UserModel, GetUserException>> getById(
    String id,
  ) async {
    final userMap = await datasource.getFirst(
      document: UserModel.document,
      // test: (element) {
      //   return element['id'] == id;
      // },
    );
    if (userMap == null) {
      return Error(NotFoundUserException());
    }
    return Success(UserModel.fromMap(userMap));
  }


  Future<Result<Map<String, dynamic>?, GetUserException>> getUserById(
    String id,
  ) async {
    final userMap = await userDataSource.getUserById(id: id);
    if (userMap == null) {
      return Error(NotFoundUserException());
    }
    return Success(userMap);
  }



  Future<Result<UserModel, CreateUserException>> createUser(
    String login,
    String password,
  ) async {
    final userMap = await userDataSource.getUserByUsername(username: login);
    if (userMap?.getOrNull("username") == login) {
      return Error(UserAlreadyExistException());
    }

    final insertedResult = await datasource.insert(
      document: UserModel.document,
      data: {
        'username': login,
        'password': password.encrypted,
      },
    );

    final id = insertedResult?.getOrNull('id').toString() ?? '';
    final username = insertedResult?.getOrNull('username').toString() ?? '';

    final tokenService = TokenService();
    final accessToken = tokenService.generateAccessToken(
      userId: id,
      username: username,
    );
    final refreshToken = tokenService.generateRefreshToken(
      userId: id,
      username: username,
    );

    var success = await datasource.update(
      document: UserModel.document,
      data: {
        'id': id,
        'token': accessToken,
        'refresh_token': refreshToken,
      },
    );

    if (success) {
      final updatedUserData = {
        'id': id,
        'username': username,
        // 'password': password.encrypted,
        'token': accessToken,
        'refresh_token': refreshToken,
      };
      return Success(UserModel.fromMap(updatedUserData));
    } else {
      return Error(SignUpErrorException());
    }
  }

  Future<Result<UserModel, Exception>> refreshAccessToken(
      {required String refreshToken}) async {
    final tokenService = TokenService();

    // 🔹 Xác minh refresh token
    final payload = tokenService.verifyToken(refreshToken);
    if (payload == null || payload['type'] != 'refresh') {
      return Error(TokenInvalidTypeException());
    }
    final userId = payload?.getOrNull('id').toString() ?? '';
    final userName = payload?.getOrNull('username').toString() ?? '';

    final existingUserMap =
        await userDataSource.getUserByUsername(username: userName);
    if (existingUserMap == null ||
        existingUserMap.getOrNull('refresh_token') != refreshToken) {
      return Error(TokenInvalidTypeException());
    }

    final newAccessToken = tokenService.generateAccessToken(
      userId: userId,
      username: userName,
    );
    final newRefreshToken = tokenService.generateRefreshToken(
      userId: userId,
      username: userName,
    );

    await datasource.update(
      document: UserModel.document,
      data: {
        'id': userId,
        'token': newAccessToken,
        'refresh_token': newRefreshToken,
      },
    );

    final updatedUserMap =
        await userDataSource.getUserByUsername(username: userName);
    if (updatedUserMap == null) {
      return Error(TokenInvalidTypeException());
    }

    return Success(UserModel.fromMap(updatedUserMap));
  }

  Future<Result<UserModel, Exception>> updateProfile({
    required Map<String, dynamic> body,
  }) async {
    try {
      final id = body['id']?.toString();
      final username = body['username']?.toString();

      Map<String, dynamic>? existingUserMap;

      if (id != null && id.isNotEmpty) {
        existingUserMap = await userDataSource.getUserById(id: id);
      } else if (username != null) {
        existingUserMap = await userDataSource.getUserByUsername(username: username.toString(),);
      }

      if (existingUserMap == null) {
        return Error(CommonException("Người dùng không tồn tại"));
      }

      final updateData = <String, dynamic>{
        'id': id,
        if (body['gender'] != null) 'gender': body['gender'],
        if (body['birthday'] != null) 'birthday': body['birthday'],
        if (body['character_name'] != null) 'character_name': body['character_name'],
        if (body['username'] != null) 'username': body['username'],
        if (body['password'] != null) 'password': body['password'],
      };

      await datasource.update(
        document: UserModel.document,
        data: updateData,
      );

      // 🔹 Lấy lại user sau khi update
      final updatedUserMap = await userDataSource.getUserByUsername(
        username: existingUserMap['username'].toString(),
      );

      if (updatedUserMap == null) {
        return Error(CommonException("Không thể lấy thông tin người dùng sau khi cập nhật"));
      }

      return Success(UserModel.fromMap(updatedUserMap));
    } catch (e, s) {
      print('❌ updateProfile error: $e\n$s');
      return Error(CommonException("Không thể cập nhật hồ sơ người dùng"));
    }
  }

  Future<void> initializeNewUserData(String userId) async {
    if (userId.isNotEmpty) {
      await userService.initializeNewUser(userId);
    }
  }
}
