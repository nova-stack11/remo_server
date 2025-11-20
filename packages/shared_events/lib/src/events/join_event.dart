// ignore_for_file: public_member_api_docs, sort_constructors_first

class JoinEvent {
  JoinEvent(
      {required this.userId, required this.name, required this.skin, required this.map });

  final String userId;
  final String name;
  final String skin;
  final String map;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'name': name,
      'skin': skin,
      'map': map,
    };
  }

  factory JoinEvent.fromMap(Map<String, dynamic> map) {
    return JoinEvent(
      userId: map['userId'] as String,
      name: map['name'] as String,
      skin: map['skin'] as String,
      map: map['map'] as String,
    );
  }
}
