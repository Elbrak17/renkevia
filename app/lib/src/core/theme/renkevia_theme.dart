import 'package:flutter/material.dart';

abstract final class RenkeviaColors {
  static const canvas = Color(0xFFF1EFE8);
  static const surface = Color(0xFFFBFAF5);
  static const surfaceRaised = Color(0xFFFFFFFF);
  static const graphite = Color(0xFF142020);
  static const graphiteSoft = Color(0xFF1D2A2A);
  static const ink = Color(0xFF182222);
  static const inkMuted = Color(0xFF63706F);
  static const hairline = Color(0xFFD9DED9);
  static const hairlineDark = Color(0xFF31403F);
  static const cyan = Color(0xFF3ABDB4);
  static const cyanDark = Color(0xFF137E79);
  static const cyanWash = Color(0xFFE2F5F1);
  static const amber = Color(0xFFE4A63A);
  static const amberWash = Color(0xFFFFF2D8);
  static const danger = Color(0xFFC94F43);
  static const dangerWash = Color(0xFFFBE6E2);
  static const success = Color(0xFF2E8B65);
  static const successWash = Color(0xFFE3F3EA);
  static const violet = Color(0xFF6F6AA8);
}

abstract final class RenkeviaTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: RenkeviaColors.canvas,
      colorScheme: const ColorScheme.light(
        primary: RenkeviaColors.cyanDark,
        onPrimary: Colors.white,
        secondary: RenkeviaColors.cyan,
        surface: RenkeviaColors.surface,
        onSurface: RenkeviaColors.ink,
        error: RenkeviaColors.danger,
        outline: RenkeviaColors.hairline,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displayLarge: const TextStyle(
          color: RenkeviaColors.ink,
          fontSize: 42,
          height: 1.05,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.4,
        ),
        headlineLarge: const TextStyle(
          color: RenkeviaColors.ink,
          fontSize: 28,
          height: 1.12,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        headlineMedium: const TextStyle(
          color: RenkeviaColors.ink,
          fontSize: 20,
          height: 1.2,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.35,
        ),
        titleLarge: const TextStyle(
          color: RenkeviaColors.ink,
          fontSize: 16,
          height: 1.25,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: const TextStyle(
          color: RenkeviaColors.ink,
          fontSize: 13,
          height: 1.25,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: const TextStyle(
          color: RenkeviaColors.ink,
          fontSize: 14,
          height: 1.5,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: const TextStyle(
          color: RenkeviaColors.inkMuted,
          fontSize: 12,
          height: 1.45,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.15,
        ),
        labelMedium: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.7,
        ),
      ),
      dividerColor: RenkeviaColors.hairline,
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        color: RenkeviaColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: RenkeviaColors.hairline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: RenkeviaColors.graphite,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 42),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: RenkeviaColors.ink,
          minimumSize: const Size(0, 42),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          side: const BorderSide(color: RenkeviaColors.hairline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: RenkeviaColors.graphite,
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}
