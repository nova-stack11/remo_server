// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:shared_events/shared_events.dart';

class MyChangeMapEvent {
  final String userId;
  final String mapId;

  MyChangeMapEvent({required this.userId, required this.mapId});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'mapId': mapId,
    };
  }

  factory MyChangeMapEvent.fromMap(Map<String, dynamic> map) {
    return MyChangeMapEvent(
      userId: map['userId'] as String,
      mapId: map['mapId'] as String,
    );
  }
}
