// ignore_for_file: public_member_api_docs, sort_constructors_first
enum GardenEventType {
  unlockPlot,
  plantTree,
  waterTree,
  harvestTree,
  removeTree,
  none
}


extension GardenEventTypeExt on GardenEventType {
  String get value => name;

  static GardenEventType fromString(String s) {
    return GardenEventType.values.firstWhere(
          (e) => e.name == s,
      orElse: () => GardenEventType.none,
    );
  }
}
