class ServerException implements Exception {
  const ServerException([this.message = 'Something went wrong on the server.']);

  final String message;
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'No internet connection.']);

  final String message;
}

class LocationException implements Exception {
  const LocationException([this.message = 'Unable to determine your location.']);

  final String message;
}

class PermissionException implements Exception {
  const PermissionException([this.message = 'Required permission was denied.']);

  final String message;
}

class CacheException implements Exception {
  const CacheException([this.message = 'No cached data available.']);

  final String message;
}

class UnauthorizedException implements Exception {
  const UnauthorizedException([this.message = 'Your session has expired. Please log in again.']);

  final String message;
}

class ValidationException implements Exception {
  const ValidationException([this.message = 'Some information you entered is invalid.']);

  final String message;
}
