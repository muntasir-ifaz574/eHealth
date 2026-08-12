import 'package:dio/dio.dart';
import 'package:ehealth/core/config/env.dart';
import 'package:ehealth/core/constants/api_constants.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Thin wrapper around a configured [Dio] instance shared by every remote
/// data source in the app. `baseUrl` only applies to relative paths — the
/// hospital feature's absolute Google Places URLs are unaffected.
class DioClient {
  DioClient({Dio? dio, bool enableLogging = false, List<Interceptor> extraInterceptors = const []})
      : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: Env.apiBaseUrl,
                connectTimeout: ApiConstants.connectTimeout,
                receiveTimeout: ApiConstants.receiveTimeout,
              ),
            ) {
    this.dio.interceptors.addAll(extraInterceptors);
    if (enableLogging) {
      this.dio.interceptors.add(
            PrettyDioLogger(
              requestHeader: false,
              requestBody: true,
              responseBody: true,
              compact: true,
            ),
          );
    }
  }

  final Dio dio;
}
