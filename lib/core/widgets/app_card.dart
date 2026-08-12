import 'package:ehealth/core/theme/app_colors.dart';
import 'package:ehealth/core/theme/app_shadows.dart';
import 'package:ehealth/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// The design system's card: white, 16px radius, level-1 micro-shadow, no
/// border at rest. Used for appointment/doctor/prescription list items and
/// any other grouped-content container.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.sm),
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        boxShadow: AppShadows.level1,
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: content,
      ),
    );
  }
}
