import 'package:ehealth/core/router/route_names.dart';
import 'package:ehealth/core/theme/app_colors.dart';
import 'package:ehealth/core/theme/app_spacing.dart';
import 'package:ehealth/core/theme/app_text_styles.dart';
import 'package:ehealth/core/widgets/app_card.dart';
import 'package:ehealth/core/widgets/async_value_widget.dart';
import 'package:ehealth/features/appointments/domain/usecases/book_appointment.dart';
import 'package:ehealth/features/appointments/presentation/providers/appointments_providers.dart';
import 'package:ehealth/features/auth/presentation/providers/auth_providers.dart';
import 'package:ehealth/features/video_call/domain/entities/doctor.dart';
import 'package:ehealth/features/video_call/domain/entities/service.dart';
import 'package:ehealth/features/video_call/presentation/providers/video_call_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _weekdayAbbrev = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _monthAbbrev = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

// No real availability endpoint exists yet, so these are just hardcoded
// candidate slots the user picks from.
const _morningSlots = [
  TimeOfDay(hour: 9, minute: 0),
  TimeOfDay(hour: 10, minute: 30),
  TimeOfDay(hour: 11, minute: 15),
];
const _afternoonSlots = [
  TimeOfDay(hour: 13, minute: 0),
  TimeOfDay(hour: 14, minute: 45),
  TimeOfDay(hour: 16, minute: 0),
];

String _formatTime(TimeOfDay time) {
  final hour12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour12:$minute $period';
}

String _formatDateTime(DateTime dateTime) {
  final month = _monthAbbrev[dateTime.month - 1];
  final time = _formatTime(TimeOfDay.fromDateTime(dateTime));
  return '$month ${dateTime.day}, $time';
}

class AppointmentBookingScreen extends ConsumerStatefulWidget {
  const AppointmentBookingScreen({super.key, required this.doctorId});

  final int doctorId;

  @override
  ConsumerState<AppointmentBookingScreen> createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends ConsumerState<AppointmentBookingScreen> {
  late final List<DateTime> _days = List.generate(
    7,
    (i) => DateTime.now().add(Duration(days: i)),
  );

  Service? _selectedService;
  late DateTime _selectedDay = _days.first;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;

  DateTime? get _startTime {
    final time = _selectedTime;
    if (time == null) return null;
    return DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, time.hour, time.minute);
  }

  Future<void> _confirmBooking() async {
    final service = _selectedService;
    final startTime = _startTime;
    if (service == null || startTime == null) return;

    setState(() => _isSubmitting = true);
    final result = await ref.read(bookAppointmentProvider).call(
          BookAppointmentParams(
            doctorId: widget.doctorId,
            serviceId: service.serviceId,
            startTime: startTime,
          ),
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
      (confirmation) {
        final userId = ref.read(authControllerProvider).user?.userId;
        context.pushNamed(
          RouteNames.paymentReview,
          pathParameters: {'consultationId': confirmation.consultationId.toString()},
          extra: {'amount': service.totalCost, 'userId': userId},
        );
      },
    );
  }

  String _initialsOf(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    return words.map((w) => w[0]).take(2).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final doctorAsync = ref.watch(doctorByIdProvider(widget.doctorId));

    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: AsyncValueWidget(
        value: doctorAsync,
        onRetry: () => ref.invalidate(doctorByIdProvider(widget.doctorId)),
        data: (doctor) => _buildBody(doctor),
      ),
    );
  }

  Widget _buildBody(Doctor doctor) {
    final activeServices = doctor.services.where((s) => s.isActive).toList();
    final canConfirm = _selectedService != null && _startTime != null && !_isSubmitting;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      children: [
        Column(
          children: [
            Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.electricBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                _initialsOf(doctor.doctorName),
                style: AppTextStyles.headlineXl.copyWith(color: AppColors.electricBlue),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(doctor.doctorName, style: AppTextStyles.headlineXl, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              doctor.specialization ?? 'General Physician',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Select Service', style: AppTextStyles.headlineMd),
        const SizedBox(height: AppSpacing.sm),
        for (final service in activeServices) _buildServiceCard(service),
        const SizedBox(height: AppSpacing.lg),
        Text('Schedule', style: AppTextStyles.headlineMd),
        const SizedBox(height: AppSpacing.sm),
        _buildDayStrip(),
        const SizedBox(height: AppSpacing.sm),
        _buildTimeGroup('MORNING', _morningSlots),
        const SizedBox(height: AppSpacing.sm),
        _buildTimeGroup('AFTERNOON', _afternoonSlots),
        const SizedBox(height: AppSpacing.lg),
        _buildSummary(),
        const SizedBox(height: AppSpacing.md),
        FilledButton(
          onPressed: canConfirm ? _confirmBooking : null,
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Confirm Booking'),
        ),
      ],
    );
  }

  Widget _buildServiceCard(Service service) {
    final selected = _selectedService == service;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        onTap: () => setState(() => _selectedService = service),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected ? AppColors.surfaceContainerLow : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(
              color: selected ? AppColors.electricBlue : AppColors.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.serviceName, style: AppTextStyles.headlineLg),
                    const SizedBox(height: 4),
                    Text(
                      '${service.durationHours}H • ৳${service.totalCost}',
                      style: AppTextStyles.labelCaps.copyWith(color: AppColors.electricBlue),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.check_circle,
                color: selected ? AppColors.electricBlue : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayStrip() {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final day = _days[index];
          final selected = _isSameDay(day, _selectedDay);
          return InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
            onTap: () => setState(() => _selectedDay = day),
            child: Container(
              width: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.electricBlue : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                border: selected ? null : Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekdayAbbrev[day.weekday - 1].toUpperCase(),
                    style: AppTextStyles.labelCaps.copyWith(
                      color: selected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: AppTextStyles.headlineLg.copyWith(
                      color: selected ? AppColors.onPrimary : AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeGroup(String label, List<TimeOfDay> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelCaps),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final slot in slots) _buildTimeChip(slot),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeChip(TimeOfDay slot) {
    final selected = _selectedTime == slot;
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
      onTap: () => setState(() => _selectedTime = slot),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: selected ? AppColors.electricBlue.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          border: Border.all(color: selected ? AppColors.electricBlue : AppColors.outlineVariant),
        ),
        child: Text(
          _formatTime(slot),
          style: AppTextStyles.bodySm.copyWith(
            color: selected ? AppColors.electricBlue : AppColors.onSurface,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final service = _selectedService;
    final startTime = _startTime;
    return AppCard(
      color: AppColors.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Booking Summary', style: AppTextStyles.headlineMd),
          const SizedBox(height: AppSpacing.sm),
          _buildSummaryRow('Service', service?.serviceName ?? '—'),
          const SizedBox(height: 4),
          _buildSummaryRow('Date & Time', startTime == null ? '—' : _formatDateTime(startTime)),
          const Divider(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.headlineLg),
              Text(
                service == null ? '৳—' : '৳${service.totalCost}',
                style: AppTextStyles.headlineLg.copyWith(color: AppColors.electricBlue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
        Text(value, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
