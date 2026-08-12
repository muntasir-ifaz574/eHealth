import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  final int userId;
  final String userName;
  final String userEmail;

  @override
  List<Object?> get props => [userId, userName, userEmail];
}
