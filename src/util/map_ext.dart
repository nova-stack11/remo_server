extension MapGetOrNullExt on Map<String, dynamic> {
  T? getOrNull<T>(String key) {
    final value = this[key];
    if (value is T) return value;
    return null;
  }
}