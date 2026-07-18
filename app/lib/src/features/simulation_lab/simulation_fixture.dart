enum SimulationRunState { baselineFailed, running, verified }

enum RegressionOutcome { passed, failed, running }

class SimulationSuite {
  const SimulationSuite({
    required this.id,
    required this.name,
    required this.scope,
    required this.pathwayIds,
    required this.assertionCount,
    required this.evidenceId,
    this.baselineFailedPathwayId,
  });

  final String id;
  final String name;
  final String scope;
  final List<String> pathwayIds;
  final int assertionCount;
  final String evidenceId;
  final String? baselineFailedPathwayId;

  int passedPathways(SimulationRunState state) {
    if (state == SimulationRunState.running) return 0;
    if (state == SimulationRunState.verified) return pathwayIds.length;
    return pathwayIds.length - (baselineFailedPathwayId == null ? 0 : 1);
  }

  RegressionOutcome outcomeFor(String pathwayId, SimulationRunState state) {
    if (state == SimulationRunState.running) return RegressionOutcome.running;
    if (state == SimulationRunState.baselineFailed &&
        pathwayId == baselineFailedPathwayId) {
      return RegressionOutcome.failed;
    }
    return RegressionOutcome.passed;
  }
}

class SimulationSnapshot {
  const SimulationSnapshot({
    required this.candidate,
    required this.passedPathways,
    required this.failedPathways,
    required this.passedAssertions,
    required this.totalAssertions,
    required this.provenanceCoverage,
  });

  final String candidate;
  final int passedPathways;
  final int failedPathways;
  final int passedAssertions;
  final int totalAssertions;
  final int provenanceCoverage;
}

const simulationSuites = <SimulationSuite>[
  SimulationSuite(
    id: 'ADULT-CORE',
    name: 'Adult core pathways',
    scope: 'Standard and conservation branches',
    pathwayIds: ['ADU-01', 'ADU-02', 'ADU-03', 'ADU-04'],
    assertionCount: 16,
    evidenceId: 'SRC-002',
  ),
  SimulationSuite(
    id: 'OVERRIDE',
    name: 'Documented overrides',
    scope: 'Exception precedence and handoff',
    pathwayIds: ['OVR-01', 'OVR-02', 'OVR-03', 'OVR-04'],
    assertionCount: 16,
    evidenceId: 'SRC-004',
  ),
  SimulationSuite(
    id: 'CRITICAL',
    name: 'Critical-care handoff',
    scope: 'Order set to device parity',
    pathwayIds: ['CRT-01', 'CRT-02', 'CRT-03', 'CRT-04'],
    assertionCount: 16,
    evidenceId: 'SRC-005',
  ),
  SimulationSuite(
    id: 'PED-07',
    name: 'Pediatric exception',
    scope: 'Population-scoped carrier branch',
    pathwayIds: ['PED-07-01', 'PED-07-02', 'PED-07-03', 'PATH-PED-07-04'],
    assertionCount: 16,
    evidenceId: 'SRC-006',
    baselineFailedPathwayId: 'PATH-PED-07-04',
  ),
  SimulationSuite(
    id: 'PARITY',
    name: 'Projection parity',
    scope: 'Six synchronized artifacts',
    pathwayIds: ['PAR-01', 'PAR-02', 'PAR-03', 'PAR-04'],
    assertionCount: 16,
    evidenceId: 'SRC-008',
  ),
  SimulationSuite(
    id: 'ROLLBACK',
    name: 'Rollback integrity',
    scope: 'Exact sealed-state restoration',
    pathwayIds: ['RBK-01', 'RBK-02', 'RBK-03', 'RBK-04'],
    assertionCount: 16,
    evidenceId: 'SRC-009',
  ),
];

SimulationSuite simulationSuiteById(String id) => simulationSuites.firstWhere(
  (suite) => suite.id == id,
  orElse: () => simulationSuites[3],
);

SimulationSnapshot simulationSnapshot(SimulationRunState state) {
  return switch (state) {
    SimulationRunState.baselineFailed => const SimulationSnapshot(
      candidate: 'v0.7',
      passedPathways: 23,
      failedPathways: 1,
      passedAssertions: 95,
      totalAssertions: 96,
      provenanceCoverage: 99,
    ),
    SimulationRunState.running => const SimulationSnapshot(
      candidate: 'v0.8',
      passedPathways: 0,
      failedPathways: 0,
      passedAssertions: 0,
      totalAssertions: 96,
      provenanceCoverage: 100,
    ),
    SimulationRunState.verified => const SimulationSnapshot(
      candidate: 'v0.8',
      passedPathways: 24,
      failedPathways: 0,
      passedAssertions: 96,
      totalAssertions: 96,
      provenanceCoverage: 100,
    ),
  };
}
