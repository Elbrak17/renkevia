import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:renkevia/src/features/evidence_vault/evidence_vault_fixture.dart';
import 'package:renkevia/src/features/simulation_lab/simulation_fixture.dart';

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
  SimulationRunState _simulationRunState = SimulationRunState.baselineFailed;
  String _selectedSimulationSuiteId = 'PED-07';
  EvidenceVaultRunState _evidenceVaultRunState = EvidenceVaultRunState.ready;
  String _selectedSpecialistReviewId = 'clinical-informatics';
  VaultLedgerView _selectedVaultLedgerView = VaultLedgerView.provenance;

  WorkspaceSection get section => _section;
  CompileState get compileState => _compileState;
  PatchCompileState get patchCompileState => _patchCompileState;
  String get selectedEvidenceId => _selectedEvidenceId;
  String get selectedMutationId => _selectedMutationId;
  PatchArtifact get selectedPatchArtifact => _selectedPatchArtifact;
  SimulationRunState get simulationRunState => _simulationRunState;
  String get selectedSimulationSuiteId => _selectedSimulationSuiteId;
  EvidenceVaultRunState get evidenceVaultRunState => _evidenceVaultRunState;
  String get selectedSpecialistReviewId => _selectedSpecialistReviewId;
  VaultLedgerView get selectedVaultLedgerView => _selectedVaultLedgerView;
  bool get pediatricBlockerRevealed => _compileState == CompileState.blocked;
  bool get patchRevised => _patchCompileState == PatchCompileState.revised;
  bool get simulationVerified =>
      _simulationRunState == SimulationRunState.verified;

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

  void selectSimulationSuite(String suiteId) {
    if (_selectedSimulationSuiteId == suiteId) return;
    _selectedSimulationSuiteId = suiteId;
    notifyListeners();
  }

  void selectSpecialistReview(String reviewId) {
    if (_selectedSpecialistReviewId == reviewId) return;
    _selectedSpecialistReviewId = reviewId;
    notifyListeners();
  }

  void selectVaultLedgerView(VaultLedgerView view) {
    if (_selectedVaultLedgerView == view) return;
    _selectedVaultLedgerView = view;
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

  Future<void> runRevisedSimulation() async {
    if (!patchRevised ||
        _simulationRunState != SimulationRunState.baselineFailed) {
      return;
    }
    _simulationRunState = SimulationRunState.running;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 920));
    _simulationRunState = SimulationRunState.verified;
    _selectedSimulationSuiteId = 'PED-07';
    notifyListeners();
  }

  Future<void> runSpecialistReviews() async {
    if (!simulationVerified ||
        _evidenceVaultRunState != EvidenceVaultRunState.ready) {
      return;
    }
    _evidenceVaultRunState = EvidenceVaultRunState.reviewing;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 980));
    _evidenceVaultRunState = EvidenceVaultRunState.sealed;
    _selectedSpecialistReviewId = 'clinical-informatics';
    _selectedVaultLedgerView = VaultLedgerView.provenance;
    notifyListeners();
  }

  void resetFixture() {
    _compileState = CompileState.ready;
    _patchCompileState = PatchCompileState.blocked;
    _selectedEvidenceId = 'SRC-001';
    _selectedMutationId = 'MUT-01';
    _selectedPatchArtifact = PatchArtifact.orderSet;
    _simulationRunState = SimulationRunState.baselineFailed;
    _selectedSimulationSuiteId = 'PED-07';
    _evidenceVaultRunState = EvidenceVaultRunState.ready;
    _selectedSpecialistReviewId = 'clinical-informatics';
    _selectedVaultLedgerView = VaultLedgerView.provenance;
    _section = WorkspaceSection.responseRoom;
    notifyListeners();
  }
}
