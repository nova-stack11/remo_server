
class UnlockPlotData {
  UnlockPlotData({required this.id, required this.mapId});

  final String id;
  final String mapId;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'mapId': mapId,
    };
  }

  factory UnlockPlotData.fromMap(Map<String, dynamic> map) {
    return UnlockPlotData(
      id: map['id'] ?? '',
      mapId: map['mapId'] ?? '',
    );
  }
}
