import 'package:flutter/material.dart';

/// Color tokens from the Sentience-Health-derived design system
/// (`stitch_minimalist_smart_authentication/sentience_health/DESIGN.md`).
abstract final class AppColors {
  static const surface = Color(0xFFFAF8FF);
  static const surfaceDim = Color(0xFFD9D9E6);
  static const surfaceBright = Color(0xFFFAF8FF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF3F2FF);
  static const surfaceContainer = Color(0xFFEDEDFB);
  static const surfaceContainerHigh = Color(0xFFE7E7F5);
  static const surfaceContainerHighest = Color(0xFFE1E1EF);
  static const onSurface = Color(0xFF191B25);
  static const onSurfaceVariant = Color(0xFF434656);
  static const inverseSurface = Color(0xFF2E303A);
  static const inverseOnSurface = Color(0xFFF0F0FD);
  static const outline = Color(0xFF737688);
  static const outlineVariant = Color(0xFFC3C5D9);

  static const primary = Color(0xFF0041C8);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF0055FF);
  static const onPrimaryContainer = Color(0xFFE3E6FF);
  static const inversePrimary = Color(0xFFB6C4FF);
  static const primaryFixed = Color(0xFFDCE1FF);
  static const primaryFixedDim = Color(0xFFB6C4FF);

  static const secondary = Color(0xFF5F5E5E);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFE5E2E1);
  static const onSecondaryContainer = Color(0xFF656464);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  static const background = Color(0xFFFAF8FF);
  static const onBackground = Color(0xFF191B25);
  static const surfaceVariant = Color(0xFFE1E1EF);

  /// The singular "intelligent" accent — CTAs, active states, AI prompts.
  static const electricBlue = Color(0xFF0055FF);
  static const charcoalDeep = Color(0xFF121212);
  static const charcoalMuted = Color(0xFF404040);

  static const triageHigh = Color(0xFFFF3B30);
  static const triageMedium = Color(0xFFFFCC00);
  static const triageLow = Color(0xFF34C759);

  /// Recurring AI-prompt-bubble tint used across the mockups; not present in
  /// DESIGN.md's token frontmatter but appears literally in every screen
  /// that has an AI bubble/insight card.
  static const aiBubbleTint = Color(0xFFF0F5FF);
}
