import 'package:flutter_test/flutter_test.dart';
import 'package:renkevia/src/features/simulation_lab/simulation_fixture.dart';

void main() {
  test('sealed simulation fixture owns 24 pathways and 96 assertions', () {
    final pathways = simulationSuites.expand((suite) => suite.pathwayIds);
    final assertions = simulationSuites.fold<int>(
      0,
      (total, suite) => total + suite.assertionCount,
    );

    expect(pathways.length, 24);
    expect(pathways.toSet().length, 24);
    expect(assertions, 96);
  });

  test(
    'baseline has one stable failure and revision changes only its outcome',
    () {
      final baselineOutcomes = <String, RegressionOutcome>{
        for (final suite in simulationSuites)
          for (final pathwayId in suite.pathwayIds)
            pathwayId: suite.outcomeFor(
              pathwayId,
              SimulationRunState.baselineFailed,
            ),
      };
      final verifiedOutcomes = <String, RegressionOutcome>{
        for (final suite in simulationSuites)
          for (final pathwayId in suite.pathwayIds)
            pathwayId: suite.outcomeFor(pathwayId, SimulationRunState.verified),
      };

      expect(
        baselineOutcomes.entries
            .where((entry) => entry.value == RegressionOutcome.failed)
            .map((entry) => entry.key),
        ['PATH-PED-07-04'],
      );
      expect(
        verifiedOutcomes.values.every(
          (outcome) => outcome == RegressionOutcome.passed,
        ),
        isTrue,
      );
      expect(
        baselineOutcomes.entries
            .where((entry) => entry.value != verifiedOutcomes[entry.key])
            .map((entry) => entry.key),
        ['PATH-PED-07-04'],
      );
    },
  );
}
