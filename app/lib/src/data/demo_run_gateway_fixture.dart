import 'demo_run_gateway_contract.dart';

class FixtureReplayGateway implements DemoRunGateway {
  const FixtureReplayGateway();

  @override
  String get modeLabel => 'FIXTURE REPLAY';

  @override
  bool get isConnected => false;

  @override
  Future<CandidateRunResult> compileCandidate() async {
    await Future<void>.delayed(const Duration(milliseconds: 720));
    return const CandidateRunResult(
      patchVersion: 'v0.7',
      diffCount: 6,
      pathwayCount: 24,
      passedPathways: 23,
      assertionCount: 96,
      passedAssertions: 95,
      blockerIds: ['PATH-PED-07-04/A1'],
      finalCommitAllowed: false,
    );
  }

  @override
  Future<RecompileRunResult> recompilePatch() async {
    await Future<void>.delayed(const Duration(milliseconds: 860));
    return const RecompileRunResult(
      patchVersion: 'v0.8',
      diffCount: 12,
      status: 'revised',
      finalCommitAllowed: false,
    );
  }

  @override
  Future<SimulationRunResult> runSimulation() async {
    await Future<void>.delayed(const Duration(milliseconds: 920));
    return const SimulationRunResult(
      patchVersion: 'v0.8',
      pathwayCount: 24,
      passedPathways: 24,
      assertionCount: 96,
      passedAssertions: 96,
      provenanceCoverage: 100,
      exactRollbackVerified: true,
      finalCommitAllowed: false,
    );
  }

  @override
  Future<AuditRunResult> runSpecialistAudit() async {
    await Future<void>.delayed(const Duration(milliseconds: 980));
    return const AuditRunResult(
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
}
