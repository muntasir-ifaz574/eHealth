import 'package:ehealth/core/router/route_names.dart';
import 'package:ehealth/core/widgets/async_value_widget.dart';
import 'package:ehealth/features/appointments/presentation/providers/appointments_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MyAppointmentsScreen extends ConsumerWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(myAppointmentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      body: AsyncValueWidget(
        value: appointmentsAsync,
        onRetry: () => ref.invalidate(myAppointmentsProvider),
        data: (appointments) {
          if (appointments.isEmpty) {
            return const Center(child: Text('No appointments booked yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  title: Text(appointment.doctor.doctorName),
                  subtitle: Text(appointment.service.serviceName),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      final consultationId = appointment.consultationId.toString();
                      if (value == 'call') {
                        context.pushNamed(
                          RouteNames.videoCall,
                          pathParameters: {'consultationId': consultationId},
                        );
                      } else if (value == 'prescriptions') {
                        context.pushNamed(
                          RouteNames.prescriptionList,
                          pathParameters: {'consultationId': consultationId},
                        );
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'call', child: Text('Join Call')),
                      PopupMenuItem(value: 'prescriptions', child: Text('View Prescriptions')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
