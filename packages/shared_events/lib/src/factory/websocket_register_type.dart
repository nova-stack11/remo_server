import 'package:shared_events/shared_events.dart';
import 'package:shared_events/src/provider/base_websocket_provider.dart';

class WebsocketRegisterType {
  static void registerTypes(BaseWebsocketProvider websocket) {
    websocket.registerType<GardenModel>(
      TypeAdapter(
        toMap: (type) => type.toMap(),
        fromMap: GardenModel.fromMap,
      ),
    );
    websocket.registerType<JoinMapEvent>(
      TypeAdapter(
        toMap: (type) => type.toMap(),
        fromMap: JoinMapEvent.fromMap,
      ),
    );
    websocket.registerType<GardenEvent>(
      TypeAdapter(
        toMap: (type) => type.toMap(),
        fromMap: GardenEvent.fromMap,
      ),
    );
    // websocket.registerType<UnlockPlotData>(
    //   TypeAdapter(
    //     toMap: (type) => type.toMap(),
    //     fromMap: UnlockPlotData.fromMap,
    //   ),
    // );
    websocket.registerType<JoinEvent>(
      TypeAdapter(
        toMap: (type) => type.toMap(),
        fromMap: JoinEvent.fromMap,
      ),
    );
    websocket.registerType<MyChangeMapEvent>(
      TypeAdapter(
        toMap: (type) => type.toMap(),
        fromMap: MyChangeMapEvent.fromMap,
      ),
    );
    websocket.registerType<GameStateModel>(
      TypeAdapter(
        toMap: (type) => type.toMap(),
        fromMap: GameStateModel.fromMap,
      ),
    );
    websocket.registerType<MoveEvent>(
      TypeAdapter(
        toMap: (type) => type.toMap(),
        fromMap: MoveEvent.fromMap,
      ),
    );
    websocket.registerType<PlayerEvent>(
      TypeAdapter(
        toMap: (type) => type.toMap(),
        fromMap: PlayerEvent.fromMap,
      ),
    );
  }
}
