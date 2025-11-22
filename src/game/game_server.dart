import 'dart:async';
import 'dart:math';

import 'package:bonfire_server/bonfire_server.dart';
import 'package:shared_events/shared_events.dart';
import 'package:collection/collection.dart';

import '../../main.dart';
import '../infrastructure/websocket/websocket_provider.dart';
import 'components/garden_component.dart';
import 'components/player.dart';
import 'maps/home.dart';
// import 'events/plant_tree_event.dart';

class GameServer extends Game {
  GameServer({required this.server, required super.maps}) {
    _registerTypes();
    _startFarmGrowLoop();
  }

  static const tileSize = 16.0;

  List<WebsocketClient> clients = [];

  final WebsocketProvider server;

  void enterClient(WebsocketClient client) {
    clients.add(client);

    logger.i('Client(${client}) Connected!');
    client
      ..on<JoinEvent>(EventType.JOIN.name, (message) {
        logger.i('JoinEvent: ${message.toMap()}');
        _joinPlayerInTheGame(client, message);
      })
      ..on<ChangeMapEvent>(EventType.CHANGE_MAP.name, (msg) {
        // Find the player by userId
        final player = maps
            .expand((m) => m.components.whereType<Player>())
            .firstWhereOrNull((p) => p.id == msg.userId);

        if (player == null) {
          logger.e("⚠️ Player with id ${msg.userId} not found for ChangeMap");
          return;
        }

        // Ensure the map exists, create home if needed
        _createHomeMapIfNotExists(msg.mapId);

        // Find target map
        final newMap = maps.firstWhere((m) => m.id == msg.mapId);

        // Execute map change
        print(">>>>>>>>> player =${player.id}, =${newMap.id}");
        changeMap(player, newMap.id, player.state.position);
      })
      ..on<PlantTreeEvent>(EventType.PLANT_TREE.name, (msg) {
        _onPlantTree(client, msg);
      })
      ..on<WaterTreeEvent>(EventType.WATER_TREE.name, (msg) {
        _onWaterTree(client, msg);
      })
      ..on<HarvestTreeEvent>(EventType.HARVEST_TREE.name, (msg) {
        _onHarvestTree(client, msg);
      })
      ..on<RemoveTreeEvent>(EventType.REMOVE_TREE.name, (msg) {
        _onRemoveTree(client, msg);
      });
  }

  void _createHomeMapIfNotExists(String mapId) {
    if (maps.any((m) => m.id == mapId)) return;

    final homeMap = HomeMap(id: mapId);
    maps.add(homeMap);
  }

  void _startFarmGrowLoop() {
    Timer.periodic(Duration(seconds: 10), (_) {
      _updateFarmGrowth();
    });
  }

  void _updateFarmGrowth() {
    for (final map in maps) {
      for (final tree in map.components.whereType<GardenComponent>()) {
        if (_shouldGrow(tree)) {
          tree.stage++;
          tree.wateredAt = null;

          requestUpdate();
        }
      }
    }
  }

  void _onPlantTree(WebsocketClient client, PlantTreeEvent msg) {
    final map = maps.firstWhere((m) => m.id == msg.mapId);

    final tree = GardenComponent(
      seedId: msg.seedId,
      stage: 0,
      position: GameVector(x: msg.x, y: msg.y),
      size: GameVector.all(16),
    );

    map.add(tree);
    requestUpdate();
  }

  void _onWaterTree(WebsocketClient client, WaterTreeEvent msg) {
    final map = maps.firstWhere((m) => m.id == msg.mapId);

    final tree = map.components.whereType<GardenComponent>().firstWhere(
          (t) => t.position.x == msg.x && t.position.y == msg.y,
        );

    if (tree == null) return;

    tree.wateredAt = DateTime.now();
    requestUpdate();
  }

  void _onHarvestTree(WebsocketClient client, HarvestTreeEvent msg) {
    final map = maps.firstWhere((m) => m.id == msg.mapId);

    final tree = map.components.whereType<GardenComponent>().firstWhere(
          (t) => t.position.x == msg.x && t.position.y == msg.y,
        );

    if (tree == null) return;
    if (tree.stage < 3) return;

    // reward item here
    // userRepo.addItem(client.id, tree.seedId);

    tree.removeFromParent();
    requestUpdate();
  }

  void _onRemoveTree(WebsocketClient client, RemoveTreeEvent msg) {
    final map = maps.firstWhere((m) => m.id == msg.mapId);

    final tree = map.components.whereType<GardenComponent>().firstWhere(
          (t) => t.position.x == msg.x && t.position.y == msg.y,
        );

    if (tree == null) return;

    tree.removeFromParent();
    requestUpdate();
  }

  void leaveClient(WebsocketClient client) {
    clients.remove(client);
    for (final map in maps) {
      map.components
          .whereType<Player>()
          .where((element) => element.client.id == client.id)
          .forEach((element) => element.removeFromParent());
    }
    requestUpdate();
    logger.i('Client(${client.id}) Disconnected!');
  }

  bool _shouldGrow(GardenComponent tree) {
    if (tree.stage >= 3) return false;
    if (tree.wateredAt == null) return false;

    return DateTime.now().difference(tree.wateredAt!).inMinutes >= 2;
  }

  @override
  void updateListeners(GameComponent compChanged) {
    if (compChanged is GameMap) {
      if (compChanged.players.isEmpty) {
        return;
      }
      final players = compChanged.playersState;
      final npcs = compChanged.npcsState;

      for (final player in compChanged.players) {
        player.send(
          EventType.UPDATE_STATE.name,
          GameStateModel(
            players: players,
            npcs: npcs,
          ),
        );
      }
    }
  }

  void _joinPlayerInTheGame(WebsocketClient client, JoinEvent message) async {
    // ✅ Check if user exists before joining
    // final userRepo = injector.read<IUserRepository>();
    // final user = await userRepo.getUserById(client.id);
    //
    // if (user == null) {
    //   client.send(
    //     EventType.ERROR.name,
    //     {'error': 'User not found, cannot join game'},
    //   );
    //   logger.w('❌ User(${client.id}) not found in DB — join denied.');
    //   return;
    // }

    if (components
        .whereType<Player>()
        .any((element) => element.id == message.userId)) {
      return;
    }

    // Create initial position
    final position = GameVector(
      x: (3 + Random().nextInt(3)) * tileSize,
      y: 11 * tileSize,
    );

    final mapId = "home_${message.userId}";
    _createHomeMapIfNotExists(mapId);

    // Adds Player
    final player = Player(
      state: ComponentStateModel(
        id: message.userId,
        name: message.name,
        position: position,
        size: GameVector.all(32),
        life: 100,
        properties: {
          'skin': message.skin,
        },
      ),
      client: client,
    );

    final initialMap = maps.firstWhere(
      (m) => m.id == "home_${message.userId}",
    )..add(player);

    // send ACK to client that request join.
    client.send(
      EventType.JOIN_MAP.name,
      JoinMapEvent(
        state: player.state,
        players: initialMap.playersState,
        npcs: initialMap.npcsState,
        map: initialMap.toModel(),
      ),
    );
  }

  void onPlayerChangeMap(GamePlayer player, GameMap map) {
    print(">>>>>>> change 2 =${map.toModel().toMap()}");
    player.send(
      EventType.JOIN_MAP.name,
      JoinMapEvent(
        state: player.state,
        players: map.playersState,
        npcs: map.npcsState,
        map: map.toModel(),
      ),
    );
  }

  void _registerTypes() {
    server
      ..registerType<JoinEvent>(
        TypeAdapter(
          toMap: (type) => type.toMap(),
          fromMap: JoinEvent.fromMap,
        ),
      )
      ..registerType<ChangeMapEvent>(
        TypeAdapter(
          toMap: (type) => type.toMap(),
          fromMap: ChangeMapEvent.fromMap,
        ),
      )    ..registerType<JoinMapEvent>(
        TypeAdapter(
          toMap: (type) => type.toMap(),
          fromMap: JoinMapEvent.fromMap,
        ),
      )
      ..registerType<GameStateModel>(
        TypeAdapter(
          toMap: (type) => type.toMap(),
          fromMap: GameStateModel.fromMap,
        ),
      )
      ..registerType<PlayerEvent>(
        TypeAdapter(
          toMap: (type) => type.toMap(),
          fromMap: PlayerEvent.fromMap,
        ),
      )
      ..registerType<MoveEvent>(
        TypeAdapter(
          toMap: (type) => type.toMap(),
          fromMap: MoveEvent.fromMap,
        ),
      )
      ..registerType<PlantTreeEvent>(
        TypeAdapter(
          toMap: (e) => e.toMap(),
          fromMap: PlantTreeEvent.fromMap,
        ),
      )
      ..registerType<WaterTreeEvent>(
        TypeAdapter(
          toMap: (e) => e.toMap(),
          fromMap: WaterTreeEvent.fromMap,
        ),
      )
      ..registerType<HarvestTreeEvent>(
        TypeAdapter(
          toMap: (e) => e.toMap(),
          fromMap: HarvestTreeEvent.fromMap,
        ),
      )
      ..registerType<ChangeMapEvent>(
        TypeAdapter(
          toMap: (e) => e.toMap(),
          fromMap: ChangeMapEvent.fromMap,
        ),
      )
      ..registerType<RemoveTreeEvent>(
        TypeAdapter(
          toMap: (e) => e.toMap(),
          fromMap: RemoveTreeEvent.fromMap,
        ),
      );
  }

  @override
  Future<void> onLoadMaps() {
    logger.d('Loading maps...');
    return super.onLoadMaps();
  }

  @override
  void onStart() {
    logger.i('Start Game loop');
    super.onStart();
  }

  @override
  void stop() {
    logger.i('Stop Game loop');
    super.stop();
  }
}
