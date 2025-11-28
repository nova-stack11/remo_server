
import 'package:shared_events/src/socket_event/garden/garden_event_type.dart';

class GardenEvent {
  GardenEvent({required this.type, required this.data});

  final String type;
  final Map<String, dynamic> data;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type,
      'data': data,
    };
  }

  factory GardenEvent.fromMap(Map<String, dynamic> map) {
    return GardenEvent(
      type: map['type'] ?? '',
      data: map['data'] ?? '',
    );
  }

  GardenEventType toType() {
    return GardenEventTypeExt.fromString(type);
  }
}
