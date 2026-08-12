import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:ehealth/core/network/auth_interceptor.dart';
import 'package:ehealth/core/network/dio_client.dart';
import 'package:ehealth/core/network/network_info.dart';
import 'package:ehealth/core/permissions/permission_service.dart';
import 'package:ehealth/core/storage/token_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Overridden in `main()` once `SharedPreferences.getInstance()` resolves.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});

final tokenStorageProvider = Provider<TokenStorage>((ref) => const TokenStorage());

final dioProvider = Provider<Dio>((ref) {
  return DioClient(
    enableLogging: true,
    extraInterceptors: [AuthInterceptor(ref.watch(tokenStorageProvider))],
  ).dio;
});

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.watch(connectivityProvider));
});

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return const PermissionService();
});
