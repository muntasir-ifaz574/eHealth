import 'package:ehealth/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// A pill-shaped chip: a 10%-opacity tint of [color] as background, with
/// [color] itself used for the icon/label — backs triage chips and
/// neutral status badges ("IN 15 MINS", "Active", "Expired", ...).
class PillChip extends StatelessWidget {
  const PillChip({super.key, required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.labelCaps.copyWith(color: color, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}
