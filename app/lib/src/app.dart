import 'package:flutter/material.dart';
import 'package:renkevia/src/core/theme/renkevia_theme.dart';
import 'package:renkevia/src/features/workspace/demo_run_controller.dart';
import 'package:renkevia/src/features/workspace/workspace_shell.dart';

class RenkeviaApp extends StatefulWidget {
  const RenkeviaApp({super.key});

  @override
  State<RenkeviaApp> createState() => _RenkeviaAppState();
}

class _RenkeviaAppState extends State<RenkeviaApp> {
  late final DemoRunController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DemoRunController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RENKEVIA — Institutional Change Compiler',
      debugShowCheckedModeBanner: false,
      theme: RenkeviaTheme.light(),
      home: WorkspaceShell(controller: _controller),
    );
  }
}
