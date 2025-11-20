// ignore_for_file: public_member_api_docs, sort_constructors_first

class ChangeMapEvent {
  final String mapId;

  ChangeMapEvent({required this.mapId});

  Map<String, dynamic> toMap() {
    return {
      'mapId': mapId,
    };
  }

  factory ChangeMapEvent.fromMap(Map<String, dynamic> map) {
    return ChangeMapEvent(
      mapId: map['mapId'] as String,
    );
  }
}
