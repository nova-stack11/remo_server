import 'package:bonfire_server/bonfire_server.dart';
import 'package:shared_events/shared_events.dart';

import '../components/map_gateway.dart';
import '../game_server.dart';

class HomeMap extends GameMap with GameRef<GameServer> {
  HomeMap({
    required super.id,
    super.name = 'home',
    super.path = 'maps/map3/map1.tmj',
  });

  @override
  void onObjectBuilder(GameMapObjectProperties object) {
    if (object.typeOrClass == 'gateway') {
      add(
        MapGateway(
          position: object.position,
          size: object.size,
          mapTagetId: object.properties['mapId'].toString(),
          targetPlayerPosition: GameVector(
            x: double.parse(object.properties['x'].toString()),
            y: double.parse(object.properties['y'].toString()),
          ),
        ),
      );
    }
  }
}
