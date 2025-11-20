import '../../../constants/garden_plot_state.dart';
import '../../../util/map_ext.dart';
import '../../data/datasource/garden_datasource.dart';
import '../../data/datasource/inventory_datasource.dart';
import '../../data/datasource/seed_datasource.dart';
import '../../data/datasource/user_seed_datasource.dart';

class UserInitializerService {
  final GardenDatasource gardenDatasource;
  final UserSeedDatasource userSeedsDatasource;
  final SeedDataSource seedDataSource;

  UserInitializerService(
    this.gardenDatasource,
    this.userSeedsDatasource,
    this.seedDataSource,
  );

  Future<void> initializeNewUser(String userId) async {
    await _initGarden(userId);
    await _initUserSeed(userId);
  }

  // ---------------------------------------------------------
  // 1) Garden plots — tạo 20 ô
  // ---------------------------------------------------------
  Future<void> _initGarden(String userId) async {
    const int maxX = 4;
    const int maxY = 5;

    int counter = 0;

    for (var x = 1; x <= maxX; x++) {
      for (var y = 1; y <= maxY; y++) {
        counter++;

        final state = counter <= 6
            ? GardenPlotState.unlocked.name
            : GardenPlotState.locked.name;

        await gardenDatasource.createGardenPlot(
          userId: userId,
          x: x,
          y: y,
          plotState: state,
        );
      }
    }
  }

  Future<void> _initUserSeed(String userId) async {
    final seeds = await seedDataSource.getFirstSeeds(limit: 1);

    for (final seed in seeds) {
      await userSeedsDatasource.createUserSeed(
        userId: userId,
        seedId: seed.getOrNull('id') as String? ?? '',
        quantity: 3,
      );
    }
  }
}
