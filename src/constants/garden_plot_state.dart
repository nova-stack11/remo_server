enum GardenPlotState {
  locked,       // ô bị khóa
  unlocked,     // ô mở khóa
  planting,     // đang trồng
  growing,      // đang phát triển
  completed,    // đã thu hoạch
  blocked,      // bị lỗi/hỏng
}

extension GardenPlotStateExt on GardenPlotState {
  String get value => name;

  static GardenPlotState fromString(String s) {
    return GardenPlotState.values.firstWhere(
          (e) => e.name == s,
      orElse: () => GardenPlotState.locked,
    );
  }
}