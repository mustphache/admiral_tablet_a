import 'package:flutter/material.dart';

class AppTypography {
  static TextTheme textTheme(ColorScheme c) => TextTheme(
    titleLarge:  TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: c.onSurface),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: c.onSurface),
    bodyMedium:  TextStyle(fontSize: 14, color: c.onSurface),
    labelLarge:  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  );
}
