import 'package:ehealth/core/constants/api_constants.dart';
import 'package:ehealth/core/router/route_names.dart';
import 'package:ehealth/core/utils/dialer.dart';
import 'package:ehealth/core/widgets/app_scaffold.dart';
import 'package:ehealth/core/widgets/async_value_widget.dart';
import 'package:ehealth/features/hospital/presentation/providers/hospital_providers.dart';
import 'package:ehealth/features/hospital/presentation/widgets/hospital_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HospitalListScreen extends ConsumerWidget {
  const HospitalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hospitalsAsync = ref.watch(nearbyHospitalsProvider);

    return AppScaffold(
      currentTab: AppTab.hospitals,
      appBar: AppBar(
        title: const Text('Nearby Hospitals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'Map view',
            onPressed: () => context.pushNamed(RouteNames.hospitalMap),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(nearbyHospitalsProvider),
        child: AsyncValueWidget(
          value: hospitalsAsync,
          onRetry: () => ref.invalidate(nearbyHospitalsProvider),
          data: (hospitals) {
            if (hospitals.isEmpty) {
              return const Center(child: Text('No hospitals found nearby.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: hospitals.length,
              itemBuilder: (context, index) {
                final hospital = hospitals[index];
                return HospitalCard(
                  hospital: hospital,
                  onTap: () => context.pushNamed(
                    RouteNames.hospitalDetail,
                    pathParameters: {'placeId': hospital.placeId},
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => dialPhoneNumber(AppConstants.emergencyServiceNumber),
        backgroundColor: Colors.red,
        icon: const Icon(Icons.emergency, color: Colors.white),
        label: const Text('Emergency', style: TextStyle(color: Colors.white)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
