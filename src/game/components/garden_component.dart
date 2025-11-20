import 'package:bonfire_server/bonfire_server.dart';
import 'package:shared_events/shared_events.dart';

class GardenComponent extends PositionedGameComponent {
  GardenComponent({
    required super.position,
    required super.size,
    required this.seedId,
    this.stage = 0,
    this.wateredAt,
    this.plantedAt,
  });

  final String seedId;
  int stage;
  DateTime? plantedAt;
  DateTime? wateredAt;

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'garden',
      'seedId': seedId,
      'stage': stage,
      'position': position.toMap(),
      'size': size.toMap(),
      'plantedAt': plantedAt?.toIso8601String(),
      'wateredAt': wateredAt?.toIso8601String(),
    };
  }

  factory GardenComponent.fromMap(Map<String, dynamic> map) {
    return GardenComponent(
      seedId: map['seedId'] as String? ?? '',
      stage: map['stage'] as int? ?? 0,
      plantedAt: (map['plantedAt'] != null)
          ? DateTime.parse(map['plantedAt'] as String? ?? '')
          : null,
      wateredAt: (map['wateredAt'] != null)
          ? DateTime.parse(map['wateredAt'] as String? ?? '')
          : null,
      position: GameVector.fromMap(map['position'] as Map<String, dynamic>? ?? {}),
      size: GameVector.fromMap(map['size']as Map<String, dynamic>? ?? {}),
    );
  }
}