import 'package:shared_events/shared_events.dart';

class GardenEventRequest {
  GardenEventRequest({
    required this.type,
    required this.mapId,
    required this.data,
    this.ownerId,
  });

  final String type;
  final String mapId;
  final String? ownerId;
  final Map<String, dynamic>? data;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type,
      'map_id': mapId,
      'owner_id': ownerId,
      'data': data,
    };
  }

  factory GardenEventRequest.fromMap(Map<String, dynamic> map) {
    return GardenEventRequest(
      type: map['type'] ?? '',
      mapId: map['map_id'] ?? '',
      ownerId: map['owner_id'] ?? '',
      data: map['data'],
    );
  }

  GardenEventType toType() {
    return GardenEventTypeExt.fromString(type);
  }

  bool validated() {
    return type.isNotEmpty &&
        mapId.isNotEmpty;
  }
}
