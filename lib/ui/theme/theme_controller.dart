﻿import 'package:flutter/material.dart';

class ThemeController {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.light);
  void toggle() {
    mode.value = mode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}
