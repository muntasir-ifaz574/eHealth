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
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
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
                    Text(doctor.doctorName, style: AppTextStyles.headlineMd),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialization ?? 'General Physician',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.electricBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (doctor.bio != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              doctor.bio!,
              style: AppTextStyles.bodySm,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewProfile,
                  child: const Text('View Profile'),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: FilledButton(
                  onPressed: doctor.isBookable ? onBook : null,
                  child: Text(doctor.isBookable ? 'Book Now' : 'Unavailable'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
