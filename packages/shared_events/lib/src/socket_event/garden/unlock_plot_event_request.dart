
class UnlockPlotDataRequest {
  UnlockPlotDataRequest({required this.id});

  final String id;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
    };
  }

  factory UnlockPlotDataRequest.fromMap(Map<String, dynamic> map) {
    return UnlockPlotDataRequest(
      id: map['id'] ?? '',
    );
  }
}
