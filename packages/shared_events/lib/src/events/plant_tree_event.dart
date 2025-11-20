// ignore_for_file: public_member_api_docs, sort_constructors_first

class PlantTreeEvent {
  PlantTreeEvent({
    required this.mapId,
    required this.seedId,
    required this.x,
    required this.y,
  });

  final String mapId;
  final String seedId;
  final double x;
  final double y;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'mapId': mapId,
      'seedId': seedId,
      'x': x,
      'y': y,
    };
  }

  factory PlantTreeEvent.fromMap(Map<String, dynamic> map) {
    return PlantTreeEvent(
      mapId: map['mapId'] as String,
      seedId: map['seedId'] as String,
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
    );
  }
}