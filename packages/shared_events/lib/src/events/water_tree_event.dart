class WaterTreeEvent {
  final String mapId;
  final double x;
  final double y;

  WaterTreeEvent({
    required this.mapId,
    required this.x,
    required this.y,
  });

  Map<String, dynamic> toMap() => {
    'mapId': mapId,
    'x': x,
    'y': y,
  };

  factory WaterTreeEvent.fromMap(Map<String, dynamic> map) {
    return WaterTreeEvent(
      mapId: map['mapId'],
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
    );
  }
}