abstract interface class DemoRunGateway {
  String get modeLabel;
  bool get isConnected;

  Future<CandidateRunResult> compileCandidate();
  Future<RecompileRunResult> recompilePatch();
  Future<SimulationRunResult> runSimulation();
  Future<AuditRunResult> runSpecialistAudit();
}

class CandidateRunResult {
  const CandidateRunResult({
    required this.patchVersion,
    required this.diffCount,
    required this.pathwayCount,
    required this.passedPathways,
    required this.assertionCount,
    required this.passedAssertions,
    required this.blockerIds,
    required this.finalCommitAllowed,
  });

  final String patchVersion;
  final int diffCount;
  final int pathwayCount;
  final int passedPathways;
  final int assertionCount;
  final int passedAssertions;
  final List<String> blockerIds;
  final bool finalCommitAllowed;
}

class RecompileRunResult {
  const RecompileRunResult({
    required this.patchVersion,
    required this.diffCount,
    required this.status,
    required this.finalCommitAllowed,
  });

  final String patchVersion;
  final int diffCount;
  final String status;
  final bool finalCommitAllowed;
}

class SimulationRunResult {
  const SimulationRunResult({
    required this.patchVersion,
    required this.pathwayCount,
    required this.passedPathways,
    required this.assertionCount,
    required this.passedAssertions,
    required this.provenanceCoverage,
    required this.exactRollbackVerified,
    required this.finalCommitAllowed,
  });

  final String patchVersion;
  final int pathwayCount;
  final int passedPathways;
  final int assertionCount;
  final int passedAssertions;
  final int provenanceCoverage;
  final bool exactRollbackVerified;
  final bool finalCommitAllowed;
}

class AuditRunResult {
  const AuditRunResult({
    required this.reviewCount,
    required this.roles,
    required this.preservedDissentIds,
    required this.approvalControlEnabled,
    required this.finalCommitAllowed,
  });

  final int reviewCount;
  final List<String> roles;
  final List<String> preservedDissentIds;
  final bool approvalControlEnabled;
  final bool finalCommitAllowed;
}

class DemoGatewayContractError implements Exception {
  const DemoGatewayContractError(this.message);
  final String message;

  @override
  String toString() => message;
}
