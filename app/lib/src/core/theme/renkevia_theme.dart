import 'package:flutter/material.dart';

abstract final class RenkeviaColors {
  // The palette comes from a real clinical change room: porcelain worktops,
  // brushed steel, dark instrument glass, teal sterile wraps, and paper charts.
  static const canvas = Color(0xFFF2F5F2);
  static const surface = Color(0xFFF8FAF7);
  static const surfaceRaised = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF0F4F1);
  static const surfaceInset = Color(0xFFEBF0ED);
  static const graphite = Color(0xFF10211F);
  static const graphiteSoft = Color(0xFF1A2D2A);
  static const ink = Color(0xFF172522);
  static const inkSecondary = Color(0xFF43534F);
  static const inkMuted = Color(0xFF687773);
  static const hairline = Color(0xFFDCE4E0);
  static const hairlineDark = Color(0xFF304440);
  static const cyan = Color(0xFF28B8AA);
  static const cyanDark = Color(0xFF08736C);
  static const cyanWash = Color(0xFFE2F4F0);
  static const amber = Color(0xFFD99A2B);
  static const amberWash = Color(0xFFFFF1D5);
  static const danger = Color(0xFFBF493F);
  static const dangerWash = Color(0xFFFBE8E4);
  static const success = Color(0xFF247B58);
  static const successWash = Color(0xFFE3F1E9);
  static const violet = Color(0xFF625E97);
}

abstract final class RenkeviaShadows {
  static const panel = <BoxShadow>[
    BoxShadow(color: Color(0x0A10211F), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0810211F), blurRadius: 10, offset: Offset(0, 4)),
  ];
  static const hero = <BoxShadow>[
    BoxShadow(color: Color(0x0D10211F), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0A10211F), blurRadius: 20, offset: Offset(0, 8)),
  ];
  static const overlay = <BoxShadow>[
    BoxShadow(color: Color(0x1A10211F), blurRadius: 28, offset: Offset(0, 12)),
  ];
}

abstract final class RenkeviaTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'RenkeviaSans',
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

    final textTheme = base.textTheme
        .copyWith(
          displayLarge: const TextStyle(
            color: RenkeviaColors.ink,
            fontSize: 46,
            height: 1.04,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.65,
          ),
          headlineLarge: const TextStyle(
            color: RenkeviaColors.ink,
            fontSize: 30,
            height: 1.1,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.95,
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
            fontSize: 17,
            height: 1.25,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
          titleMedium: const TextStyle(
            color: RenkeviaColors.ink,
            fontSize: 13,
            height: 1.25,
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: const TextStyle(
            color: RenkeviaColors.ink,
            fontSize: 15,
            height: 1.55,
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: const TextStyle(
            color: RenkeviaColors.inkSecondary,
            fontSize: 13,
            height: 1.5,
            fontWeight: FontWeight.w400,
          ),
          bodySmall: const TextStyle(
            color: RenkeviaColors.inkMuted,
            fontSize: 11,
            height: 1.4,
            fontWeight: FontWeight.w400,
          ),
          labelLarge: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.05,
          ),
          labelMedium: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.05,
          ),
        )
        .apply(fontFamily: 'RenkeviaSans');

    return base.copyWith(
      textTheme: textTheme,
      dividerColor: RenkeviaColors.hairline,
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        color: RenkeviaColors.surfaceRaised,
        elevation: 1,
        shadowColor: const Color(0x1810211F),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: RenkeviaColors.graphite,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: RenkeviaColors.ink,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          side: const BorderSide(color: RenkeviaColors.hairline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(48),
          foregroundColor: RenkeviaColors.inkSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        height: 72,
        backgroundColor: RenkeviaColors.surfaceRaised,
        indicatorColor: RenkeviaColors.cyanWash,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: RenkeviaColors.graphite,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
