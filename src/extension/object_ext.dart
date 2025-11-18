
/// ===============================================
/// Extensions để sanitize DateTime trong Map và List
/// ===============================================

extension MapSanitized on Map<String, dynamic> {
  Map<String, dynamic> sanitized() {
    final result = <String, dynamic>{};
    forEach((key, value) {
      if (value is DateTime) {
        result[key] = value.toIso8601String();
      } else if (value is Map<String, dynamic>) {
        result[key] = value.sanitized();
      } else if (value is List) {
        result[key] = value.sanitizedList();
      } else {
        result[key] = value;
      }
    });
    return result;
  }
}

extension ListSanitized on List {
  List sanitizedList() {
    return map((value) {
      if (value is DateTime) {
        return value.toIso8601String();
      } else if (value is Map<String, dynamic>) {
        return value.sanitized();
      } else if (value is List) {
        return value.sanitizedList();
      } else {
        return value;
      }
    }).toList();
  }
}