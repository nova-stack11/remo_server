import 'dart:async';
import 'dart:math';

import 'package:bonfire_server/bonfire_server.dart';
import 'package:collection/collection.dart';
import 'package:shared_events/shared_events.dart';

import '../../app_injector.dart';
import '../../main.dart';
import '../api/data/repositories/garden_repository.dart';
import '../infrastructure/websocket/websocket_provider.dart';
import '../util/string_helper.dart';
import 'components/garden_component.dart';
import 'components/player.dart';
import 'maps/home.dart';

class GameServer extends Game {
  GameServer({required this.server, required super.maps}) {
    gardenRepository = AppInject.I.gardenRepository;

    _registerTypes();
    _startFarmGrowLoop();
  }
  late final GardenRepository gardenRepository;

  static const tileSize = 32.0;

  List<WebsocketClient> clients = [];

  final WebsocketProvider server;

  void enterClient(WebsocketClient client) {
    clients.add(client);
    logger.i('Client(${client.id}) Connected!');
    client
      ..on<JoinEvent>(EventType.JOIN.name, (message) {
        logger.i('JoinEvent: ${message.toMap()}');
        _joinPlayerInTheGame(client, message);
      })
      ..on<MyChangeMapEvent>(EventType.CHANGE_MAP.name, (message) {
        _playerChangeMap(message);
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

  void _startFarmGrowLoop() {
    Timer.periodic(Duration(seconds: 10), (_) {
      _updateFarmGrowth();
    });
  }

  void _playerChangeMap(MyChangeMapEvent message) {
    final player =
        maps.expand((m) => m.components.whereType<Player>()).firstWhereOrNull(
              (p) => p.id == message.userId,
            );
    if (player == null) {
      logger.e("Player with id ${message.userId} not found for CHANGE_MAP");
      return;
    }

    // Create or get target map
    final targetMap = getOrCreateMap(message.mapId);

    // Change map
    changeMap(
      player,
      targetMap.id,
      player.state.position,
    );
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

  GameMap getOrCreateMap(String id) {
    return maps.firstWhere(
      (m) => m.id == id,
      orElse: () {
        final newMap = HomeMap(id: id);
        maps.add(newMap);
        add(newMap);
        newMap.load();
        return newMap;
      },
    );
  }

  void _joinPlayerInTheGame(WebsocketClient client, JoinEvent message) {
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
    // Adds Player

    final player = Player(
      state: ComponentStateModel(
        id: message.userId,
        name: message.name,
        position: position,
        size: GameVector.all(16),
        life: 100,
        properties: {
          'skin': message.skin,
        },
      ),
      client: client,
    );

    final initialMap = getOrCreateMap(message.map)..add(player);

    // send ACK to client that request join.
    onPlayerChangeMap(player, initialMap);
  }

  @override
  void onPlayerChangeMap(GamePlayer player, GameMap map) async {
    final ownerId = map.id.split("_").lastOrNull;

    // 2. load garden plots của user
    final garden = await gardenRepository.getGarden(ownerId.orEmpty());

    print(">>>>>>> garden=${garden.length}");
    // 3. convert sang list json
    // final gardenJson = garden.map((e) => e.toJson()).toList();

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
      ..registerType<MyChangeMapEvent>(
        TypeAdapter(
          toMap: (type) => type.toMap(),
          fromMap: MyChangeMapEvent.fromMap,
        ),
      )
      ..registerType<JoinMapEvent>(
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
