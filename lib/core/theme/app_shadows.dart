import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const level1 = [
    BoxShadow(color: Color(0x0A121212), blurRadius: 15, spreadRadius: 0),
  ];

  static const level2 = [
    BoxShadow(color: Color(0x14121212), blurRadius: 30, spreadRadius: 0),
  ];

  static const ctaGlow = [
    BoxShadow(color: Color(0x330055FF), blurRadius: 20, offset: Offset(0, 8)),
  ];
}
