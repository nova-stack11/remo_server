import 'package:shared_events/shared_events.dart';

import '../datasource/garden_datasource.dart';

class GardenRepository {
  GardenRepository({required this.datasource});
  final GardenDatasource datasource;

  Future<List<Map<String, dynamic>>> getGardenByUserId(String userId) {
    return datasource.getGardenByUserId(userId);
  }

  Future<GardenModel> getGardenById(String gardenId) async {
    final records = await datasource.getGardenById(gardenId);
    return GardenModel.fromMap(records.firstOrNull ?? {});
  }

  Future<bool> updatePlotState({
    required String userId,
    required int x,
    required int y,
    required String state,
  }) async {
    await datasource.updateGardenPlot(
      userId: userId,
      x: x,
      y: y,
      plotState: state,
    );
    return true;
  }

  Future<bool> updateState({
    required String gardenId,
    required String state,
  }) async {
    await datasource.updateState(
      gardenId: gardenId,
      plotState: state,
    );
    return true;
  }
}