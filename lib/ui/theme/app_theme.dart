import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_shapes.dart';

class AppTheme {
  static ThemeData light() {
    final cs = ColorScheme.fromSeed(seedColor: AppColors.seed, brightness: Brightness.light);
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: AppTypography.textTheme(cs),
      cardTheme: CardThemeData(shape: AppShapes.cardShape, elevation: 0),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: AppShapes.buttonShape, minimumSize: const Size(44,44)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(shape: AppShapes.buttonShape, minimumSize: const Size(44,44)),
      ),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder(), isDense: true),
    );
  }

  static ThemeData dark() {
    final cs = ColorScheme.fromSeed(seedColor: AppColors.seed, brightness: Brightness.dark);
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: AppTypography.textTheme(cs),
      cardTheme: CardThemeData(shape: AppShapes.cardShape, elevation: 0),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: AppShapes.buttonShape, minimumSize: const Size(44,44)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(shape: AppShapes.buttonShape, minimumSize: const Size(44,44)),
      ),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder(), isDense: true),
    );
  }
}
