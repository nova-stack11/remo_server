import '../datasource/garden_datasource.dart';

class GardenRepository {
  GardenRepository({required this.datasource});
  final GardenDatasource datasource;

  Future<List<Map<String, dynamic>>> getGarden(String userId) {
    return datasource.getGardenPlots(userId);
  }

  Future<bool> updatePlotState({
    required String userId,
    required String plotCode,
    required String state,
  }) async {
    await datasource.updateGardenPlot(
      userId: userId,
      plotCode: plotCode,
      plotState: state,
    );
    return true;
  }
}