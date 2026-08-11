import 'package:ehealth/core/utils/dialer.dart';
import 'package:ehealth/core/widgets/async_value_widget.dart';
import 'package:ehealth/features/hospital/presentation/providers/hospital_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HospitalDetailScreen extends ConsumerWidget {
  const HospitalDetailScreen({super.key, required this.placeId});

  final String placeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(hospitalDetailsProvider(placeId));

    return Scaffold(
      appBar: AppBar(title: const Text('Hospital Details')),
      body: AsyncValueWidget(
        value: detailsAsync,
        onRetry: () => ref.invalidate(hospitalDetailsProvider(placeId)),
        data: (hospital) {
          final position = LatLng(hospital.latitude, hospital.longitude);
          return ListView(
            children: [
              SizedBox(
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(target: position, zoom: 15),
                  markers: {Marker(markerId: MarkerId(hospital.placeId), position: position)},
                  zoomControlsEnabled: false,
                  scrollGesturesEnabled: false,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hospital.name, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18),
                        const SizedBox(width: 4),
                        Expanded(child: Text(hospital.address)),
                      ],
                    ),
                    if (hospital.rating != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 18, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(hospital.rating!.toStringAsFixed(1)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: hospital.phoneNumber == null
                          ? null
                          : () => dialPhoneNumber(hospital.phoneNumber!),
                      icon: const Icon(Icons.call),
                      label: Text(
                        hospital.phoneNumber == null
                            ? 'No contact number available'
                            : 'Call ${hospital.phoneNumber}',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
