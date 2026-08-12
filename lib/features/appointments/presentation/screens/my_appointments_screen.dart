import 'package:ehealth/core/router/route_names.dart';
import 'package:ehealth/core/theme/app_colors.dart';
import 'package:ehealth/core/theme/app_spacing.dart';
import 'package:ehealth/core/theme/app_text_styles.dart';
import 'package:ehealth/core/widgets/app_card.dart';
import 'package:ehealth/core/widgets/async_value_widget.dart';
import 'package:ehealth/features/appointments/domain/entities/appointment.dart';
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_busy, size: 40, color: AppColors.outline),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'No appointments booked yet.',
                      style: AppTextStyles.bodyMd,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.marginMobile,
              vertical: AppSpacing.sm,
            ),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _AppointmentCard(appointment: appointment),
              );
            },
          );
        },
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final consultationId = appointment.consultationId.toString();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initialsOf(appointment.doctor.doctorName),
                  style: AppTextStyles.button.copyWith(color: AppColors.electricBlue),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment.doctor.doctorName, style: AppTextStyles.headlineMd),
                    if (appointment.doctor.specialization != null)
                      Text(
                        appointment.doctor.specialization!,
                        style: AppTextStyles.bodySm,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(height: 1, color: AppColors.surfaceVariant),
          const SizedBox(height: AppSpacing.xs),
          Text(appointment.service.serviceName, style: AppTextStyles.bodySm),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.electricBlue,
                    foregroundColor: AppColors.onPrimary,
                    textStyle: AppTextStyles.button,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                    ),
                  ),
                  onPressed: () => context.pushNamed(
                    RouteNames.videoCall,
                    pathParameters: {'consultationId': consultationId},
                  ),
                  icon: const Icon(Icons.videocam),
                  label: const Text('Join Call'),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'prescriptions') {
                    context.pushNamed(
                      RouteNames.prescriptionList,
                      pathParameters: {'consultationId': consultationId},
                    );
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'prescriptions', child: Text('View Prescriptions')),
                ],
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                    border: Border.all(color: AppColors.outlineVariant, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.more_vert, color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _initialsOf(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words.first.substring(0, 1) + words.last.substring(0, 1)).toUpperCase();
  }
}
