
import 'src/api/data/datasource/garden_datasource.dart';
import 'src/api/data/repositories/garden_repository.dart';
import 'src/database/database.dart';
import 'src/game/event_handler/garden_event_handler.dart';

class AppInject {
  static final AppInject I = AppInject._();
  AppInject._();

  late DatabaseService db;
  late GardenRepository gardenRepository;
  late GardenEventHandler gardenEventHandler;
}

extension AppInjectInitializer on AppInject {
  Future<void> init(DatabaseService dbService) async {
    db = dbService;

    final gardenDatasource = GardenDatasourceImpl(dbService);
    gardenRepository = GardenRepository(datasource: gardenDatasource);

    gardenEventHandler = GardenEventHandler();
  }
}
