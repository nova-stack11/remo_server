
import 'src/api/data/datasource/datasource.dart';
import 'src/api/data/datasource/db_datasource.dart';
import 'src/api/data/datasource/farm_datasource.dart';
import 'src/api/data/datasource/garden_datasource.dart';
import 'src/api/data/datasource/seed_datasource.dart';
import 'src/api/data/datasource/user_datasource.dart';
import 'src/api/data/datasource/map_datasource.dart';
import 'src/api/data/datasource/map_member_datasource.dart';
import 'src/api/data/datasource/user_map_state_datasource.dart';
import 'src/api/data/repositories/farm_repository.dart';
import 'src/api/data/repositories/garden_repository.dart';
import 'src/api/data/repositories/seed_repository.dart';
import 'src/api/data/repositories/user_map_state_repository.dart';
import 'src/api/data/repositories/user_ws_repository.dart';
import 'src/database/database.dart';
import 'src/game/event_handler/garden_event_handler.dart';

class AppInject {
  static final AppInject I = AppInject._();
  AppInject._();

  late DatabaseService db;
  late GardenRepository gardenRepository;
  late FarmRepository farmRepository;
  late UserWsRepository userRepository;
  late SeedRepository seedRepository;
  late UserMapStateRepository userMapStateRepository;

  late GardenEventHandler gardenEventHandler;
}

extension AppInjectInitializer on AppInject {
  Future<void> init(DatabaseService dbService) async {
    db = dbService;

    gardenRepository = GardenRepository(datasource: GardenDatasourceImpl(dbService));
    farmRepository = FarmRepository(datasource: FarmDataSourceImpl(dbService));
    seedRepository = SeedRepository(datasource: SeedDataSourceImpl(dbService));
    userMapStateRepository = UserMapStateRepository(datasource: UserMapStateDataSourceImpl(dbService));
    userRepository = UserWsRepository(datasource: UserDataSourceImpl(dbService));

    gardenEventHandler = GardenEventHandler();
  }
}
