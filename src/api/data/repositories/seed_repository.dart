import '../datasource/seed_datasource.dart';

class SeedRepository {
  SeedRepository({required this.datasource});

  final SeedDataSource datasource;

  Future<List<Map<String, dynamic>>> getSeedByUserId(String userId) async {
    final rows = await datasource.getSeedByUserId(userId);
    return rows;
  }

  Future<Map<String, dynamic>?> getSeedById(String? seedId) async {
    final data = await datasource.getSeedById(seedId);
    return data;
  }

  Future<void> decreaseQuantity(String id) async {
    await datasource.decreaseQuantity(id);
  }
}