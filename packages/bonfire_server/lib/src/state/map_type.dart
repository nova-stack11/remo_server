enum MapType {
  user,
  city;

  static MapType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'user':
        return MapType.user;
      case 'city':
        return MapType.city;
      default:
        throw Exception('Invalid MapType: $value');
    }
  }

  String toValue() {
    switch (this) {
      case MapType.user:
        return 'user';
      case MapType.city:
        return 'city';
    }
  }
}