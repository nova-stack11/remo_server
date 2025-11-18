import '../datasource/garden_datasource.dart';

class GardenRepository {
  GardenRepository({required this.datasource});
  final GardenDatasource datasource;

  Future<List<Map<String, dynamic>>> getGarden(String userId) {
    return datasource.getGardenPlots(userId);
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
}