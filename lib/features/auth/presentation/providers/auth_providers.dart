import 'package:ehealth/core/di/core_providers.dart';
import 'package:ehealth/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ehealth/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ehealth/features/auth/domain/repositories/auth_repository.dart';
import 'package:ehealth/features/auth/domain/usecases/google_oauth_login.dart';
import 'package:ehealth/features/auth/domain/usecases/login_user.dart';
import 'package:ehealth/features/auth/domain/usecases/register_user.dart';
import 'package:ehealth/features/auth/presentation/providers/auth_controller.dart';
import 'package:ehealth/features/auth/presentation/providers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final registerUserProvider = Provider<RegisterUser>((ref) {
  return RegisterUser(ref.watch(authRepositoryProvider));
});

final loginUserProvider = Provider<LoginUser>((ref) {
  return LoginUser(ref.watch(authRepositoryProvider));
});

final googleOAuthLoginProvider = Provider<GoogleOAuthLogin>((ref) {
  return GoogleOAuthLogin(ref.watch(authRepositoryProvider));
});

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);
