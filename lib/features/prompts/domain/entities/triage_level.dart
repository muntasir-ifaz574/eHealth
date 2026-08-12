enum TriageLevel {
  high,
  medium,
  low;

  static TriageLevel? fromJson(String? value) {
    switch (value) {
      case 'HIGH':
        return TriageLevel.high;
      case 'MEDIUM':
        return TriageLevel.medium;
      case 'LOW':
        return TriageLevel.low;
      default:
        return null;
    }
  }
}
