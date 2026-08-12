import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/auth/domain/entities/user.dart';
import 'package:ehealth/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

class LoginUserParams extends Equatable {
  const LoginUserParams({required this.userEmail, required this.userPassword});

  final String userEmail;
  final String userPassword;

  @override
  List<Object?> get props => [userEmail, userPassword];
}

class LoginUser implements UseCase<User, LoginUserParams> {
  const LoginUser(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<User>> call(LoginUserParams params) {
    return _repository.login(userEmail: params.userEmail, userPassword: params.userPassword);
  }
}
