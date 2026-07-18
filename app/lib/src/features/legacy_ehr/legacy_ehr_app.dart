import 'package:flutter/material.dart';
import 'package:renkevia/src/features/legacy_ehr/legacy_ehr_sandbox_page.dart';

class LegacyEhrSandboxApp extends StatelessWidget {
  const LegacyEhrSandboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'RenkeviaSans',
    );
    return MaterialApp(
      title: 'Northstar Legacy EHR — Fictional Sandbox',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: const Color(0xFFE8EDF1),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF174E7A),
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Color(0xFF1B2A36),
          error: Color(0xFFB43B34),
          outline: Color(0xFFCAD3DA),
        ),
        textTheme: base.textTheme
            .copyWith(
              headlineMedium: const TextStyle(
                color: Color(0xFF1B2A36),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              titleMedium: const TextStyle(
                color: Color(0xFF1B2A36),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              bodyMedium: const TextStyle(
                color: Color(0xFF536673),
                fontSize: 11,
                height: 1.4,
              ),
            )
            .apply(fontFamily: 'RenkeviaSans'),
      ),
      home: const LegacyEhrSandboxPage(standalone: true),
    );
  }
}
