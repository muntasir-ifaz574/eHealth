import 'package:ehealth/features/video_call/domain/entities/doctor.dart';
import 'package:flutter/material.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard({super.key, required this.doctor, required this.onCall});

  final Doctor doctor;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: doctor.avatarUrl != null ? NetworkImage(doctor.avatarUrl!) : null,
          child: doctor.avatarUrl == null ? const Icon(Icons.person) : null,
        ),
        title: Text(doctor.name),
        subtitle: Text(doctor.specialty),
        trailing: FilledButton.icon(
          onPressed: doctor.isOnline ? onCall : null,
          icon: const Icon(Icons.videocam),
          label: Text(doctor.isOnline ? 'Call' : 'Offline'),
        ),
      ),
    );
  }
}
