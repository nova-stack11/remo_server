import 'package:bonfire_server/bonfire_server.dart';
import 'package:collection/collection.dart';

extension GameMapSenderExt on List<GameMap> {
  void sendAllUser<T>({
    required String mapId,
    required String eventType,
    required T data,
  }) {
    final map = firstWhereOrNull((m) => m.id == mapId);
    if (map == null) {
      return;
    }

    for (final player in map.players) {
      player.send(
        eventType,
        data,
      );
    }
  }

   void sendUser<T>({
    required String mapId,
    required String userId,
    required String eventType,
    required T data,
  }) {
    final map = firstWhereOrNull((m) => m.id == mapId);
    if (map == null) {
      return;
    }

    final player = map.players.firstWhereOrNull((p) => p.state.id == userId);
    if (player == null) {
      return;
    }

    player.send(
      eventType,
      data,
    );
  }


}
