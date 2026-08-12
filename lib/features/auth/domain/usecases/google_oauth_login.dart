import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/auth/domain/entities/user.dart';
import 'package:ehealth/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

class GoogleOAuthLoginParams extends Equatable {
  const GoogleOAuthLoginParams(this.idToken);

  final String idToken;

  @override
  List<Object?> get props => [idToken];
}

class GoogleOAuthLogin implements UseCase<User, GoogleOAuthLoginParams> {
  const GoogleOAuthLogin(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<User>> call(GoogleOAuthLoginParams params) {
    return _repository.googleOAuth(params.idToken);
  }
}
