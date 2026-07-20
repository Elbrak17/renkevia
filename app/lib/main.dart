import 'package:flutter/material.dart';
import 'package:renkevia/src/app.dart';
import 'package:renkevia/src/features/legacy_ehr/legacy_ehr_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final surface = Uri.base.queryParameters['surface'];
  runApp(
    surface == 'legacy-ehr' ? const LegacyEhrSandboxApp() : const RenkeviaApp(),
  );
}
