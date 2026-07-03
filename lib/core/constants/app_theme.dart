import 'package:flutter/material.dart';

class AppTheme {
  // Bảng màu thương hiệu MamGo: xanh dương + cam
  static const Color primary = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color secondary = Color(0xFF42A5F5);
  static const Color orange = Color(0xFFFF8A00);
  static const Color orangeDark = Color(0xFFF57C00);
  static const Color success = Color(0xFF2E9E5B);
  static const Color background = Color(0xFFF6F9FE);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF17223B);
  static const Color textMedium = Color(0xFF66788F);
  static const Color accent = Color(0xFFFF8A00);
  static const Color chipBg = Color(0xFFE7F0FC);

  static const List<Color> backgroundGradient = [
    Color(0xFFF2F7FE),
    Color(0xFFFDFEFF),
    Color(0xFFEFF5FD),
  ];

  static const List<Color> brandGradient = [
    Color(0xFF1E88E5),
    Color(0xFFFF8A00),
  ];

  static const List<Color> orangeGradient = [
    Color(0xFFFF9800),
    Color(0xFFFF6D00),
  ];

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: cardBg,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD3E2F5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD3E2F5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 3,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: chipBg,
        selectedColor: primary,
        labelStyle: const TextStyle(fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
