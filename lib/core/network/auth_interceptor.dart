import 'package:dio/dio.dart';
import 'package:ehealth/core/storage/token_storage.dart';

/// Attaches the stored bearer token to requests against our own backend
/// (relative paths) and clears it on a 401 so the next auth check reflects
/// the expired session. Absolute URLs (e.g. Google Places) are left alone.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage);

  final TokenStorage _tokenStorage;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!options.path.startsWith('http')) {
      final token = await _tokenStorage.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _tokenStorage.clear();
    }
    handler.next(err);
  }
}
