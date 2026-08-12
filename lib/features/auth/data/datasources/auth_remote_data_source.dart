import 'package:dio/dio.dart';
import 'package:ehealth/core/constants/api_endpoints.dart';
import 'package:ehealth/features/auth/data/models/user_model.dart';

typedef AuthSession = ({UserModel user, String accessToken});

abstract interface class AuthRemoteDataSource {
  Future<UserModel> register({
    required String userName,
    required String userEmail,
    required String userPassword,
  });

  Future<AuthSession> login({required String userEmail, required String userPassword});

  Future<AuthSession> googleOAuth(String idToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<UserModel> register({
    required String userName,
    required String userEmail,
    required String userPassword,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.registration,
      data: {'userName': userName, 'userEmail': userEmail, 'userPassword': userPassword},
    );
    return UserModel.fromJson(response.data!);
  }

  @override
  Future<AuthSession> login({required String userEmail, required String userPassword}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {'userEmail': userEmail, 'userPassword': userPassword},
    );
    return _parseSession(response.data!);
  }

  @override
  Future<AuthSession> googleOAuth(String idToken) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.googleOAuth,
      data: {'idToken': idToken},
    );
    return _parseSession(response.data!);
  }

  AuthSession _parseSession(Map<String, dynamic> json) {
    return (
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
    );
  }
}
