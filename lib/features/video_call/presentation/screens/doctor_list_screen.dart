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
                      onViewProfile: () => _openBooking(doctor),
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
