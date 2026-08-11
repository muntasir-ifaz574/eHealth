import 'package:ehealth/core/router/route_names.dart';
import 'package:ehealth/core/widgets/async_value_widget.dart';
import 'package:ehealth/features/hospital/domain/entities/hospital.dart';
import 'package:ehealth/features/hospital/presentation/providers/hospital_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HospitalMapScreen extends ConsumerWidget {
  const HospitalMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionAsync = ref.watch(currentPositionProvider);
    final hospitalsAsync = ref.watch(nearbyHospitalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Hospitals Map')),
      body: AsyncValueWidget(
        value: positionAsync,
        data: (position) {
          final userLatLng = LatLng(position.latitude, position.longitude);
          return AsyncValueWidget<List<Hospital>>(
            value: hospitalsAsync,
            data: (hospitals) {
              final markers = <Marker>{
                Marker(
                  markerId: const MarkerId('me'),
                  position: userLatLng,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                  infoWindow: const InfoWindow(title: 'You are here'),
                ),
                for (final hospital in hospitals)
                  Marker(
                    markerId: MarkerId(hospital.placeId),
                    position: LatLng(hospital.latitude, hospital.longitude),
                    infoWindow: InfoWindow(
                      title: hospital.name,
                      snippet: hospital.address,
                      onTap: () => context.pushNamed(
                        RouteNames.hospitalDetail,
                        pathParameters: {'placeId': hospital.placeId},
                      ),
                    ),
                  ),
              };

              return GoogleMap(
                initialCameraPosition: CameraPosition(target: userLatLng, zoom: 14),
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              );
            },
          );
        },
      ),
    );
  }
}
