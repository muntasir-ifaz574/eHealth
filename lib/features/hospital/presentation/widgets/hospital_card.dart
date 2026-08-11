import 'package:ehealth/core/utils/dialer.dart';
import 'package:ehealth/features/hospital/domain/entities/hospital.dart';
import 'package:flutter/material.dart';

class HospitalCard extends StatelessWidget {
  const HospitalCard({super.key, required this.hospital, required this.onTap});

  final Hospital hospital;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final distanceKm = hospital.distanceInMeters == null
        ? null
        : (hospital.distanceInMeters! / 1000).toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: const Icon(Icons.local_hospital),
        ),
        title: Text(hospital.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hospital.address, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: [
                if (distanceKm != null) Text('$distanceKm km'),
                if (hospital.rating != null) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  Text(hospital.rating!.toStringAsFixed(1)),
                ],
                if (hospital.isOpenNow != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    hospital.isOpenNow! ? 'Open now' : 'Closed',
                    style: TextStyle(
                      color: hospital.isOpenNow! ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.call),
          tooltip: hospital.phoneNumber == null ? 'Open for contact number' : 'Call hospital',
          onPressed: () {
            if (hospital.phoneNumber != null) {
              dialPhoneNumber(hospital.phoneNumber!);
            } else {
              onTap();
            }
          },
        ),
      ),
    );
  }
}
