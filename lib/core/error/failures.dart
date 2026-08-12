import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on the server.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class LocationFailure extends Failure {
  const LocationFailure([super.message = 'Unable to determine your location.']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Required permission was denied.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'No cached data available.']);
}

class VoiceFailure extends Failure {
  const VoiceFailure([super.message = 'Voice assistant is unavailable.']);
}

class CallFailure extends Failure {
  const CallFailure([super.message = 'Unable to start the video call.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Your session has expired. Please log in again.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Some information you entered is invalid.']);
}
