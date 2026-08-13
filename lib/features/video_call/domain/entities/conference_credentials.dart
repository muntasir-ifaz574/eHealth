import 'package:equatable/equatable.dart';

class ConferenceCredentials extends Equatable {
  const ConferenceCredentials({
    required this.appId,
    required this.serverSecret,
    required this.consultationId,
    required this.userId,
    required this.userName,
  });

  final int appId;
  final String serverSecret;
  final String consultationId;
  final int userId;
  final String userName;

  @override
  List<Object?> get props => [
    appId,
    serverSecret,
    consultationId,
    userId,
    userName,
  ];
}
