
import 'src/api/data/datasource/garden_datasource.dart';
import 'src/api/data/repositories/garden_repository.dart';
import 'src/database/database.dart';

class AppInject {
  static final AppInject I = AppInject._();
  AppInject._();

  late DatabaseService db;
  late GardenRepository gardenRepository;
}

extension AppInjectInitializer on AppInject {
  Future<void> init(DatabaseService dbService) async {
    db = dbService;

    final gardenDatasource = GardenDatasourceImpl(dbService);
    gardenRepository = GardenRepository(datasource: gardenDatasource);
  }
}
