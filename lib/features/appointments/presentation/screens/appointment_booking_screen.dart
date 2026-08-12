import 'package:ehealth/core/router/route_names.dart';
import 'package:ehealth/core/widgets/async_value_widget.dart';
import 'package:ehealth/features/appointments/domain/usecases/book_appointment.dart';
import 'package:ehealth/features/appointments/presentation/providers/appointments_providers.dart';
import 'package:ehealth/features/auth/presentation/providers/auth_providers.dart';
import 'package:ehealth/features/video_call/domain/entities/service.dart';
import 'package:ehealth/features/video_call/presentation/providers/video_call_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppointmentBookingScreen extends ConsumerStatefulWidget {
  const AppointmentBookingScreen({super.key, required this.doctorId});

  final int doctorId;

  @override
  ConsumerState<AppointmentBookingScreen> createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends ConsumerState<AppointmentBookingScreen> {
  Service? _selectedService;
  DateTime? _startTime;
  bool _isSubmitting = false;

  Future<void> _pickStartTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null || !mounted) return;
    setState(() {
      _startTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
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
          RouteNames.paymentCheckout,
          pathParameters: {'consultationId': confirmation.consultationId.toString()},
          extra: {'amount': service.totalCost, 'userId': userId},
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctorAsync = ref.watch(doctorByIdProvider(widget.doctorId));

    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: AsyncValueWidget(
        value: doctorAsync,
        onRetry: () => ref.invalidate(doctorByIdProvider(widget.doctorId)),
        data: (doctor) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(doctor.doctorName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(doctor.specialization ?? 'General Physician'),
              const SizedBox(height: 24),
              const Text('Choose a service', style: TextStyle(fontWeight: FontWeight.w600)),
              RadioGroup<Service>(
                groupValue: _selectedService,
                onChanged: (value) => setState(() => _selectedService = value),
                child: Column(
                  children: doctor.services.where((s) => s.isActive).map((service) {
                    return RadioListTile<Service>(
                      value: service,
                      title: Text(service.serviceName),
                      subtitle: Text('${service.durationHours}h · ৳${service.totalCost}'),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule),
                title: Text(
                  _startTime == null ? 'Pick a date & time' : _startTime.toString().substring(0, 16),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickStartTime,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: (_selectedService != null && _startTime != null && !_isSubmitting)
                    ? _confirmBooking
                    : null,
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
        },
      ),
    );
  }
}
