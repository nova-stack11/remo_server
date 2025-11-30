import 'package:shared_events/shared_events.dart';
import 'package:shared_events/src/model/farm_model.dart';

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
    websocket.registerType<InventoryResponse>(
      TypeAdapter(
        toMap: (type) => type.toMap(),
        fromMap: InventoryResponse.fromMap,
      ),
    );
    websocket.registerType<InventoryRequest>(
      TypeAdapter(
        toMap: (type) => type.toMap(),
        fromMap: InventoryRequest.fromMap,
      ),
    );
    websocket.registerType<GardenDataRequest>(
      TypeAdapter(
        toMap: (type) => type.toMap(),
        fromMap: GardenDataRequest.fromMap,
      ),
    );

    websocket.registerType<GardenEventRequest>(
      TypeAdapter(
        toMap: (type) => type.toMap(),
        fromMap: GardenEventRequest.fromMap,
      ),
    );
    websocket.registerType<GardenEventResponse>(
      TypeAdapter(
        toMap: (type) => type.toMap(),
        fromMap: GardenEventResponse.fromMap,
      ),
    );
    websocket.registerType<FarmModel>(
      TypeAdapter(
        toMap: (type) => type.toMap(),
        fromMap: FarmModel.fromMap,
      ),
    );
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
