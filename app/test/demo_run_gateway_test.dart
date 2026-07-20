import 'package:flutter_test/flutter_test.dart';
import 'package:renkevia/src/data/demo_run_gateway.dart';
import 'package:renkevia/src/features/evidence_vault/evidence_vault_fixture.dart';
import 'package:renkevia/src/features/workspace/demo_run_controller.dart';

class _ConnectedFixtureGateway implements DemoRunGateway {
  const _ConnectedFixtureGateway({this.unsafeFinalCommit = false});

  final bool unsafeFinalCommit;

  @override
  bool get isConnected => true;

  @override
  String get modeLabel => 'CONNECTED CORE';

  @override
  Future<CandidateRunResult> compileCandidate() async => CandidateRunResult(
    patchVersion: 'v0.7',
    diffCount: 6,
    pathwayCount: 24,
    passedPathways: 23,
    assertionCount: 96,
    passedAssertions: 95,
    blockerIds: const ['PATH-PED-07-04/A1'],
    finalCommitAllowed: unsafeFinalCommit,
  );

  @override
  Future<RecompileRunResult> recompilePatch() async => const RecompileRunResult(
    patchVersion: 'v0.8',
    diffCount: 12,
    status: 'revised',
    finalCommitAllowed: false,
  );

  @override
  Future<SimulationRunResult> runSimulation() async =>
      const SimulationRunResult(
        patchVersion: 'v0.8',
        pathwayCount: 24,
        passedPathways: 24,
        assertionCount: 96,
        passedAssertions: 96,
        provenanceCoverage: 100,
        exactRollbackVerified: true,
        finalCommitAllowed: false,
      );

  @override
  Future<AuditRunResult> runSpecialistAudit() async => const AuditRunResult(
    reviewCount: 4,
    roles: [
      'pharmacy',
      'clinical_informatics',
      'pediatric_safety',
      'adversarial_auditor',
    ],
    preservedDissentIds: ['LEGACY-01'],
    approvalControlEnabled: false,
    finalCommitAllowed: false,
  );
}

void main() {
  test(
    'fixture gateway remains an explicitly labeled deterministic replay',
    () {
      const gateway = FixtureReplayGateway();
      expect(gateway.modeLabel, 'FIXTURE REPLAY');
      expect(gateway.isConnected, isFalse);
    },
  );

  test(
    'connected core drives the complete proof sequence without fallback',
    () async {
      final controller = DemoRunController(
        gateway: const _ConnectedFixtureGateway(),
      );
      addTearDown(controller.dispose);

      expect(controller.executionModeLabel, 'CONNECTED CORE');
      await controller.compileFixture();
      expect(controller.compileState, CompileState.blocked);
      await controller.recompilePatch();
      expect(controller.patchCompileState, PatchCompileState.revised);
      await controller.runRevisedSimulation();
      expect(controller.simulationVerified, isTrue);
      await controller.runSpecialistReviews();
      expect(controller.evidenceVaultRunState, EvidenceVaultRunState.sealed);
      expect(controller.lastGatewayError, isNull);
    },
  );

  test(
    'client rejects a connected response that tries to enable final commit',
    () async {
      final controller = DemoRunController(
        gateway: const _ConnectedFixtureGateway(unsafeFinalCommit: true),
      );
      addTearDown(controller.dispose);

      await controller.compileFixture();

      expect(controller.compileState, CompileState.ready);
      expect(controller.lastGatewayError, contains('sealed fixture contract'));
    },
  );
}
