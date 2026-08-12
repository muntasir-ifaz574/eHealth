import 'package:flutter/material.dart';

/// "Soft micro-shadow" elevation levels from DESIGN.md — depth conveyed
/// through blur, not hard outlines.
abstract final class AppShadows {
  /// Level 1 — cards and interactive containers.
  static const level1 = [
    BoxShadow(color: Color(0x0A121212), blurRadius: 15, spreadRadius: 0),
  ];

  /// Level 2 — modals, dropdowns, active/floating elements.
  static const level2 = [
    BoxShadow(color: Color(0x14121212), blurRadius: 30, spreadRadius: 0),
  ];

  /// One-off blue-tinted glow used under primary CTA buttons.
  static const ctaGlow = [
    BoxShadow(color: Color(0x330055FF), blurRadius: 20, offset: Offset(0, 8)),
  ];
}
