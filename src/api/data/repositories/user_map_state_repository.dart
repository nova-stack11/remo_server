import '../datasource/user_map_state_datasource.dart';

class UserMapStateRepository {
  final UserMapStateDataSource datasource;

  UserMapStateRepository({required this.datasource});

  Future<Map<String, dynamic>?> getStateByUserId(String userId) {
    return datasource.getStateByUserId(userId);
  }

  Future<void> saveState({
    required String userId,
    required String mapId,
    required double posX,
    required double posY,
    required String direction,
  }) {
    return datasource.saveState(
      userId: userId,
      mapId: mapId,
      posX: posX,
      posY: posY,
      direction: direction,
    );
  }
}