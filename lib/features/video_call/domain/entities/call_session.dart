import 'package:equatable/equatable.dart';

/// Everything the ZEGOCLOUD call widget needs to join a room: a shared
/// [callId] (the "room ID") plus the identity of the current user.
class CallSession extends Equatable {
  const CallSession({
    required this.callId,
    required this.doctorId,
    required this.doctorName,
    required this.callerUserId,
    required this.callerUserName,
  });

  final String callId;
  final String doctorId;
  final String doctorName;
  final String callerUserId;
  final String callerUserName;

  @override
  List<Object?> get props => [callId, doctorId, doctorName, callerUserId, callerUserName];
}
