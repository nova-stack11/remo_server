/// ===============================================
/// Extensions để sanitize DateTime trong Map và List
/// ===============================================

extension MapSanitized on Map<String, dynamic> {
  Map<String, dynamic> sanitizeObj() {
    final result = <String, dynamic>{};
    forEach((key, value) {
      if (value is DateTime) {
        result[key] = value.toIso8601String();
      } else if (value is Map<String, dynamic>) {
        result[key] = value.sanitizeObj();
      } else if (value is List) {
        result[key] = value.sanitizeObjList();
      } else {
        result[key] = value;
      }
    });
    return result;
  }
}

extension ListSanitized on List {
  List sanitizeObjList() {
    return map((value) {
      if (value is DateTime) {
        return value.toIso8601String();
      } else if (value is Map<String, dynamic>) {
        return value.sanitizeObj();
      } else if (value is List) {
        return value.sanitizeObjList();
      } else {
        return value;
      }
    }).toList();
  }
}

extension MapSanitizeDateTimeExt on Map<String, dynamic> {
  Map<String, dynamic> sanitizeMap() {
    final result = <String, dynamic>{};

    forEach((key, value) {
      if (value is DateTime) {
        result[key] = value.toIso8601String();
      } else if (value is Map<String, dynamic>) {
        result[key] = value.sanitizeMap();
      } else if (value is List<Map<String, dynamic>>) {
        result[key] = value.sanitizeMapList();
      } else {
        result[key] = value;
      }
    });

    return result;
  }
}

extension ListSanitizeDateTimeExt on List<Map<String, dynamic>> {
  List<Map<String, dynamic>> sanitizeMapList() {
    return map((value) {
      return value.sanitizeMap();
    }).toList();
  }
}