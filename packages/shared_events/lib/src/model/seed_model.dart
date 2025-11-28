class SeedModel {
  final String? id;
  final String? name;
  final int? growDuration;      // grow_duration
  final int? waterInterval;     // water_interval
  final int? stages;
  final int? reward;
  final int? quantity;
  final String? seedImage;
  final String? stage1Image;
  final String? stage2Image;
  final String? stage3Image;
  final String? description;

  SeedModel({
    required this.id,
    required this.name,
    required this.growDuration,
    required this.waterInterval,
    required this.stages,
    required this.reward,
    required this.quantity,
    required this.seedImage,
    required this.stage1Image,
    required this.stage2Image,
    required this.stage3Image,
    required this.description,
  });

  factory SeedModel.fromMap(Map<String, dynamic> map) {
    return SeedModel(
      id: map['id'].toString(),
      name: map['name'].toString(),
      growDuration: map['grow_duration'] as int?,
      waterInterval: map['water_interval'] as int?,
      stages: map['stages'] as int?,
      reward: map['reward'] as int?,
      quantity: map['quantity'] as int?,
      seedImage: map['seed_image']?.toString() ?? '',
      stage1Image: map['stage1_image']?.toString() ?? '',
      stage2Image: map['stage2_image']?.toString() ?? '',
      stage3Image: map['stage3_image']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'grow_duration': growDuration,
      'water_interval': waterInterval,
      'stages': stages,
      'reward': reward,
      'quantity': quantity,
      'seed_image': seedImage,
      'stage1_image': stage1Image,
      'stage2_image': stage2Image,
      'stage3_image': stage3Image,
      'description': description,
    };
  }

  /// tiện ích lấy ảnh theo stage
  String? getStageImage(int stageIndex) {
    switch (stageIndex) {
      case 1:
        return stage1Image;
      case 2:
        return stage2Image;
      case 3:
        return stage3Image;
      default:
        return seedImage;
    }
  }
}