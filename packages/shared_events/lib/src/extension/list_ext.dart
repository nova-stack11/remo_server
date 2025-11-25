extension MapListParser on Map<String, dynamic> {
  List<T>? parseList<T>(String key, T Function(Map<String, dynamic>) fromMap) {
    final raw = this[key];
    if (raw is! List) return null;

    return raw.map((e) => fromMap(e as Map<String, dynamic>)).toList();
  }
}