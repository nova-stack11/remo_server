import '../datasource/friend_datasource.dart';

class FriendRepository {
  FriendRepository({required this.datasource});

  final FriendDataSource datasource;

  Future<Map<String, dynamic>> sendRequest({
    required String fromUserId,
    required String toUserId,
    String? message,
  }) async {
    if (fromUserId == toUserId) {
      throw Exception('Cannot send friend request to yourself');
    }
    // guards
    if (await datasource.isBlockedEither(a: fromUserId, b: toUserId)) {
      throw Exception('Cannot send friend request due to block relation');
    }
    if (await datasource.isFriends(a: fromUserId, b: toUserId)) {
      throw Exception('Users are already friends');
    }
    // prevent duplicates
    if (await datasource.hasPendingBetween(fromUserId: fromUserId, toUserId: toUserId)) {
      throw Exception('A pending request already exists');
    }

    // Mutual pending -> auto-accept
    final reversePendingId = await datasource.findPendingRequestId(
      fromUserId: toUserId,
      toUserId: fromUserId,
    );
    if (reversePendingId != null) {
      // Accept both in one go
      await datasource.createFriendPair(a: fromUserId, b: toUserId);
      await datasource.setRequestStatus(requestId: reversePendingId, status: 'accepted');
      // Create a record for tracking (optional), but we can also mark as accepted if created
      final created = await datasource.createRequest(
        fromUserId: fromUserId,
        toUserId: toUserId,
        message: message,
      );
      await datasource.setRequestStatus(requestId: created['id'] as String, status: 'accepted');
      return created;
    }

    // Normal pending creation
    final created = await datasource.createRequest(
      fromUserId: fromUserId,
      toUserId: toUserId,
      message: message,
    );
    return created;
  }

  Future<List<Map<String, dynamic>>> getIncomingRequests({
    required String userId,
    String status = 'pending',
  }) async {
    return datasource.getRequests(toUserId: userId, status: status);
  }

  Future<void> acceptRequest({
    required String requestId,
    required String currentUserId,
  }) async {
    final req = await datasource.getRequestById(requestId);
    if (req == null) {
      throw Exception('Request not found');
    }
    if (req['to_user_id'] != currentUserId) {
      throw Exception('Not authorized to accept this request');
    }
    if (req['status'] != 'pending') {
      throw Exception('Request is not pending');
    }

    await datasource.createFriendPair(a: req['from_user_id'] as String, b: req['to_user_id'] as String);
    await datasource.setRequestStatus(requestId: requestId, status: 'accepted');
  }

  Future<void> rejectRequest({
    required String requestId,
    required String currentUserId,
  }) async {
    final req = await datasource.getRequestById(requestId);
    if (req == null) {
      throw Exception('Request not found');
    }
    if (req['to_user_id'] != currentUserId) {
      throw Exception('Not authorized to reject this request');
    }
    if (req['status'] != 'pending') {
      throw Exception('Request is not pending');
    }
    await datasource.setRequestStatus(requestId: requestId, status: 'rejected');
  }

  Future<void> cancelRequest({
    required String requestId,
    required String currentUserId,
  }) async {
    final req = await datasource.getRequestById(requestId);
    if (req == null) {
      throw Exception('Request not found');
    }
    if (req['from_user_id'] != currentUserId) {
      throw Exception('Not authorized to cancel this request');
    }
    if (req['status'] != 'pending') {
      throw Exception('Request is not pending');
    }
    await datasource.setRequestStatus(requestId: requestId, status: 'canceled');
  }

  Future<List<Map<String, dynamic>>> listFriends(String userId) async {
    return datasource.listFriends(userId: userId);
  }
}
