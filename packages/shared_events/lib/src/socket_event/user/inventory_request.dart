// ignore_for_file: public_member_api_docs, sort_constructors_first


class InventoryRequest {
  InventoryRequest({
    required this.userId,
  });

  final String userId;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
    };
  }

  factory InventoryRequest.fromMap(Map<String, dynamic> map) {
    return InventoryRequest(
      userId: map['userId'] as String,
    );
  }
}
