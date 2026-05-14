import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFE57373),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );
  }
}
