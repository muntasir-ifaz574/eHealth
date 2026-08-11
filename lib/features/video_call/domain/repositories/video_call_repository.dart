import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/features/video_call/domain/entities/call_session.dart';
import 'package:ehealth/features/video_call/domain/entities/doctor.dart';

abstract interface class VideoCallRepository {
  Future<Result<List<Doctor>>> getAvailableDoctors();

  Future<Result<Doctor>> getDoctorById(String doctorId);

  /// Builds a [CallSession] for `caller` to join `doctor` in a shared room.
  /// A real backend would mint a signed room token here; this scaffold
  /// derives a deterministic room id so both participants land in the same
  /// ZEGOCLOUD room.
  Future<Result<CallSession>> createCallSession({
    required Doctor doctor,
    required String callerUserId,
    required String callerUserName,
  });
}
