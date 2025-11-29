import 'package:bonfire_server/src/components/game_map.dart';
import 'package:collection/collection.dart';
import 'package:shared_events/shared_events.dart';

import '../../../app_injector.dart';
import '../../../main.dart';
import '../../api/data/repositories/farm_repository.dart';
import '../../api/data/repositories/garden_repository.dart';
import '../../api/data/repositories/seed_repository.dart';
import '../../extension/game_map_ext.dart';
import '../../extension/object_ext.dart';

class GardenEventHandler {
  GardenEventHandler() {}

  late final GardenRepository gardenRepository = AppInject.I.gardenRepository;
  late final SeedRepository seedRepository = AppInject.I.seedRepository;
  late final FarmRepository farmRepository = AppInject.I.farmRepository;

  void handleGardenEvent(List<GameMap> maps, GardenEventRequest event) {
    switch (event.toType()) {
      case GardenEventType.unlockPlot:
        _handleUnlockPlot(maps, event);
        break;
      case GardenEventType.plantTree:
        _handlePlantTree(maps, event);
        break;
      case GardenEventType.waterTree:
        break;
      case GardenEventType.harvestTree:
        break;
      case GardenEventType.removeTree:
        break;
      default:
        break;
    }
  }

  Future<void> _handleUnlockPlot(
      List<GameMap> maps, GardenEventRequest event) async {
    final message = UnlockPlotDataRequest.fromMap(event.data ?? {});

    await gardenRepository.updateState(
        gardenId: message.id, state: GardenPlotState.unlocked.name);
    final garden = await gardenRepository.getGardenById(message.id);

    maps.sendAllUser(
        mapId: event.mapId,
        eventType: UserServerEventType.GARDEN_EVENT_RESULT.name,
        data: GardenEventResponse(
            type: GardenEventType.unlockPlot.name, gardenPlots: [garden]));
  }

  Future<void> _handlePlantTree(
      List<GameMap> maps, GardenEventRequest event) async {
    if(!event.validated()) return;

    final data = PlotSeedRequest.fromMap(event.data ?? {});

    if (!data.validated()) return;

    await seedRepository.decreaseQuantity(data.userSeedId.orEmpty());
    await farmRepository.insertPlant(
        gardenId: data.plotId.orEmpty(), seedId: data.seedId.orEmpty());

    final seed = await seedRepository.getSeedByUserId(event.ownerId.orEmpty());
    final farms = await farmRepository.getFarmByUserId(event.ownerId.orEmpty());

    maps..sendAllUser(
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
