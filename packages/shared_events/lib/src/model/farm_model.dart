// ignore_for_file: public_member_api_docs, sort_constructors_first

class FarmModel {
  final String? id;
  final String? plotId;
  final String? seedId;
  final String? plantedAt;
  final String? lastWateredAt;
  final int? stage;
  final bool? isDead;
  final bool? needWater;
  final String? witheredAt;

  final String? seedName;
  final String? image;

  final int? growDuration;
  final int? waterInterval;

  final String? userId;
  final int? x;
  final int? y;

  FarmModel({
    this.id,
    this.plotId,
    this.seedId,
    this.plantedAt,
    this.lastWateredAt,
    this.stage,
    this.isDead,
    this.needWater,
    this.witheredAt,
    this.seedName,
    this.image,
    this.growDuration,
    this.waterInterval,
    this.userId,
    this.x,
    this.y,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'garden_id': plotId,
      'seed_id': seedId,
      'planted_at': plantedAt,
      'last_watered_at': lastWateredAt,
      'stage': stage,
      'is_dead': isDead,
      'need_water': needWater,
      'withered_at': witheredAt,
      'seed_name': seedName,
      'image': image,
      'grow_duration': growDuration,
      'water_interval': waterInterval,
      'user_id': userId,
      'x': x,
      'y': y,
    };
  }

  factory FarmModel.fromMap(Map<String, dynamic> map) {
    return FarmModel(
      id: map['id'] as String?,
      plotId: map['garden_id'] as String?,
      seedId: map['seed_id'] as String?,
      plantedAt: map['planted_at'] as String?,
      lastWateredAt: map['last_watered_at'] as String?,
      stage: map['stage'] as int?,
      isDead: map['is_dead'] as bool?,
      needWater: map['need_water'] as bool?,
      witheredAt: map['withered_at'] as String?,
      seedName: map['seed_name'] as String?,
      image: map['image'] as String?,
      growDuration: map['grow_duration'] as int?,
      waterInterval: map['water_interval'] as int?,
      userId: map['user_id'] as String?,
      x: map['x'] as int?,
      y: map['y'] as int?,
    );
  }
}
