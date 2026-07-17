import 'dart:async';

import 'package:flutter/foundation.dart';

enum WorkspaceSection {
  responseRoom,
  patchStudio,
  simulationLab,
  evidenceVault,
}

enum CompileState { ready, mapping, blocked }

enum PatchCompileState { blocked, recompiling, revised }

enum PatchArtifact {
  policy,
  orderSet,
  pumpLibrary,
  label,
  communication,
  legacyEhr,
}

class DemoRunController extends ChangeNotifier {
  WorkspaceSection _section = WorkspaceSection.responseRoom;
  CompileState _compileState = CompileState.ready;
  PatchCompileState _patchCompileState = PatchCompileState.blocked;
  String _selectedEvidenceId = 'SRC-001';
  String _selectedMutationId = 'MUT-01';
  PatchArtifact _selectedPatchArtifact = PatchArtifact.orderSet;

  WorkspaceSection get section => _section;
  CompileState get compileState => _compileState;
  PatchCompileState get patchCompileState => _patchCompileState;
  String get selectedEvidenceId => _selectedEvidenceId;
  String get selectedMutationId => _selectedMutationId;
  PatchArtifact get selectedPatchArtifact => _selectedPatchArtifact;
  bool get pediatricBlockerRevealed => _compileState == CompileState.blocked;
  bool get patchRevised => _patchCompileState == PatchCompileState.revised;

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

  void selectMutation(String mutationId) {
    if (_selectedMutationId == mutationId) return;
    _selectedMutationId = mutationId;
    notifyListeners();
  }

  void selectPatchArtifact(PatchArtifact artifact) {
    if (_selectedPatchArtifact == artifact) return;
    _selectedPatchArtifact = artifact;
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

  Future<void> recompilePatch() async {
    if (_patchCompileState != PatchCompileState.blocked) return;
    _patchCompileState = PatchCompileState.recompiling;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 860));
    _patchCompileState = PatchCompileState.revised;
    _selectedMutationId = 'MUT-02';
    _selectedPatchArtifact = PatchArtifact.orderSet;
    notifyListeners();
  }

  void resetFixture() {
    _compileState = CompileState.ready;
    _patchCompileState = PatchCompileState.blocked;
    _selectedEvidenceId = 'SRC-001';
    _selectedMutationId = 'MUT-01';
    _selectedPatchArtifact = PatchArtifact.orderSet;
    _section = WorkspaceSection.responseRoom;
    notifyListeners();
  }
}
