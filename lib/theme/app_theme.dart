import 'package:flutter/material.dart';

class AppTheme {
  static const bg = Color(0xFF0B0D10);
  static const panel = Color(0xFF15181D);
  static const panel2 = Color(0xFF1B1F25);
  static const border = Color(0xFF262B31);
  static const accent = Color(0xFFC9A227);
  static const muted = Color(0xFF868C96);
  static const danger = Color(0xFFE5484D);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accent,
          surface: panel,
          error: danger,
        ),
      );

  static InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: muted, fontSize: 13),
      filled: true,
      fillColor: panel2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
    );
  }
}
