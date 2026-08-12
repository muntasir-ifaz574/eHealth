import 'package:ehealth/core/theme/app_colors.dart';
import 'package:ehealth/core/theme/app_spacing.dart';
import 'package:ehealth/core/theme/app_text_styles.dart';
import 'package:ehealth/core/utils/dialer.dart';
import 'package:ehealth/core/widgets/app_card.dart';
import 'package:ehealth/core/widgets/pill_chip.dart';
import 'package:ehealth/features/hospital/domain/entities/hospital.dart';
import 'package:flutter/material.dart';

class HospitalCard extends StatelessWidget {
  const HospitalCard({super.key, required this.hospital, required this.onTap});

  final Hospital hospital;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final distanceKm = hospital.distanceInMeters == null
        ? null
        : (hospital.distanceInMeters! / 1000).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
      child: AppCard(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.electricBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
              ),
              child: const Icon(Icons.local_hospital, color: AppColors.electricBlue),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hospital.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hospital.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySm,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (distanceKm != null)
                        Text('$distanceKm km', style: AppTextStyles.labelCaps),
                      if (hospital.rating != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(hospital.rating!.toStringAsFixed(1), style: AppTextStyles.labelCaps),
                          ],
                        ),
                      if (hospital.isOpenNow != null)
                        PillChip(
                          label: hospital.isOpenNow! ? 'OPEN NOW' : 'CLOSED',
                          color: hospital.isOpenNow! ? AppColors.triageLow : AppColors.error,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.call, color: AppColors.electricBlue),
              tooltip: hospital.phoneNumber == null ? 'Open for contact number' : 'Call hospital',
              onPressed: () {
                if (hospital.phoneNumber != null) {
                  dialPhoneNumber(hospital.phoneNumber!);
                } else {
                  onTap();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
