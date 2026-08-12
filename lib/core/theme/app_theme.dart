import 'package:ehealth/core/theme/app_colors.dart';
import 'package:ehealth/core/theme/app_spacing.dart';
import 'package:ehealth/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
    );

    final textTheme = TextTheme(
      headlineLarge: AppTextStyles.headlineXl,
      headlineMedium: AppTextStyles.headlineLg,
      headlineSmall: AppTextStyles.headlineMd,
      titleLarge: AppTextStyles.headlineMd,
      bodyLarge: AppTextStyles.bodyLg,
      bodyMedium: AppTextStyles.bodyMd,
      bodySmall: AppTextStyles.bodySm,
      labelLarge: AppTextStyles.button,
      labelSmall: AppTextStyles.labelCaps,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.onSurface,
        titleTextStyle: AppTextStyles.headlineMd,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.outlineVariant, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.electricBlue,
          foregroundColor: AppColors.onPrimary,
          textStyle: AppTextStyles.button,
          // A finite minimum, not Size.fromHeight (== infinite width) — that
          // forced every button to demand unbounded width by default, which
          // crashes any button placed directly in a Row/other unconstrained
          // parent. Screens that want a full-width CTA already wrap it in
          // their own SizedBox(width: double.infinity, ...) explicitly.
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.charcoalDeep,
          side: const BorderSide(color: AppColors.charcoalDeep, width: 1.5),
          textStyle: AppTextStyles.button,
          // A finite minimum, not Size.fromHeight (== infinite width) — that
          // forced every button to demand unbounded width by default, which
          // crashes any button placed directly in a Row/other unconstrained
          // parent. Screens that want a full-width CTA already wrap it in
          // their own SizedBox(width: double.infinity, ...) explicitly.
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.electricBlue,
          textStyle: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        labelStyle: AppTextStyles.labelCaps,
        hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          borderSide: const BorderSide(color: AppColors.electricBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        selectedColor: AppColors.electricBlue,
        labelStyle: AppTextStyles.bodySm,
        shape: const StadiumBorder(),
        side: BorderSide.none,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        height: 68,
        indicatorColor: AppColors.primaryContainer.withValues(alpha: 0.12),
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTextStyles.bodySm.copyWith(
            color: selected ? AppColors.electricBlue : AppColors.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? AppColors.electricBlue : AppColors.onSurfaceVariant);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? AppColors.electricBlue : Colors.transparent;
        }),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
    );
  }

  static ThemeData get dark {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: AppColors.electricBlue,
      brightness: Brightness.dark,
    );
    // DESIGN.md only defines light-mode tokens; dark mode derives a
    // contrast-correct Material3 scheme from the same accent color instead
    // of reusing the light theme's hardcoded (light-mode) text colors.
    final textTheme = GoogleFonts.interTextTheme(ThemeData(brightness: Brightness.dark).textTheme)
        .copyWith(
      headlineLarge: GoogleFonts.hankenGrotesk(fontSize: 28, fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.hankenGrotesk(fontSize: 24, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.hankenGrotesk(fontSize: 22, fontWeight: FontWeight.w600),
      labelSmall: GoogleFonts.jetBrainsMono(fontSize: 12, letterSpacing: 1.2),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: baseScheme,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(centerTitle: true),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: baseScheme.primaryContainer.withValues(alpha: 0.3),
        indicatorShape: const StadiumBorder(),
      ),
    );
  }
}
