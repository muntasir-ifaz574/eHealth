import 'dart:ui';

import 'package:ehealth/core/constants/api_constants.dart';
import 'package:ehealth/core/router/route_names.dart';
import 'package:ehealth/core/theme/app_colors.dart';
import 'package:ehealth/core/theme/app_shadows.dart';
import 'package:ehealth/core/theme/app_spacing.dart';
import 'package:ehealth/core/theme/app_text_styles.dart';
import 'package:ehealth/core/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.electricBlue.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceContainerLowest,
                          boxShadow: AppShadows.level1,
                        ),
                        child: const Icon(Icons.check_circle, color: AppColors.electricBlue, size: 48),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  "You're all set!",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineXl,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Welcome to ${AppConstants.appName}. Your intelligent care platform is ready to '
                  'guide you towards optimal well-being.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  onTap: () => context.goNamed(RouteNames.doctorList),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                        ),
                        child: const Icon(Icons.calendar_today, color: AppColors.electricBlue),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Book your first consultation', style: AppTextStyles.headlineMd),
                      const SizedBox(height: 4),
                      Text(
                        'Connect with our specialized care team to establish your baseline and '
                        'set your health goals.',
                        style: AppTextStyles.bodySm,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  onTap: () => context.goNamed(RouteNames.profile),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                        ),
                        child: const Icon(Icons.medical_information, color: AppColors.electricBlue),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Complete your health profile', style: AppTextStyles.headlineMd),
                      const SizedBox(height: 4),
                      Text(
                        'Help our AI personalize your care by providing a comprehensive overview '
                        'of your medical history.',
                        style: AppTextStyles.bodySm,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: () => context.goNamed(RouteNames.home),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Get Started'),
                      SizedBox(width: AppSpacing.xs),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
