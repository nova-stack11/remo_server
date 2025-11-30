import 'package:bonfire_server/src/components/game_map.dart';
import 'package:shared_events/shared_events.dart';

import '../../../app_injector.dart';
import '../../api/data/repositories/farm_repository.dart';
import '../../api/data/repositories/garden_repository.dart';
import '../../api/data/repositories/seed_repository.dart';
import '../../api/data/repositories/user_repository.dart';
import '../../api/data/repositories/user_ws_repository.dart';
import '../../extension/game_map_ext.dart';

class GardenEventHandler {
  GardenEventHandler() {}

  late final GardenRepository gardenRepository = AppInject.I.gardenRepository;
  late final SeedRepository seedRepository = AppInject.I.seedRepository;
  late final FarmRepository farmRepository = AppInject.I.farmRepository;
  late final UserWsRepository userRepository = AppInject.I.userRepository;

  void handleGardenEvent(List<GameMap> maps, GardenEventRequest event) {
    switch (event.toType()) {
      case GardenEventType.unlockPlot:
        _handleUnlockPlot(maps, event);
        break;
      case GardenEventType.plantTree:
        _handlePlantTree(maps, event);
        break;
      case GardenEventType.waterTree:
        _handleWaterTree(maps, event);
        break;
      case GardenEventType.needWaterTree:
        _handleNeedWaterTree(maps, event);
        break;
      case GardenEventType.harvestTree:
        _handleHarvest(maps, event);
        break;
      case GardenEventType.removeTree:
        break;
      default:
        break;
    }
  }

  Future<void> _handleUnlockPlot(
      List<GameMap> maps, GardenEventRequest event) async {
    final message = GardenDataRequest.fromMap(event.data ?? {});

    await gardenRepository.updateState(
        gardenId: message.gardentId.orEmpty(),
        state: GardenPlotState.unlocked.name);
    final garden =
        await gardenRepository.getGardenById(message.gardentId.orEmpty());

    maps.sendAllUser(
        mapId: event.mapId,
        eventType: UserServerEventType.GARDEN_EVENT_RESULT.name,
        data: GardenEventResponse(
            type: GardenEventType.unlockPlot.name, gardenPlots: [garden]));
  }

  Future<void> _handleWaterTree(
      List<GameMap> maps, GardenEventRequest event) async {
    if (!event.validated()) return;

    final data = GardenDataRequest.fromMap(event.data ?? {});

    await farmRepository.waterPlant(id: data.farmId.orEmpty());
    final farms = await farmRepository.getFarmById(id: data.farmId.orEmpty());

    maps.sendAllUser(
        mapId: event.mapId,
        eventType: UserServerEventType.GARDEN_EVENT_RESULT.name,
        data: GardenEventResponse(
            type: GardenEventType.plantTree.name, farms: [farms]));
  }

  Future<void> _handleNeedWaterTree(
      List<GameMap> maps, GardenEventRequest event) async {
    if (!event.validated()) return;

    final data = GardenDataRequest.fromMap(event.data ?? {});

    await farmRepository.needWaterPlant(id: data.farmId.orEmpty());
    final farms = await farmRepository.getFarmById(id: data.farmId.orEmpty());

    maps.sendAllUser(
        mapId: event.mapId,
        eventType: UserServerEventType.GARDEN_EVENT_RESULT.name,
        data: GardenEventResponse(
            type: GardenEventType.plantTree.name, farms: [farms]));
  }
  Future<void> _handleHarvest(
      List<GameMap> maps, GardenEventRequest event) async {
    if (!event.validated()) return;

    final data = GardenDataRequest.fromMap(event.data ?? {});

    final seed = await seedRepository.getSeedById(data.seedId.orEmpty());
    final amount = seed?['reward'] as int?;
    await userRepository.plusCoin(userId: event.ownerId.orEmpty(), amount: amount.orZero());
    await farmRepository.deletePlantById(id: data.farmId.orEmpty());

    maps.sendAllUser(
        mapId: event.mapId,
        eventType: UserServerEventType.GARDEN_EVENT_RESULT.name,
        data: GardenEventResponse(
            type: GardenEventType.harvestTree.name, farmId: data.farmId, reward: amount));
  }

  Future<void> _handlePlantTree(
      List<GameMap> maps, GardenEventRequest event) async {
    if (!event.validated()) return;

    final data = GardenDataRequest.fromMap(event.data ?? {});

    await seedRepository.decreaseQuantity(data.userSeedId.orEmpty());
    await farmRepository.insertPlant(
        gardenId: data.gardentId.orEmpty(), seedId: data.seedId.orEmpty());

    final seed = await seedRepository.getSeedByUserId(event.ownerId.orEmpty());
    final farms = await farmRepository.getFarmByUserId(event.ownerId.orEmpty());

    maps
      ..sendAllUser(
          mapId: event.mapId,
          eventType: UserServerEventType.GARDEN_EVENT_RESULT.name,
          data: GardenEventResponse(
            type: GardenEventType.plantTree.name,
            farms: farms.map(FarmModel.fromMap).toList(),
          ))
      ..sendUser(
          mapId: event.mapId,
          userId: event.ownerId.orEmpty(),
          eventType: UserServerEventType.USER_INVENTORY.name,
          data: InventoryResponse(
            seeds: seed.map(SeedModel.fromMap).toList(),
          ));
  }
}
