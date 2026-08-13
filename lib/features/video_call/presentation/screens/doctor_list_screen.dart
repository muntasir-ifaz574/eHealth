import 'package:ehealth/core/router/route_names.dart';
import 'package:ehealth/core/theme/app_colors.dart';
import 'package:ehealth/core/theme/app_spacing.dart';
import 'package:ehealth/core/theme/app_text_styles.dart';
import 'package:ehealth/core/widgets/async_value_widget.dart';
import 'package:ehealth/features/video_call/domain/entities/doctor.dart';
import 'package:ehealth/features/video_call/presentation/providers/video_call_providers.dart';
import 'package:ehealth/features/video_call/presentation/widgets/doctor_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DoctorListScreen extends ConsumerStatefulWidget {
  const DoctorListScreen({super.key});

  @override
  ConsumerState<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends ConsumerState<DoctorListScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _selectedSpecialty = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Doctor> _filter(List<Doctor> doctors) {
    return doctors.where((doctor) {
      final matchesSpecialty =
          _selectedSpecialty == 'All' || doctor.specialization == _selectedSpecialty;
      final query = _query.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          doctor.doctorName.toLowerCase().contains(query) ||
          (doctor.specialization?.toLowerCase().contains(query) ?? false);
      return matchesSpecialty && matchesQuery;
    }).toList();
  }

  void _openBooking(Doctor doctor) {
    context.pushNamed(
      RouteNames.appointmentBooking,
      pathParameters: {'doctorId': doctor.doctorId.toString()},
    );
  }

  void _showDoctorProfileSheet(BuildContext context, Doctor doctor) {
    final words = doctor.doctorName.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final initials = words.map((w) => w[0]).take(2).join().toUpperCase();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusCard)),
      ),
      builder: (bottomSheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
              child: ListView(
                controller: scrollController,
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.electricBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          initials,
                          style: AppTextStyles.headlineXl.copyWith(color: AppColors.electricBlue),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doctor.doctorName, style: AppTextStyles.headlineXl),
                            const SizedBox(height: 4),
                            Text(
                              doctor.specialization ?? 'General Physician',
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.electricBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (doctor.qualifications != null && doctor.qualifications!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                doctor.qualifications!,
                                style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (doctor.bio != null && doctor.bio!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text('About Doctor', style: AppTextStyles.headlineMd),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      doctor.bio!,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (doctor.services.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text('Consultation Options', style: AppTextStyles.headlineMd),
                    const SizedBox(height: AppSpacing.xs),
                    for (final service in doctor.services)
                      Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(service.serviceName, style: AppTextStyles.headlineLg),
                                const SizedBox(height: 2),
                                Text(
                                  'Duration: ${service.durationHours}H',
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '৳${service.totalCost}',
                              style: AppTextStyles.headlineLg.copyWith(
                                color: AppColors.electricBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: doctor.isBookable
                          ? () {
                              Navigator.pop(bottomSheetContext);
                              _openBooking(doctor);
                            }
                          : null,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        doctor.isBookable ? 'Book Appointment' : 'Doctor Unavailable',
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(availableDoctorsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('eHealth'), centerTitle: true),
      body: AsyncValueWidget(
        value: doctorsAsync,
        onRetry: () => ref.invalidate(availableDoctorsProvider),
        data: (doctors) {
          if (doctors.isEmpty) {
            return const Center(child: Text('No doctors available right now.'));
          }

          final specialties = <String>{
            for (final doctor in doctors)
              if (doctor.specialization != null) doctor.specialization!,
          }.toList()
            ..sort();
          final filtered = _filter(doctors);

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Find a Specialist', style: AppTextStyles.headlineXl),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Discover our network of medical professionals tailored to your needs.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                      decoration: const InputDecoration(
                        hintText: 'Search doctors or specialties...',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                  children: [
                    for (final specialty in ['All', ...specialties])
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.xs),
                        child: ChoiceChip(
                          label: Text(specialty),
                          selected: _selectedSpecialty == specialty,
                          onSelected: (_) => setState(() => _selectedSpecialty = specialty),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Center(child: Text('No specialists match your search.')),
                )
              else
                for (final doctor in filtered)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.marginMobile,
                      0,
                      AppSpacing.marginMobile,
                      AppSpacing.sm,
                    ),
                    child: DoctorCard(
                      doctor: doctor,
                      onViewProfile: () => _showDoctorProfileSheet(context, doctor),
                      onBook: () => _openBooking(doctor),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}
