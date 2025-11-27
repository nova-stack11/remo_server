import 'package:bonfire_server/src/components/game_map.dart';
import 'package:collection/collection.dart';
import 'package:shared_events/shared_events.dart';

import '../../../app_injector.dart';
import '../../../main.dart';
import '../../api/data/repositories/garden_repository.dart';

class GardenEventHandler {
  GardenEventHandler() {
    gardenRepository = AppInject.I.gardenRepository;
  }

  late final GardenRepository gardenRepository;

  void handleGardenEvent(List<GameMap> maps, GardenEvent event) {
    switch (event.toType()) {
      case GardenEventType.unlockPlot:
        _handleUnlockPlot(maps, event);
        break;
      case GardenEventType.plantTree:
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
      List<GameMap> maps, GardenEvent event) async {
    logger.i('_gardenUnlockPlot: ${event.toMap()}');
    final message = UnlockPlotData.fromMap(event.data);

    await gardenRepository.updateState(
        gardenId: message.id, state: GardenPlotState.unlocked.name);
    final garden = await gardenRepository.getGardenById(message.id);

    final map = maps.firstWhereOrNull((m) => m.id == message.mapId);
    if (map == null) {
      logger.e("Map ${message.mapId} not found for unlock plot");
      return;
    }

    for (final player in map.players) {
      player.send(
        UserServerEvent.GARDEN_EVENT_RESULT.name,
        garden,
      );
    }
  }
}
