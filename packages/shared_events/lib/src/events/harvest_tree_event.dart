class HarvestTreeEvent {
  final String mapId;
  final double x;
  final double y;

  HarvestTreeEvent({
    required this.mapId,
    required this.x,
    required this.y,
  });

  Map<String, dynamic> toMap() => {
    'mapId': mapId,
    'x': x,
    'y': y,
  };

  factory HarvestTreeEvent.fromMap(Map<String, dynamic> map) {
    return HarvestTreeEvent(
      mapId: map['mapId'],
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
    );
  }
}