extension NumOrZero on num? {
  num orZero() => this ?? 0;
}

extension IntOrZero on int? {
  int orZero() => this ?? 0;
}

extension DoubleOrZero on double? {
  double? orZero() => this ?? 0.0;
}