// ignore_for_file: public_member_api_docs, sort_constructors_first

class CommonIdEvent {
  CommonIdEvent({required this.id, required this.mapId });

  final String id;
  final String mapId;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'mapId': mapId,
    };
  }

  factory CommonIdEvent.fromMap(Map<String, dynamic> map) {
    return CommonIdEvent(
      id: map['id'] ?? '',
      mapId: map['mapId'] ?? '',
    );
  }
}
