// ignore_for_file: public_member_api_docs, sort_constructors_first

class FarmModel {
  final String? id;
  final String? plotId;
  final String? plantedAt;
  final String? lastWateredAt;
  final int? stage;
  final bool? isDead;
  final String? witheredAt;

  final String? seedName;
  final String? stage1Image;
  final String? stage2Image;
  final String? stage3Image;

  final int? growDuration;
  final int? waterInterval;

  final String? userId;
  final int? x;
  final int? y;

  FarmModel({
    this.id,
    this.plotId,
    this.plantedAt,
    this.lastWateredAt,
    this.stage,
    this.isDead,
    this.witheredAt,
    this.seedName,
    this.stage1Image,
    this.stage2Image,
    this.stage3Image,
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
      'planted_at': plantedAt,
      'last_watered_at': lastWateredAt,
      'stage': stage,
      'is_dead': isDead,
      'withered_at': witheredAt,
      'seed_name': seedName,
      'stage1_image': stage1Image,
      'stage2_image': stage2Image,
      'stage3_image': stage3Image,
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
      plantedAt: map['planted_at'] as String?,
      lastWateredAt: map['last_watered_at'] as String?,
      stage: map['stage'] as int?,
      isDead: map['is_dead'] as bool?,
      witheredAt: map['withered_at'] as String?,
      seedName: map['seed_name'] as String?,
      stage1Image: map['stage1_image'] as String?,
      stage2Image: map['stage2_image'] as String?,
      stage3Image: map['stage3_image'] as String?,
      growDuration: map['grow_duration'] as int?,
      waterInterval: map['water_interval'] as int?,
      userId: map['user_id'] as String?,
      x: map['x'] as int?,
      y: map['y'] as int?,
    );
  }

  String? getSeedImage() {
    switch (stage) {
      case 1:
        return stage1Image;
      case 2:
        return stage2Image;
      case 3:
        return stage3Image;
      default:
        return stage1Image;
    }
  }
}
