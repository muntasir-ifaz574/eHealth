import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/features/video_call/domain/entities/conference_credentials.dart';
import 'package:ehealth/features/video_call/domain/entities/doctor.dart';

abstract interface class VideoCallRepository {
  Future<Result<List<Doctor>>> getAvailableDoctors();

  Future<Result<Doctor>> getDoctorById(int doctorId);

  /// Fetches the Zego conference credentials for a specific booked
  /// consultation from the backend (`GET users/consultations/:id/conference`).
  Future<Result<ConferenceCredentials>> getConferenceCredentials(String consultationId);
}
