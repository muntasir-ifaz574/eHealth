import 'package:equatable/equatable.dart';

class Doctor extends Equatable {
  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    this.isOnline = false,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String specialty;
  final bool isOnline;
  final String? avatarUrl;

  @override
  List<Object?> get props => [id, name, specialty, isOnline, avatarUrl];
}
