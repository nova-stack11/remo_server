import 'package:dart_frog/dart_frog.dart';

import 'api/data/datasource/datasource.dart';
import 'api/data/datasource/db_datasource.dart';
import 'api/data/datasource/farm_datasource.dart';
import 'api/data/datasource/garden_datasource.dart';
import 'api/data/datasource/inventory_datasource.dart';
import 'api/data/datasource/seed_datasource.dart';
import 'api/data/datasource/user_datasource.dart';
import 'api/data/datasource/user_map_state_datasource.dart';
import 'api/data/datasource/user_seed_datasource.dart';
import 'api/data/datasource/friend_datasource.dart';
import 'api/data/datasource/map_datasource.dart';
import 'api/data/datasource/map_member_datasource.dart';
import 'api/data/datasource/chat_datasource.dart';
import 'api/data/datasource/presence_datasource.dart';
import 'api/data/repositories/character_repository.dart';
import 'api/data/repositories/farm_repository.dart';
import 'api/data/repositories/garden_repository.dart';
import 'api/data/repositories/seed_repository.dart';
import 'api/data/repositories/friend_repository.dart';
import 'api/data/repositories/user_map_state_repository.dart';
import 'api/data/repositories/user_repository.dart';
import 'api/data/repositories/chat_repository.dart';
import 'api/data/repositories/presence_repository.dart';
import 'api/service/user/user_initializer_service.dart';
import 'api/usecases/authenticator.dart';
import 'api/usecases/generate_jwt_usecase.dart';
import 'config.dart';
import 'database/database.dart';

abstract class Injector {
  static Future<Handler> run(Handler handler) async {
    final dbService = DatabaseService();
    await dbService.connect();

    return handler
        .use(
          provider(
            (context) => Authenticator(
              context.read(),
            ),
          ),
        )
        .use(
          provider(
            (context) => UserRepository(
              context.read(),
              context.read(),
              context.read(),
            ),
          ),
        )
        .use(
          provider(
            (context) => FarmRepository(
              datasource: context.read(),
            ),
          ),
        )
        .use(
          provider(
            (context) => CharacterRepository(
              datasource: context.read(),
            ),
          ),
        )
        .use(
          provider(
            (context) => GardenRepository(
              datasource: context.read(),
            ),
          ),
        )
        .use(
          provider(
            (context) => SeedRepository(
              datasource: context.read(),
            ),
          ),
        )
        .use(
          provider<GenerateJwtUsecase>(
            (context) => GenerateJwtUsecase(
              secretKey: Config.secretJWT,
            ),
          ),
        )
        .use(
          provider(
            (context) => UserInitializerService(
              context.read(),
              context.read(),
              context.read(),
              context.read(),
              context.read(),
              context.read(),
            ),
          ),
        )
        .use(
          provider<Datasource>(
            (_) => DbDatasource(dbService),
          ),
        )
        .use(
          provider(
            (context) => UserMapStateRepository(
              datasource: context.read(),
            ),
          ),
        )
        .use(
          provider<UserDataSource>(
            (_) => UserDataSourceImpl(dbService),
          ),
        )
        .use(
          provider<GardenDatasource>(
            (_) => GardenDatasourceImpl(dbService),
          ),
        )
        .use(
          provider<InventoryDatasource>(
            (_) => InventoryDatasourceImpl(dbService),
          ),
        )
        .use(
          provider<UserSeedDatasource>(
            (_) => UserSeedDatasourceImpl(dbService),
          ),
        )
        .use(
          provider<FarmDataSource>(
            (_) => FarmDataSourceImpl(dbService),
          ),
        )
        .use(
          provider<SeedDataSource>(
            (_) => SeedDataSourceImpl(dbService),
          ),
        )
        .use(
          provider<MapDatasource>(
            (_) => MapDatasourceImpl(dbService),
          ),
        )
        .use(
          provider<MapMemberDatasource>(
            (_) => MapMemberDatasourceImpl(dbService),
          ),
        )
        .use(
          provider<UserMapStateDataSource>(
            (_) => UserMapStateDataSourceImpl(dbService),
          ),
        )
        .use(
          provider<FriendDataSource>(
            (_) => FriendDataSourceImpl(dbService),
          ),
        )
        .use(
          provider(
            (context) => FriendRepository(
              datasource: context.read(),
            ),
          ),
        )
        .use(
          provider(
            (context) => ChatRepository(
              datasource: context.read(),
            ),
          ),
        )
        .use(
      provider<ChatDataSource>(
            (_) => ChatDataSourceImpl(dbService),
      ),
    )
        .use(
          provider<PresenceDataSource>(
            (_) => PresenceDataSourceImpl(dbService),
          ),
        )
        .use(
          provider(
            (context) => PresenceRepository(
              datasource: context.read(),
            ),
          ),
        )

        // ---------------------------------------------------------
        // Database service at last
        .use(
          provider<DatabaseService>(
            (_) => dbService,
          ),
        );

    // .use(
    //   provider<Datasource>(
    //     (context) => MemoryDatasource(),
    //   ),
    // );
  }
}
