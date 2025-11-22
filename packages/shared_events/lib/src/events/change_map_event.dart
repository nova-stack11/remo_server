// ignore_for_file: public_member_api_docs, sort_constructors_first

class ChangeMapEvent {
  final String userId;
  final String mapId;

  ChangeMapEvent({required this.userId, required this.mapId});

  Map<String, dynamic> toMap() {
    return <String, dynamic> {
      'userId': userId,
      'mapId': mapId,
    };
  }

  factory ChangeMapEvent.fromMap(Map<String, dynamic> map) {
    return ChangeMapEvent(
      userId: map['userId'] as String,
      mapId: map['mapId'] as String,
    );
  }
}
