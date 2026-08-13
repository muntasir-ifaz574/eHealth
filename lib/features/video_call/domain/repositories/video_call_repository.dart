import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/features/video_call/domain/entities/conference_credentials.dart';
import 'package:ehealth/features/video_call/domain/entities/doctor.dart';

abstract interface class VideoCallRepository {
  Future<Result<List<Doctor>>> getAvailableDoctors();

  Future<Result<Doctor>> getDoctorById(int doctorId);

  Future<Result<ConferenceCredentials>> getConferenceCredentials(
    String consultationId,
  );
}
