import '../../../constants/garden_plot_state.dart';
import '../../data/datasource/garden_datasource.dart';
import '../../data/datasource/inventory_datasource.dart';
import '../../data/datasource/user_seed_datasource.dart';

class UserInitializerService {
  final GardenDatasource gardenDatasource;
  final InventoryDatasource inventoryDatasource;
  final UserSeedDatasource seedsDatasource;

  UserInitializerService(
    this.gardenDatasource,
    this.inventoryDatasource,
    this.seedsDatasource,
  );

  Future<void> initializeNewUser(String userId) async {
    await _initGarden(userId);
    await _initInventory(userId);
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

        final plotCode = 'x${x}y${y}';

        final state = counter <= 6
            ? GardenPlotState.unlocked.name
            : GardenPlotState.locked.name;

        await gardenDatasource.createGardenPlot(
          userId: userId,
          plotCode: plotCode,
          plotState: state,
        );
      }
    }
  }

  // ---------------------------------------------------------
  // 2) Inventory mặc định
  // ---------------------------------------------------------
  Future<void> _initInventory(String userId) async {
    await inventoryDatasource.createInventory(userId: userId);

    // Tạo default tool
    await inventoryDatasource.addItem(
      userId: userId,
      itemId: "starter_watering_can",
      quantity: 1,
    );

    // Tặng 1 loại hạt đầu tiên
    final firstSeed = await seedsDatasource.getFirstSeedId();
    if (firstSeed != null) {
      await inventoryDatasource.addItem(
        userId: userId,
        itemId: firstSeed,
        quantity: 1,
      );
    }
  }
}
