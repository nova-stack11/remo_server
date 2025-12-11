import '../datasource/presence_datasource.dart';

class PresenceRepository {
  PresenceRepository({required this.datasource});

  final PresenceDataSource datasource;

  /// Update user's online status
  Future<void> updateUserStatus({
    required String userId,
    required String status, // 'online', 'offline', 'away'
  }) async {
    if (!['online', 'offline', 'away'].contains(status)) {
      throw Exception('Invalid status. Must be: online, offline, or away');
    }

    await datasource.updateUserStatus(
      userId: userId,
      status: status,
    );
  }

  /// Get a single user's status
  Future<Map<String, dynamic>?> getUserStatus({
    required String userId,
  }) async {
    return datasource.getUserStatus(userId: userId);
  }

  /// Get status for multiple users (batch)
  Future<List<Map<String, dynamic>>> getUsersStatus({
    required List<String> userIds,
  }) async {
    if (userIds.isEmpty) return [];

    return datasource.getUsersStatus(userIds: userIds);
  }

  /// Update user's last seen timestamp
  Future<void> updateLastSeen({
    required String userId,
  }) async {
    await datasource.updateLastSeen(userId: userId);
  }

  /// Get list of online friends for a user
  Future<List<Map<String, dynamic>>> getOnlineFriends({
    required String userId,
  }) async {
    return datasource.getOnlineFriends(userId: userId);
  }

  /// Set user as online
  Future<void> setUserOnline({
    required String userId,
  }) async {
    await updateUserStatus(userId: userId, status: 'online');
  }

  /// Set user as offline
  Future<void> setUserOffline({
    required String userId,
  }) async {
    await updateUserStatus(userId: userId, status: 'offline');
  }

  /// Set user as away
  Future<void> setUserAway({
    required String userId,
  }) async {
    await updateUserStatus(userId: userId, status: 'away');
  }
}
