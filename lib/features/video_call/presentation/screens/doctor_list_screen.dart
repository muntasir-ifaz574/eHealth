import 'package:ehealth/core/router/route_names.dart';
import 'package:ehealth/core/widgets/app_scaffold.dart';
import 'package:ehealth/core/widgets/async_value_widget.dart';
import 'package:ehealth/features/video_call/presentation/providers/video_call_providers.dart';
import 'package:ehealth/features/video_call/presentation/widgets/doctor_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DoctorListScreen extends ConsumerWidget {
  const DoctorListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(availableDoctorsProvider);

    return AppScaffold(
      currentTab: AppTab.doctors,
      appBar: AppBar(title: const Text('Talk to a Doctor')),
      body: AsyncValueWidget(
        value: doctorsAsync,
        onRetry: () => ref.invalidate(availableDoctorsProvider),
        data: (doctors) {
          if (doctors.isEmpty) {
            return const Center(child: Text('No doctors available right now.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return DoctorCard(
                doctor: doctor,
                onBook: () => context.pushNamed(
                  RouteNames.appointmentBooking,
                  pathParameters: {'doctorId': doctor.doctorId.toString()},
                ),
              );
            },
          );
        },
      ),
    );
  }
}
