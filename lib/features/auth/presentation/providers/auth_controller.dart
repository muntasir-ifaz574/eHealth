import 'package:ehealth/features/auth/presentation/providers/auth_providers.dart';
import 'package:ehealth/features/auth/presentation/providers/auth_state.dart';
import 'package:ehealth/features/auth/domain/usecases/google_oauth_login.dart';
import 'package:ehealth/features/auth/domain/usecases/login_user.dart';
import 'package:ehealth/features/auth/domain/usecases/register_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthController extends Notifier<AuthState> {
  Future<void>? _bootstrapFuture;

  @override
  AuthState build() => const AuthState();
  Future<void> bootstrap() {
    return _bootstrapFuture ??= () async {
      final user = await ref.read(authRepositoryProvider).restoreSession();
      state = AuthState(
        status: user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        user: user,
      );
    }();
  }

  Future<bool> register({
    required String userName,
    required String userEmail,
    required String userPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.authenticating, clearError: true);
    final result = await ref.read(registerUserProvider)(
      RegisterUserParams(
        userName: userName,
        userEmail: userEmail,
        userPassword: userPassword,
      ),
    );
    return result.fold((failure) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
      );
      return false;
    }, (_) => true);
  }

  Future<bool> login({
    required String userEmail,
    required String userPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.authenticating, clearError: true);
    final result = await ref.read(loginUserProvider)(
      LoginUserParams(userEmail: userEmail, userPassword: userPassword),
    );
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.message,
        );
        return false;
      },
      (user) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
        return true;
      },
    );
  }

  Future<bool> googleOAuth(String idToken) async {
    state = state.copyWith(status: AuthStatus.authenticating, clearError: true);
    final result = await ref.read(googleOAuthLoginProvider)(
      GoogleOAuthLoginParams(idToken),
    );
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.message,
        );
        return false;
      },
      (user) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
        return true;
      },
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    _bootstrapFuture = null;
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
