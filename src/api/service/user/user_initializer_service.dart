import 'package:shared_events/shared_events.dart';

import '../../data/datasource/garden_datasource.dart';
import '../../data/datasource/seed_datasource.dart';
import '../../data/datasource/user_seed_datasource.dart';
import '../../data/datasource/map_datasource.dart';
import '../../data/datasource/map_member_datasource.dart';
import '../../data/repositories/user_map_state_repository.dart';

class UserInitializerService {

  UserInitializerService(
    this.gardenDatasource,
    this.userSeedsDatasource,
    this.seedDataSource,
    this.mapDatasource,
    this.mapMemberDatasource,
    this.userMapStateRepository,
  );
  final GardenDatasource gardenDatasource;
  final UserSeedDatasource userSeedsDatasource;
  final SeedDataSource seedDataSource;
  final MapDatasource mapDatasource;
  final MapMemberDatasource mapMemberDatasource;
  final UserMapStateRepository userMapStateRepository;

  Future<void> initializeNewUser(String userId) async {
    await _assignMap(userId);
    await _initGarden(userId);
    await _initUserSeed(userId);
  }

  // ---------------------------------------------------------
  // 1) Garden plots — tạo 20 ô
  // ---------------------------------------------------------
  Future<void> _initGarden(String userId) async {
    const int maxX = 3;
    const int maxY = 4;

    int counter = 0;

    for (var y = 0; y <= maxY; y++) {
      for (var x = 0; x <= maxX; x++) {
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

  Future<void> _assignMap(String userId) async {
    // Fetch all maps to find one with free slot.
    final maps = await mapDatasource.getAllMaps();
    String? targetMapId;
    String? assignedSlot;

    for (final m in maps) {
      final members = await mapMemberDatasource.getMembersByMapId(m.getOrNull('id').toString());
      if (members.length < 16) {
        targetMapId = m.getOrNull('id');
        // Determine slot_code v_1 to v_16
        final usedSlots = members.map((m) => m['slot_code'] as String).toSet();
        for (int i = 1; i <= 16; i++) {
          final slot = 'v_$i';
          if (!usedSlots.contains(slot)) {
            assignedSlot = slot;
            break;
          }
        }
        break;
      }
    }

    // If no map found, create a new one.
    if (targetMapId == null) {
      final newMap = await mapDatasource.createMap(
        name: 'Auto Village',
        type: 'village',
        capacity: 16,
      );
      targetMapId = newMap['id'].toString();
      assignedSlot = 'v_1';
    }

    // Insert member record
    await mapMemberDatasource.createMember(
      userId: userId,
      mapId: targetMapId,
      slotCode: assignedSlot!,
    );
    await userMapStateRepository.saveState(
      userId: userId,
      mapId: targetMapId,
      posX: 0,
      posY: 0,
      direction: 'down',
    );
  }
}
