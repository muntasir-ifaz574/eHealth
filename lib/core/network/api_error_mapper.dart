import 'package:dio/dio.dart';
import 'package:ehealth/core/error/failures.dart';

Failure mapDioException(DioException e) {
  final statusCode = e.response?.statusCode;
  final body = e.response?.data;
  final serverMessage = body is Map ? _messageOf(body['message']) : null;

  switch (statusCode) {
    case 401:
      return UnauthorizedFailure(
        serverMessage ?? 'Your session has expired. Please log in again.',
      );
    case 400:
    case 422:
      return ValidationFailure(
        serverMessage ?? 'Some information you entered is invalid.',
      );
    default:
      return ServerFailure(
        serverMessage ?? e.message ?? 'Something went wrong on the server.',
      );
  }
}

String? _messageOf(dynamic message) {
  if (message is String) return message;
  if (message is List) return message.whereType<String>().join(', ');
  return null;
}
