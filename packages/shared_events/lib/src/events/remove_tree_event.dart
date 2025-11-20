class RemoveTreeEvent {
  final String mapId;
  final double x;
  final double y;

  RemoveTreeEvent({
    required this.mapId,
    required this.x,
    required this.y,
  });

  Map<String, dynamic> toMap() => {
    'mapId': mapId,
    'x': x,
    'y': y,
  };

  factory RemoveTreeEvent.fromMap(Map<String, dynamic> map) {
    return RemoveTreeEvent(
      mapId: map['mapId'],
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
    );
  }
}