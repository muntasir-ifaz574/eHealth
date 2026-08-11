import 'package:ehealth/core/result/result.dart';
import 'package:ehealth/core/usecase/usecase.dart';
import 'package:ehealth/features/video_call/domain/entities/call_session.dart';
import 'package:ehealth/features/video_call/domain/entities/doctor.dart';
import 'package:ehealth/features/video_call/domain/repositories/video_call_repository.dart';
import 'package:equatable/equatable.dart';

class CreateCallSessionParams extends Equatable {
  const CreateCallSessionParams({
    required this.doctor,
    required this.callerUserId,
    required this.callerUserName,
  });

  final Doctor doctor;
  final String callerUserId;
  final String callerUserName;

  @override
  List<Object?> get props => [doctor, callerUserId, callerUserName];
}

class CreateCallSession implements UseCase<CallSession, CreateCallSessionParams> {
  const CreateCallSession(this._repository);

  final VideoCallRepository _repository;

  @override
  Future<Result<CallSession>> call(CreateCallSessionParams params) {
    return _repository.createCallSession(
      doctor: params.doctor,
      callerUserId: params.callerUserId,
      callerUserName: params.callerUserName,
    );
  }
}
