import 'package:ehealth/core/constants/api_constants.dart';
import 'package:ehealth/core/router/route_names.dart';
import 'package:ehealth/core/theme/app_colors.dart';
import 'package:ehealth/core/theme/app_spacing.dart';
import 'package:ehealth/core/theme/app_text_styles.dart';
import 'package:ehealth/core/utils/dialer.dart';
import 'package:ehealth/core/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickActionData(
        icon: Icons.local_hospital,
        title: 'Nearby Hospitals',
        subtitle: 'Find hospitals close to you with contact numbers',
        onTap: () => context.pushNamed(RouteNames.hospitalList),
      ),
      _QuickActionData(
        icon: Icons.medical_services,
        title: 'Talk to a Doctor',
        subtitle: 'Book a live video consultation',
        onTap: () => context.pushNamed(RouteNames.doctorList),
      ),
      _QuickActionData(
        icon: Icons.health_and_safety,
        title: 'Symptom Checker',
        subtitle: 'Describe symptoms and get triaged first-aid guidance',
        onTap: () => context.pushNamed(RouteNames.symptomChecker),
      ),
      _QuickActionData(
        icon: Icons.show_chart,
        title: 'Health Progress',
        subtitle: 'Track your health trend over time',
        onTap: () => context.pushNamed(RouteNames.healthProgress),
      ),
      _QuickActionData(
        icon: Icons.mic,
        title: 'Voice Assistant',
        subtitle: 'View voice command transcript & help',
        onTap: () => context.pushNamed(RouteNames.voiceAssistant),
      ),
      _QuickActionData(
        icon: Icons.emergency,
        title: 'Emergency Call',
        subtitle: 'Dial ${AppConstants.emergencyServiceNumber} immediately',
        color: AppColors.error,
        onTap: () => dialPhoneNumber(AppConstants.emergencyServiceNumber),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        children: [
          Text(
            'Say "find hospital", "call doctor", or tap the mic — the app '
            'can be fully controlled by voice.',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.xs,
              crossAxisSpacing: AppSpacing.xs,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) => _QuickAction(data: actions[index]),
          ),
        ],
      ),
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.data});

  final _QuickActionData data;

  @override
  Widget build(BuildContext context) {
    final tint = data.color ?? AppColors.electricBlue;
    return AppCard(
      onTap: data.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
            ),
            child: Icon(data.icon, color: tint),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            data.title,
            style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Text(
              data.subtitle,
              style: AppTextStyles.bodySm,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
