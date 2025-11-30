import '../datasource/user_datasource.dart';

class UserWsRepository {
  UserWsRepository({required this.datasource});

  final UserDataSource datasource;

  Future<void> plusCoin({
    required String userId,
    required int amount,
  }) async {
    await datasource.plusCoin(
      userId: userId,
      amount: amount,
    );
  }
}
