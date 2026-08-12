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
    // The backend has been observed returning appId/serverSecret with
    // stray trailing whitespace, which is invalid for ZEGO's auth and
    // leaves the native engine uninitialized (every call then fails with
    // "on a null object reference") — trim defensively.
    return ConferenceCredentialsModel(
      appId: int.parse(json['appId'].toString().trim()),
      serverSecret: (json['serverSecret'] as String).trim(),
      consultationId: json['consultationId'].toString().trim(),
      userId: json['userId'] as int,
      userName: (json['userName'] as String).trim(),
    );
  }
}
