import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';

import '../src/api/data/datasource/user_map_state_datasource.dart';
import '../src/api/data/model/user_model.dart';
import '../src/api/usecases/authenticator.dart';
import '../src/database/database.dart';
import '../src/api/data/datasource/friend_datasource.dart';
import '../src/api/data/repositories/friend_repository.dart';

final pathsNotAuthenticated = [
  '/auth/sign_in',
  '/auth/sign_up',
  '/auth/forgot_password',
  '/auth/create_password',
  '/auth/refresh_token',
  '/ws',
  '/assets',
  '/',
];

Handler middleware(Handler handler) {
  return handler
      // Register DI for Friends feature at route level to guarantee availability
      .use(provider<FriendDataSource>((context) {
        final db = context.read<DatabaseService>();
        return FriendDataSourceImpl(db);
      }))
      .use(provider<FriendRepository>((context) {
        return FriendRepository(
          datasource: context.read<FriendDataSource>(),
        );
      }))

      // 1) Xác thực bearer → tạo UserModel
      .use(
        bearerAuthentication<UserModel>(
          authenticator: (context, token) async {
            final authenticator = context.read<Authenticator>();
            return authenticator.verifyToken(token);
          },
          applies: (context) async {
            final path = context.request.uri.path;
            return !pathsNotAuthenticated.contains(path);
          },
        ),
      );
}