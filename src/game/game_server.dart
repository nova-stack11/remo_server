import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:bonfire_server/bonfire_server.dart';
import 'package:collection/collection.dart';
import 'package:shared_events/shared_events.dart';

import '../../app_injector.dart';
import '../../main.dart';
import '../api/data/repositories/farm_repository.dart';
import '../api/data/repositories/garden_repository.dart';
import '../api/data/repositories/seed_repository.dart';
import '../api/data/repositories/user_map_state_repository.dart';
import '../infrastructure/websocket/websocket_provider.dart';
import 'components/garden_component.dart';
import 'components/player.dart';
import 'event_handler/garden_event_handler.dart';
import 'maps/home.dart';

class GameServer extends Game {
  GameServer({required this.server, required super.maps}) {
    WebsocketRegisterType.registerTypes(server);
    _startFarmGrowLoop();
  }

  late final GardenRepository _gardenRepository = AppInject.I.gardenRepository;
  late final FarmRepository _farmRepository = AppInject.I.farmRepository;
  late final SeedRepository _seedRepository = AppInject.I.seedRepository;
  late final UserMapStateRepository _userMapStateRepository = AppInject.I.userMapStateRepository;
  late final GardenEventHandler _gardenEventHandler =
      AppInject.I.gardenEventHandler;

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
      ..on<GardenEventRequest>(
        UserClientEventType.GARDEN_EVENT.name,
        (event) => _gardenEventHandler.handleGardenEvent(maps, event),
      )
      ..on<InventoryRequest>(
        UserClientEventType.USER_INVENTORY.name,
        (event) {
          sendUserInventory(client, event.userId);
        },
      )
      ..on<MyChangeMapEvent>(EventType.CHANGE_MAP.name, _playerChangeMap);
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

  void _joinPlayerInTheGame(WebsocketClient client, JoinEvent message) async {
    // Prevent duplicate players
    if (_isPlayerAlreadyJoined(message.userId)) return;

    final mapState = await _getSavedMapState(message.userId);
    final mapId = mapState.savedMapId;
    final position = _resolveSpawnPosition(mapState);

    final player = _createPlayer(client, message, position);
    await _spawnPlayerOnMap(player, mapId);
  }

  bool _isPlayerAlreadyJoined(String userId) {
    return components.whereType<Player>().any((p) => p.id == userId);
  }

  Future<_SavedMapState> _getSavedMapState(String userId) async {
    final mapState = await _userMapStateRepository.getStateByUserId(userId);
    return _SavedMapState(
      savedMapId: mapState?.getOrNull('map_id')?.toString(),
      x: mapState?.getOrNull('pos_x') as double?,
      y: mapState?.getOrNull('pos_y') as double?,
    );
  }

  GameVector _resolveSpawnPosition(_SavedMapState state) {
    if (state.x != null && state.y != null) {
      return GameVector(x: state.x!, y: state.y!);
    }
    return GameVector(
      x: (3 + Random().nextInt(3)) * tileSize,
      y: 11 * tileSize,
    );
  }

  Player _createPlayer(
    WebsocketClient client,
    JoinEvent message,
    GameVector position,
  ) {
    return Player(
      state: ComponentStateModel(
        id: message.userId,
        name: message.name,
        position: position,
        size: GameVector.all(16),
        life: 100,
        properties: {'skin': message.skin},
      ),
      client: client,
    );
  }

  Future<void> _spawnPlayerOnMap(Player player, String? mapId) async {
    final targetMap = getOrCreateMap(mapId ?? "default_map");
    targetMap.add(player);
    onPlayerChangeMap(player, targetMap);
  }

  @override
  void onPlayerChangeMap(GamePlayer player, GameMap map) async {
    final mapData = map.toModel();
    final garden = await _gardenRepository.getGardenByUserId(mapData.ownerId().orEmpty());
    final farm = await _farmRepository.getFarmByUserId(mapData.ownerId().orEmpty());
    player.send(
      EventType.JOIN_MAP.name,
      JoinMapEvent(
        state: player.state,
        players: map.playersState,
        npcs: map.npcsState,
        map: map.toModel(),
        garden: garden.map(GardenModel.fromMap),
        farms: farm.map(FarmModel.fromMap),
      ),
    );
  }

  void sendUserInventory(WebsocketClient client, String userId) async {
    final seed = await _seedRepository.getSeedByUserId(userId);
    // final farm = await _farmRepository.getFarmByUserId(userId);
    client.send(
      UserServerEventType.USER_INVENTORY.name,
      InventoryResponse(
        seeds: seed.map(SeedModel.fromMap),
        // farms: farm.map(FarmModel.fromMap),
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

class _SavedMapState {
  final String? savedMapId;
  final double? x;
  final double? y;
  _SavedMapState({this.savedMapId, this.x, this.y});
}