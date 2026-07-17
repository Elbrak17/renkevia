import 'dart:async';

import 'package:flutter/foundation.dart';

enum WorkspaceSection {
  responseRoom,
  patchStudio,
  simulationLab,
  evidenceVault,
}

enum CompileState { ready, mapping, blocked }

class DemoRunController extends ChangeNotifier {
  WorkspaceSection _section = WorkspaceSection.responseRoom;
  CompileState _compileState = CompileState.ready;
  String _selectedEvidenceId = 'SRC-001';

  WorkspaceSection get section => _section;
  CompileState get compileState => _compileState;
  String get selectedEvidenceId => _selectedEvidenceId;
  bool get pediatricBlockerRevealed => _compileState == CompileState.blocked;

  void selectSection(WorkspaceSection section) {
    if (_section == section) return;
    _section = section;
    notifyListeners();
  }

  void selectEvidence(String evidenceId) {
    if (_selectedEvidenceId == evidenceId) return;
    _selectedEvidenceId = evidenceId;
    notifyListeners();
  }

  Future<void> compileFixture() async {
    if (_compileState == CompileState.mapping) return;
    if (_compileState == CompileState.blocked) {
      resetFixture();
      return;
    }
    _compileState = CompileState.mapping;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 720));
    _compileState = CompileState.blocked;
    _selectedEvidenceId = 'SRC-006';
    notifyListeners();
  }

  void resetFixture() {
    _compileState = CompileState.ready;
    _selectedEvidenceId = 'SRC-001';
    _section = WorkspaceSection.responseRoom;
    notifyListeners();
  }
}
