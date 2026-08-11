abstract final class ApiConstants {
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const String placesNearbySearchUrl =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
  static const String placeDetailsUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';

  static const String hospitalKeyword = 'hospital';
  static const int defaultSearchRadiusMeters = 5000;
}

abstract final class AppConstants {
  static const String appName = 'eHealth';
  static const String emergencyServiceNumber = '999';
}
