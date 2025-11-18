import '../datasource/farm_datasource.dart';
import '../datasource/seed_datasource.dart';
import '../model/seed_model.dart';

class SeedRepository {
  SeedRepository({required this.datasource});

  final SeedDataSource datasource;

  Future<List<SeedModel>> getUserSeeds(String userId) async {
    final rows = await datasource.getUserSeeds(userId);
    return rows.map((e) => SeedModel.fromMap(e)).toList();
  }

  Future<SeedModel?> getSeedById(String seedId) async {
    final data = await datasource.getSeedById(seedId);
    if (data == null) return null;
    return SeedModel.fromMap(data);
  }
}