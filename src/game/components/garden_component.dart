import 'package:bonfire_server/bonfire_server.dart';
import 'package:shared_events/shared_events.dart';

class GardenComponent extends PositionedGameComponent {
  GardenComponent({
    required super.position,
    required super.size,
    required this.seedId,
    this.stage = 0,
  });

  final String seedId;
  int stage;

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'garden',
      'position': position.toMap(),
      'size': size.toMap(),
      'seedId': seedId,
      'stage': stage,
    };
  }

  factory GardenComponent.fromMap(Map<String, dynamic> map) {
    return GardenComponent(
      seedId: map['seedId'] as String? ?? '',
      stage: map['stage'] as int? ?? 0,
      position: GameVector.fromMap(map['position'] as Map<String, dynamic>),
      size: GameVector.fromMap(map['size'] as Map<String, dynamic>),
    );
  }
}
