import 'package:ehealth/core/router/route_names.dart';
import 'package:ehealth/core/theme/app_colors.dart';
import 'package:ehealth/core/theme/app_spacing.dart';
import 'package:ehealth/core/theme/app_text_styles.dart';
import 'package:ehealth/core/widgets/app_card.dart';
import 'package:ehealth/core/widgets/async_value_widget.dart';
import 'package:ehealth/core/widgets/pill_chip.dart';
import 'package:ehealth/core/widgets/top_toast.dart';
import 'package:ehealth/features/appointments/domain/entities/appointment.dart';
import 'package:ehealth/features/appointments/presentation/providers/appointments_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _Status { ongoing, upcoming, past, unknown }

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String _formatDateTime(DateTime utc) {
  final date = utc.toLocal();
  final day = date.day.toString().padLeft(2, '0');
  final month = _months[date.month - 1];
  final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final hour = hour12.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour < 12 ? 'AM' : 'PM';
  return '$day $month ${date.year} $hour:$minute $period';
}

_Status _statusOf(Appointment appointment) {
  final start = appointment.startTime;
  if (start == null) return _Status.unknown;

  final now = DateTime.now();
  final end =
      appointment.endTime ??
      start.add(
        Duration(minutes: (appointment.service.durationHours * 60).round()),
      );

  if (now.isBefore(start)) return _Status.upcoming;
  if (now.isBefore(end)) return _Status.ongoing;
  return _Status.past;
}

bool _canJoinCall(Appointment appointment) {
  final start = appointment.startTime;
  if (start == null) return true;

  final now = DateTime.now();
  final end =
      appointment.endTime ??
      start.add(
        Duration(minutes: (appointment.service.durationHours * 60).round()),
      );
  final joinWindowStart = start.subtract(const Duration(minutes: 5));

  return !now.isBefore(joinWindowStart) && now.isBefore(end);
}

int _statusRank(_Status status) => switch (status) {
  _Status.ongoing => 0,
  _Status.upcoming => 1,
  _Status.past => 2,
  _Status.unknown => 3,
};

List<Appointment> _sortedByRelevance(List<Appointment> appointments) {
  final sorted = [...appointments];
  sorted.sort((a, b) {
    final statusA = _statusOf(a);
    final statusB = _statusOf(b);
    final rankDiff = _statusRank(statusA).compareTo(_statusRank(statusB));
    if (rankDiff != 0) return rankDiff;

    final startA = a.startTime;
    final startB = b.startTime;
    if (startA == null || startB == null) return 0;
    return statusA == _Status.past
        ? startB.compareTo(startA)
        : startA.compareTo(startB);
  });
  return sorted;
}

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
          final sorted = _sortedByRelevance(appointments);
          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.marginMobile,
              vertical: AppSpacing.sm,
            ),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _AppointmentCard(appointment: sorted[index]),
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
    final status = _statusOf(appointment);
    final isOngoing = status == _Status.ongoing;
    final canJoin = _canJoinCall(appointment);

    return AppCard(
      color: isOngoing ? AppColors.triageLow.withValues(alpha: 0.08) : null,
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
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.electricBlue,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctor.doctorName,
                      style: AppTextStyles.headlineMd,
                    ),
                    if (appointment.doctor.specialization != null)
                      Text(
                        appointment.doctor.specialization!,
                        style: AppTextStyles.bodySm,
                      ),
                  ],
                ),
              ),
              if (isOngoing)
                const PillChip(
                  label: 'Ongoing',
                  color: AppColors.triageLow,
                  icon: Icons.circle,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(height: 1, color: AppColors.surfaceVariant),
          const SizedBox(height: AppSpacing.xs),
          Text(appointment.service.serviceName, style: AppTextStyles.bodySm),
          if (appointment.startTime != null) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(appointment.startTime!),
                  style: AppTextStyles.bodySm,
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: canJoin
                        ? AppColors.electricBlue
                        : AppColors.outlineVariant,
                    foregroundColor: canJoin
                        ? AppColors.onPrimary
                        : AppColors.onSurfaceVariant,
                    textStyle: AppTextStyles.button,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusButton,
                      ),
                    ),
                  ),
                  onPressed: () {
                    if (canJoin) {
                      context.pushNamed(
                        RouteNames.videoCall,
                        pathParameters: {'consultationId': consultationId},
                      );
                    } else {
                      showTopToast(
                        context,
                        'You can join 5 minutes before the appointment starts.',
                        icon: Icons.access_time,
                      );
                    }
                  },
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
                  PopupMenuItem(
                    value: 'prescriptions',
                    child: Text('View Prescriptions'),
                  ),
                ],
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusButton,
                    ),
                    border: Border.all(
                      color: AppColors.outlineVariant,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.more_vert,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _initialsOf(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words.first.substring(0, 1) + words.last.substring(0, 1))
        .toUpperCase();
  }
}
