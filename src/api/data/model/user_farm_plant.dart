class UserFarmPlant {
  final String id;
  final String userId;
  final String seedId;
  final int x;
  final int y;
  final String plantedAt;
  final String lastWateredAt;
  final int stage;
  final bool isDead;
  final String? witheredAt;

  UserFarmPlant({
    required this.id,
    required this.userId,
    required this.x,
    required this.y,
    required this.seedId,
    required this.plantedAt,
    required this.lastWateredAt,
    required this.stage,
    required this.isDead,
    required this.witheredAt,
  });

  factory UserFarmPlant.fromMap(Map<String, dynamic> map) {
    return UserFarmPlant(
      id: map['id'].toString(),
      userId: map['user_id'].toString(),
      x: map['x'] as int,
      y: map['y'] as int,
      seedId: map['seed_id'] as String,
      plantedAt: map['planted_at'].toString(),
      lastWateredAt: map['last_watered_at'].toString(),
      stage: map['stage'] as int,
      isDead: map['is_dead'] == true || map['is_dead'] == 1,
      witheredAt: map['withered_at'].toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'x': x,
      'y': y,
      'seed_id': seedId,
      'planted_at': plantedAt,
      'last_watered_at': lastWateredAt,
      'stage': stage,
      'is_dead': isDead,
      'withered_at': witheredAt,
    };
  }
}