import 'package:ehealth/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography tokens from DESIGN.md: Hanken Grotesk for headlines, Inter for
/// body copy, JetBrains Mono (uppercase, tracked-out) for labels/metadata.
/// Mobile sizes are used throughout since this is a phone-only app.
abstract final class AppTextStyles {
  static TextStyle get headlineXl => GoogleFonts.hankenGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 34 / 28,
        letterSpacing: -0.02 * 28,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineLg => GoogleFonts.hankenGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 30 / 24,
        letterSpacing: -0.01 * 24,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineMd => GoogleFonts.hankenGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 28 / 22,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.onSurface,
      );

  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: AppColors.onSurfaceVariant,
      );

  /// Uppercase metadata/labels — triage statuses, timestamps, ids.
  static TextStyle get labelCaps => GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.1 * 12,
        color: AppColors.onSurfaceVariant,
      );

  /// Button label style — Inter semibold, matching the majority of the
  /// mockups' CTA text (headline-font buttons on a couple of auth screens
  /// were a one-off, not a system-wide rule worth adopting everywhere).
  static TextStyle get button => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );
}
