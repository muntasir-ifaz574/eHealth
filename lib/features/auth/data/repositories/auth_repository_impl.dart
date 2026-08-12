import 'package:dartz/dartz.dart';
import 'package:ehealth/core/error/failures.dart';
import 'package:ehealth/core/network/api_error_mapper.dart';
import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:ehealth/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ehealth/features/auth/data/models/user_model.dart';
import 'package:ehealth/features/auth/domain/entities/user.dart';
import 'package:ehealth/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.remoteDataSource, required this.tokenStorage});

  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  @override
  Future<Result<User>> register({
    required String userName,
    required String userEmail,
    required String userPassword,
  }) async {
    try {
      final user = await remoteDataSource.register(
        userName: userName,
        userEmail: userEmail,
        userPassword: userPassword,
      );
      return Right(user);
    } on DioException catch (e) {
      return Left(mapDioException(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Result<User>> login({required String userEmail, required String userPassword}) async {
    try {
      final session = await remoteDataSource.login(userEmail: userEmail, userPassword: userPassword);
      await _persistSession(session);
      return Right(session.user);
    } on DioException catch (e) {
      return Left(mapDioException(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Result<User>> googleOAuth(String idToken) async {
    try {
      final session = await remoteDataSource.googleOAuth(idToken);
      await _persistSession(session);
      return Right(session.user);
    } on DioException catch (e) {
      return Left(mapDioException(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<void> logout() => tokenStorage.clear();

  @override
  Future<User?> restoreSession() async {
    final token = await tokenStorage.getToken();
    final userJson = await tokenStorage.getUser();
    if (token == null || userJson == null) return null;
    return UserModel.fromJson(userJson);
  }

  Future<void> _persistSession(AuthSession session) async {
    await tokenStorage.saveToken(session.accessToken);
    await tokenStorage.saveUser(session.user.toJson());
  }
}
