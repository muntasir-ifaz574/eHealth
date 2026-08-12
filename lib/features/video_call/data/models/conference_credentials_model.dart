import 'package:ehealth/features/video_call/domain/entities/conference_credentials.dart';

class ConferenceCredentialsModel extends ConferenceCredentials {
  const ConferenceCredentialsModel({
    required super.appId,
    required super.serverSecret,
    required super.consultationId,
    required super.userId,
    required super.userName,
  });

  factory ConferenceCredentialsModel.fromJson(Map<String, dynamic> json) {
    return ConferenceCredentialsModel(
      appId: int.parse(json['appId'].toString()),
      serverSecret: json['serverSecret'] as String,
      consultationId: json['consultationId'].toString(),
      userId: json['userId'] as int,
      userName: json['userName'] as String,
    );
  }
}
