import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/features/auth/domain/entities/user.dart';

abstract interface class AuthRepository {
  Future<Result<User>> register({
    required String userName,
    required String userEmail,
    required String userPassword,
  });

  Future<Result<User>> login({
    required String userEmail,
    required String userPassword,
  });

  Future<Result<User>> googleOAuth(String idToken);

  Future<void> logout();

  /// Reads a previously persisted session (no network call) — used to
  /// bootstrap [AuthController] on app start.
  Future<User?> restoreSession();
}
