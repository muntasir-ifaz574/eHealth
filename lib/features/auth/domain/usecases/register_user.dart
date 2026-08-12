import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/auth/domain/entities/user.dart';
import 'package:ehealth/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

class RegisterUserParams extends Equatable {
  const RegisterUserParams({
    required this.userName,
    required this.userEmail,
    required this.userPassword,
  });

  final String userName;
  final String userEmail;
  final String userPassword;

  @override
  List<Object?> get props => [userName, userEmail, userPassword];
}

class RegisterUser implements UseCase<User, RegisterUserParams> {
  const RegisterUser(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<User>> call(RegisterUserParams params) {
    return _repository.register(
      userName: params.userName,
      userEmail: params.userEmail,
      userPassword: params.userPassword,
    );
  }
}
