import 'package:dio/dio.dart';
import 'package:ehealth/core/constants/api_constants.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Thin wrapper around a configured [Dio] instance shared by every remote
/// data source in the app.
class DioClient {
  DioClient({Dio? dio, bool enableLogging = false})
      : dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: ApiConstants.connectTimeout,
                receiveTimeout: ApiConstants.receiveTimeout,
              ),
            ) {
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
