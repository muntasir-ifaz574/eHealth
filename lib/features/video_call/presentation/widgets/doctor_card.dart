import 'package:ehealth/core/theme/app_colors.dart';
import 'package:ehealth/core/theme/app_spacing.dart';
import 'package:ehealth/core/theme/app_text_styles.dart';
import 'package:ehealth/core/widgets/app_card.dart';
import 'package:ehealth/features/video_call/domain/entities/doctor.dart';
import 'package:flutter/material.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onViewProfile,
    required this.onBook,
  });

  final Doctor doctor;
  final VoidCallback onViewProfile;
  final VoidCallback onBook;

  String get _initials {
    final words = doctor.doctorName.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    return words.map((w) => w[0]).take(2).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final activeServices = doctor.services.where((s) => s.isActive).toList();
    final lowestCost = activeServices.isNotEmpty
        ? activeServices.map((s) => s.totalCost).reduce((a, b) => a < b ? a : b)
        : null;

    return AppCard(
      onTap: onViewProfile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _initials,
                  style: AppTextStyles.headlineMd.copyWith(color: AppColors.electricBlue),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            doctor.doctorName,
                            style: AppTextStyles.headlineMd,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Profile',
                              style: AppTextStyles.labelCaps.copyWith(
                                color: AppColors.electricBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: AppColors.electricBlue,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctor.specialization ?? 'General Physician',
                      style: AppTextStyles.bodySm.copyWith(
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
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (doctor.bio != null && doctor.bio!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              doctor.bio!,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (lowestCost != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Consultation from ৳$lowestCost',
                  style: AppTextStyles.bodySm.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: doctor.isBookable ? onBook : null,
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(doctor.isBookable ? 'Book Appointment' : 'Unavailable'),
            ),
          ),
        ],
      ),
    );
  }
}

