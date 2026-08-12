import 'package:ehealth/features/video_call/domain/entities/doctor.dart';
import 'package:flutter/material.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard({super.key, required this.doctor, required this.onBook});

  final Doctor doctor;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(doctor.doctorName),
        subtitle: Text(doctor.specialization ?? 'General Physician'),
        trailing: FilledButton.icon(
          onPressed: doctor.isBookable ? onBook : null,
          icon: const Icon(Icons.event_available),
          label: Text(doctor.isBookable ? 'Book' : 'Unavailable'),
        ),
      ),
    );
  }
}
