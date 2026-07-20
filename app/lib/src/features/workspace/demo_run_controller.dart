import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:renkevia/src/data/demo_run_gateway.dart';
import 'package:renkevia/src/features/evidence_vault/evidence_vault_fixture.dart';
import 'package:renkevia/src/features/legacy_ehr/legacy_ehr_fixture.dart';
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
  DemoRunController({
    DemoRunGateway? gateway,
    WorkspaceSection initialSection = WorkspaceSection.responseRoom,
  }) : _gateway = gateway ?? createDemoRunGateway(),
       _section = initialSection;

  final DemoRunGateway _gateway;
  WorkspaceSection _section;
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
  LegacyStagingProof? _legacyStagingProof;
  String? _lastGatewayError;

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
  LegacyStagingProof? get legacyStagingProof => _legacyStagingProof;
  String? get lastGatewayError => _lastGatewayError;
  String get executionModeLabel => _gateway.modeLabel;
  bool get isConnectedCore => _gateway.isConnected;
  bool get pediatricBlockerRevealed => _compileState == CompileState.blocked;
  bool get patchRevised => _patchCompileState == PatchCompileState.revised;
  bool get simulationVerified =>
      _simulationRunState == SimulationRunState.verified;
  bool get legacyStagingVerified => _legacyStagingProof?.isValid ?? false;

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
    _lastGatewayError = null;
    notifyListeners();
    try {
      final result = await _gateway.compileCandidate();
      if (result.patchVersion != 'v0.7' ||
          result.diffCount != 6 ||
          result.pathwayCount != 24 ||
          result.passedPathways != 23 ||
          result.assertionCount != 96 ||
          result.passedAssertions != 95 ||
          result.blockerIds.length != 1 ||
          result.blockerIds.single != 'PATH-PED-07-04/A1' ||
          result.finalCommitAllowed) {
        throw const DemoGatewayContractError(
          'Candidate proof did not match the sealed fixture contract.',
        );
      }
      _compileState = CompileState.blocked;
      _selectedEvidenceId = 'SRC-006';
    } catch (error) {
      _compileState = CompileState.ready;
      _lastGatewayError = 'Compilation blocked: $error';
    }
    notifyListeners();
  }

  Future<void> recompilePatch() async {
    if (_patchCompileState != PatchCompileState.blocked) return;
    _patchCompileState = PatchCompileState.recompiling;
    _lastGatewayError = null;
    notifyListeners();
    try {
      final result = await _gateway.recompilePatch();
      if (result.patchVersion != 'v0.8' ||
          result.diffCount != 12 ||
          result.status != 'revised' ||
          result.finalCommitAllowed) {
        throw const DemoGatewayContractError(
          'Recompiled patch did not match the sealed fixture contract.',
        );
      }
      _patchCompileState = PatchCompileState.revised;
      _selectedMutationId = 'MUT-02';
      _selectedPatchArtifact = PatchArtifact.orderSet;
    } catch (error) {
      _patchCompileState = PatchCompileState.blocked;
      _lastGatewayError = 'Recompilation blocked: $error';
    }
    notifyListeners();
  }

  Future<void> runRevisedSimulation() async {
    if (!patchRevised ||
        _simulationRunState != SimulationRunState.baselineFailed) {
      return;
    }
    _simulationRunState = SimulationRunState.running;
    _lastGatewayError = null;
    notifyListeners();
    try {
      final result = await _gateway.runSimulation();
      if (result.patchVersion != 'v0.8' ||
          result.pathwayCount != 24 ||
          result.passedPathways != 24 ||
          result.assertionCount != 96 ||
          result.passedAssertions != 96 ||
          result.provenanceCoverage != 100 ||
          !result.exactRollbackVerified ||
          result.finalCommitAllowed) {
        throw const DemoGatewayContractError(
          'Simulation proof did not match the sealed fixture contract.',
        );
      }
      _simulationRunState = SimulationRunState.verified;
      _selectedSimulationSuiteId = 'PED-07';
    } catch (error) {
      _simulationRunState = SimulationRunState.baselineFailed;
      _lastGatewayError = 'Simulation blocked: $error';
    }
    notifyListeners();
  }

  Future<void> runSpecialistReviews() async {
    if (!simulationVerified ||
        _evidenceVaultRunState != EvidenceVaultRunState.ready) {
      return;
    }
    _evidenceVaultRunState = EvidenceVaultRunState.reviewing;
    _lastGatewayError = null;
    notifyListeners();
    try {
      final result = await _gateway.runSpecialistAudit();
      const roles = {
        'pharmacy',
        'clinical_informatics',
        'pediatric_safety',
        'adversarial_auditor',
      };
      if (result.reviewCount != 4 ||
          result.roles.toSet().length != 4 ||
          !result.roles.toSet().containsAll(roles) ||
          !result.preservedDissentIds.contains('LEGACY-01') ||
          result.approvalControlEnabled ||
          result.finalCommitAllowed) {
        throw const DemoGatewayContractError(
          'Specialist audit did not preserve the staging dissent.',
        );
      }
      _evidenceVaultRunState = EvidenceVaultRunState.sealed;
      _selectedSpecialistReviewId = 'clinical-informatics';
      _selectedVaultLedgerView = VaultLedgerView.provenance;
    } catch (error) {
      _evidenceVaultRunState = EvidenceVaultRunState.ready;
      _lastGatewayError = 'Specialist audit blocked: $error';
    }
    notifyListeners();
  }

  void acceptLegacyStagingProof(LegacyStagingProof proof) {
    if (_evidenceVaultRunState != EvidenceVaultRunState.sealed ||
        !proof.isValid) {
      return;
    }
    _legacyStagingProof = proof;
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
    _legacyStagingProof = null;
    _lastGatewayError = null;
    _section = WorkspaceSection.responseRoom;
    notifyListeners();
  }
}
