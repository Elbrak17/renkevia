import 'package:flutter/material.dart';
import 'package:renkevia/src/core/theme/renkevia_theme.dart';
import 'package:renkevia/src/features/simulation_lab/simulation_fixture.dart';
import 'package:renkevia/src/features/workspace/demo_run_controller.dart';
import 'package:renkevia/src/shared/status_pill.dart';

class SimulationLabPage extends StatelessWidget {
  const SimulationLabPage({super.key, required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.simulationRunState;
    final snapshot = simulationSnapshot(state);
    final compact = MediaQuery.sizeOf(context).width < 600;
    return ColoredBox(
      color: RenkeviaColors.canvas,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          compact ? 12 : 22,
          compact ? 16 : 22,
          compact ? 12 : 22,
          30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SimulationHeader(controller: controller, snapshot: snapshot),
            const SizedBox(height: 16),
            _RunTrace(controller: controller),
            const SizedBox(height: 16),
            _SimulationWorkspace(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _SimulationHeader extends StatelessWidget {
  const _SimulationHeader({required this.controller, required this.snapshot});

  final DemoRunController controller;
  final SimulationSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final state = controller.simulationRunState;
    final running = state == SimulationRunState.running;
    final verified = state == SimulationRunState.verified;
    final patchReady = controller.patchRevised;
    final status = switch (state) {
      SimulationRunState.baselineFailed when patchReady => (
        'v0.8 • READY TO RETEST',
        const Color(0xFF9A6918),
        RenkeviaColors.amberWash,
      ),
      SimulationRunState.baselineFailed => (
        'BASELINE • 1 FAILURE',
        RenkeviaColors.danger,
        RenkeviaColors.dangerWash,
      ),
      SimulationRunState.running => (
        'DETERMINISTIC REPLAY',
        const Color(0xFF9A6918),
        RenkeviaColors.amberWash,
      ),
      SimulationRunState.verified => (
        '24 / 24 VERIFIED',
        RenkeviaColors.success,
        RenkeviaColors.successWash,
      ),
    };

    final action = Semantics(
      button: true,
      label: !patchReady
          ? 'Open Patch Studio and compile candidate version 0.8'
          : (verified
                ? 'All deterministic patient pathways verified'
                : 'Run deterministic patient pathways for candidate version 0.8'),
      child: FilledButton.icon(
        key: const Key('simulation-primary-button'),
        onPressed: !patchReady
            ? () => controller.selectSection(WorkspaceSection.patchStudio)
            : (state == SimulationRunState.baselineFailed
                  ? controller.runRevisedSimulation
                  : null),
        icon: running
            ? const SizedBox.square(
                dimension: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                verified
                    ? Icons.verified_rounded
                    : (patchReady
                          ? Icons.play_arrow_rounded
                          : Icons.arrow_back_rounded),
                size: 18,
              ),
        label: Text(
          !patchReady
              ? 'Compile Patch v0.8 first'
              : switch (state) {
                  SimulationRunState.baselineFailed => 'Run revised candidate',
                  SimulationRunState.running => 'Executing 96 assertions…',
                  SimulationRunState.verified => 'Verified • audits next',
                },
        ),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;
        final summary = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 7,
              children: [
                Text(
                  'SIMULATION LAB / 03',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                StatusPill(
                  label: status.$1,
                  icon: verified
                      ? Icons.verified_outlined
                      : (running
                            ? Icons.sync_rounded
                            : Icons.warning_amber_rounded),
                  foreground: status.$2,
                  background: status.$3,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Patient pathways become executable assertions.',
              style: compact
                  ? Theme.of(context).textTheme.headlineMedium
                  : Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 7),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 790),
              child: Text(
                verified
                    ? 'The same sealed fixture that rejected v0.7 now accepts v0.8. The original counterexample remains inspectable; specialist review is still required.'
                    : 'A reproducible pediatric counterexample rejected v0.7. Retest the synchronized v0.8 candidate against the same 24 pathways and 96 assertions.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (compact) ...[
              summary,
              const SizedBox(height: 14),
              action,
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: summary),
                  const SizedBox(width: 20),
                  action,
                ],
              ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Metric(
                  label: 'PATHWAYS',
                  value: running ? '— / 24' : '${snapshot.passedPathways} / 24',
                  detail: verified ? 'all representative' : '1 counterexample',
                  icon: Icons.route_outlined,
                  danger: !verified && !running,
                  success: verified,
                ),
                _Metric(
                  label: 'ASSERTIONS',
                  value: running
                      ? '0 / 96'
                      : '${snapshot.passedAssertions} / ${snapshot.totalAssertions}',
                  detail: running ? 'deterministic queue' : 'schema-bound',
                  icon: Icons.rule_folder_outlined,
                  danger: !verified && !running,
                  success: verified,
                ),
                _Metric(
                  label: 'PROVENANCE',
                  value: '${snapshot.provenanceCoverage}%',
                  detail: verified ? 'every assertion linked' : '1 broken edge',
                  icon: Icons.link_rounded,
                  danger: !verified && !running,
                  success: verified,
                ),
                _Metric(
                  label: 'APPROVAL',
                  value: 'LOCKED',
                  detail: verified ? '4 audits required' : 'regression blocker',
                  icon: Icons.lock_clock_outlined,
                  warning: verified || running,
                  danger: !verified && !running,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    this.danger = false,
    this.success = false,
    this.warning = false,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final bool danger;
  final bool success;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final accent = danger
        ? RenkeviaColors.danger
        : (success
              ? RenkeviaColors.success
              : (warning ? const Color(0xFF9A6918) : RenkeviaColors.cyanDark));
    final wash = danger
        ? RenkeviaColors.dangerWash
        : (success
              ? RenkeviaColors.successWash
              : (warning ? RenkeviaColors.amberWash : RenkeviaColors.surface));
    return Container(
      width: 212,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: wash,
        border: Border.all(color: accent.withValues(alpha: 0.28)),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 18),
          const SizedBox(width: 10),
          Text(
            value,
            style: TextStyle(
              color: danger ? RenkeviaColors.danger : RenkeviaColors.ink,
              fontSize: value.length > 7 ? 15 : 20,
              height: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: accent,
                    fontSize: 8,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RunTrace extends StatelessWidget {
  const _RunTrace({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.simulationRunState;
    final running = state == SimulationRunState.running;
    final verified = state == SimulationRunState.verified;
    final revised = controller.patchRevised;
    final steps = <_RunStepData>[
      const _RunStepData(
        icon: Icons.lock_outline_rounded,
        title: 'Fixture sealed',
        detail: 'SIM-24-0717 • hash 8D4A',
        state: _RunStepState.done,
      ),
      _RunStepData(
        icon: Icons.schema_outlined,
        title: revised ? 'Candidate v0.8' : 'Candidate v0.7',
        detail: revised ? 'six projections synchronized' : 'PED-07 edge absent',
        state: revised ? _RunStepState.done : _RunStepState.failed,
      ),
      _RunStepData(
        icon: Icons.account_tree_outlined,
        title: 'Deterministic executor',
        detail: running
            ? 'evaluating 96 assertions'
            : (verified ? '24 pathways verified' : '23 pass • 1 fail'),
        state: running
            ? _RunStepState.active
            : (verified ? _RunStepState.done : _RunStepState.failed),
      ),
      _RunStepData(
        icon: Icons.lock_clock_outlined,
        title: 'Approval gate',
        detail: verified ? 'specialist audits pending' : 'regression blocking',
        state: _RunStepState.waiting,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: RenkeviaColors.graphite,
          borderRadius: BorderRadius.circular(11),
        ),
        child: constraints.maxWidth < 680
            ? Column(
                children: [
                  for (var index = 0; index < steps.length; index++) ...[
                    _RunStep(data: steps[index]),
                    if (index < steps.length - 1)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 1,
                          height: 10,
                          margin: const EdgeInsets.only(left: 14),
                          color: _runStepColor(
                            steps[index + 1].state,
                          ).withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ],
              )
            : Row(
                children: [
                  for (var index = 0; index < steps.length; index++) ...[
                    Expanded(child: _RunStep(data: steps[index])),
                    if (index < steps.length - 1)
                      Container(
                        width: 32,
                        height: 1,
                        color: _runStepColor(
                          steps[index + 1].state,
                        ).withValues(alpha: 0.7),
                      ),
                  ],
                ],
              ),
      ),
    );
  }
}

enum _RunStepState { done, active, failed, waiting }

class _RunStepData {
  const _RunStepData({
    required this.icon,
    required this.title,
    required this.detail,
    required this.state,
  });

  final IconData icon;
  final String title;
  final String detail;
  final _RunStepState state;
}

Color _runStepColor(_RunStepState state) => switch (state) {
  _RunStepState.done => RenkeviaColors.cyan,
  _RunStepState.active => RenkeviaColors.amber,
  _RunStepState.failed => RenkeviaColors.danger,
  _RunStepState.waiting => const Color(0xFF71817F),
};

class _RunStep extends StatelessWidget {
  const _RunStep({required this.data});

  final _RunStepData data;

  @override
  Widget build(BuildContext context) {
    final accent = _runStepColor(data.state);
    return Row(
      children: [
        Container(
          width: 29,
          height: 29,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.13),
            shape: BoxShape.circle,
            border: Border.all(color: accent),
          ),
          child: Icon(data.icon, color: accent, size: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF93A5A3), fontSize: 8.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SimulationWorkspace extends StatelessWidget {
  const _SimulationWorkspace({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final suiteRail = _SuiteRail(controller: controller);
        final matrix = _RegressionMatrix(controller: controller);
        final inspector = _CounterexampleInspector(controller: controller);
        if (constraints.maxWidth < 720) {
          return Column(
            children: [
              suiteRail,
              const SizedBox(height: 12),
              matrix,
              const SizedBox(height: 12),
              inspector,
            ],
          );
        }
        if (constraints.maxWidth >= 1110) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 238, child: suiteRail),
              const SizedBox(width: 12),
              Expanded(child: matrix),
              const SizedBox(width: 12),
              SizedBox(width: 320, child: inspector),
            ],
          );
        }
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 238, child: suiteRail),
                const SizedBox(width: 12),
                Expanded(child: matrix),
              ],
            ),
            const SizedBox(height: 12),
            inspector,
          ],
        );
      },
    );
  }
}

class _SuiteRail extends StatelessWidget {
  const _SuiteRail({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.simulationRunState;
    return Container(
      decoration: BoxDecoration(
        color: RenkeviaColors.surface,
        border: Border.all(color: RenkeviaColors.hairline),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _PanelHeading(
            eyebrow: 'SEALED SUITE',
            title: 'Patient cohorts',
            trailing: '6 suites',
          ),
          const Divider(height: 1),
          for (final suite in simulationSuites)
            _SuiteTile(
              suite: suite,
              state: state,
              selected: controller.selectedSimulationSuiteId == suite.id,
              onTap: () => controller.selectSimulationSuite(suite.id),
            ),
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3EC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: RenkeviaColors.hairline),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.fingerprint_rounded,
                  color: RenkeviaColors.violet,
                  size: 15,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Fixture hash is pinned. Candidate changes; test inputs do not.',
                    style: TextStyle(
                      color: RenkeviaColors.inkMuted,
                      fontSize: 9.5,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuiteTile extends StatelessWidget {
  const _SuiteTile({
    required this.suite,
    required this.state,
    required this.selected,
    required this.onTap,
  });

  final SimulationSuite suite;
  final SimulationRunState state;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final running = state == SimulationRunState.running;
    final passed = suite.passedPathways(state);
    final failed = !running && passed < suite.pathwayIds.length;
    final accent = running
        ? RenkeviaColors.amber
        : (failed ? RenkeviaColors.danger : RenkeviaColors.success);
    return Material(
      color: selected ? RenkeviaColors.cyanWash : Colors.transparent,
      child: InkWell(
        key: Key('suite-${suite.id}'),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: const BorderSide(color: RenkeviaColors.hairline),
              left: BorderSide(
                color: selected ? RenkeviaColors.cyanDark : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 23,
                height: 23,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  running
                      ? Icons.more_horiz_rounded
                      : (failed ? Icons.close_rounded : Icons.check_rounded),
                  color: accent,
                  size: 14,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suite.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: RenkeviaColors.ink,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      running
                          ? 'queued'
                          : '$passed / ${suite.pathwayIds.length} pathways',
                      style: TextStyle(
                        color: accent,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegressionMatrix extends StatelessWidget {
  const _RegressionMatrix({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.simulationRunState;
    final verified = state == SimulationRunState.verified;
    return Container(
      decoration: BoxDecoration(
        color: RenkeviaColors.surface,
        border: Border.all(color: RenkeviaColors.hairline),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PanelHeading(
            eyebrow: 'REGRESSION MATRIX',
            title: 'Same fixture. New candidate.',
            trailing: verified ? 'v0.7 → v0.8' : 'baseline v0.7',
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 14, 15, 10),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final trailing = Text(
                  '4 PATHWAYS / SUITE',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: RenkeviaColors.inkMuted,
                    fontSize: 8,
                  ),
                );
                if (constraints.maxWidth < 520) {
                  return Wrap(
                    spacing: 13,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const _LegendDot(
                        color: RenkeviaColors.success,
                        label: 'assertions pass',
                      ),
                      const _LegendDot(
                        color: RenkeviaColors.danger,
                        label: 'counterexample',
                      ),
                      trailing,
                    ],
                  );
                }
                return Row(
                  children: [
                    const _LegendDot(
                      color: RenkeviaColors.success,
                      label: 'assertions pass',
                    ),
                    const SizedBox(width: 13),
                    const _LegendDot(
                      color: RenkeviaColors.danger,
                      label: 'counterexample',
                    ),
                    const Spacer(),
                    trailing,
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            child: Column(
              children: [
                for (final suite in simulationSuites)
                  _MatrixRow(
                    suite: suite,
                    state: state,
                    selected: controller.selectedSimulationSuiteId == suite.id,
                    onTap: () => controller.selectSimulationSuite(suite.id),
                  ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: verified
                  ? RenkeviaColors.successWash
                  : RenkeviaColors.dangerWash,
              border: Border.all(
                color: verified
                    ? RenkeviaColors.success.withValues(alpha: 0.3)
                    : RenkeviaColors.danger.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  verified
                      ? Icons.verified_outlined
                      : Icons.report_gmailerrorred_outlined,
                  color: verified
                      ? RenkeviaColors.success
                      : RenkeviaColors.danger,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        verified
                            ? 'REGRESSION GATE PASSED'
                            : 'REGRESSION GATE BLOCKED',
                        style: TextStyle(
                          color: verified
                              ? RenkeviaColors.success
                              : RenkeviaColors.danger,
                          fontSize: 9,
                          letterSpacing: 0.7,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        verified
                            ? 'v0.8 resolves PATH-PED-07-04 without changing the other 23 outcomes.'
                            : 'PATH-PED-07-04 is stable, reproducible, and linked to one missing Patch IR edge.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _MatrixRow extends StatelessWidget {
  const _MatrixRow({
    required this.suite,
    required this.state,
    required this.selected,
    required this.onTap,
  });

  final SimulationSuite suite;
  final SimulationRunState state;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF2F8F6) : const Color(0xFFF7F6F1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? RenkeviaColors.cyan : RenkeviaColors.hairline,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suite.id,
                    style: const TextStyle(
                      color: RenkeviaColors.ink,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    suite.scope,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: RenkeviaColors.inkMuted,
                      fontSize: 8.5,
                    ),
                  ),
                ],
              ),
            ),
            for (final pathwayId in suite.pathwayIds) ...[
              const SizedBox(width: 6),
              _OutcomeCell(
                pathwayId: pathwayId,
                outcome: suite.outcomeFor(pathwayId, state),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OutcomeCell extends StatelessWidget {
  const _OutcomeCell({required this.pathwayId, required this.outcome});

  final String pathwayId;
  final RegressionOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final color = switch (outcome) {
      RegressionOutcome.passed => RenkeviaColors.success,
      RegressionOutcome.failed => RenkeviaColors.danger,
      RegressionOutcome.running => RenkeviaColors.amber,
    };
    final icon = switch (outcome) {
      RegressionOutcome.passed => Icons.check_rounded,
      RegressionOutcome.failed => Icons.close_rounded,
      RegressionOutcome.running => Icons.more_horiz_rounded,
    };
    return Tooltip(
      message: '$pathwayId • ${outcome.name}',
      child: AnimatedContainer(
        key: Key('outcome-$pathwayId'),
        duration: const Duration(milliseconds: 240),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.13),
          border: Border.all(color: color.withValues(alpha: 0.62)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: color, size: 14),
      ),
    );
  }
}

class _CounterexampleInspector extends StatelessWidget {
  const _CounterexampleInspector({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.simulationRunState;
    final verified = state == SimulationRunState.verified;
    final running = state == SimulationRunState.running;
    final suite = simulationSuiteById(controller.selectedSimulationSuiteId);
    final isPediatric = suite.id == 'PED-07';
    return Container(
      decoration: BoxDecoration(
        color: RenkeviaColors.surface,
        border: Border.all(color: RenkeviaColors.hairline),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PanelHeading(
            eyebrow: isPediatric ? 'COUNTEREXAMPLE TRACE' : 'PATHWAY PROOF',
            title: isPediatric ? 'PATH-PED-07-04' : suite.id,
            trailing: running
                ? 'RUNNING'
                : (isPediatric ? (verified ? 'RESOLVED' : 'BLOCKER') : 'PASS'),
            danger: isPediatric && !verified && !running,
            success: verified || !isPediatric,
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: isPediatric
                ? _PediatricProof(state: state)
                : _PassingProof(suite: suite),
          ),
        ],
      ),
    );
  }
}

class _PediatricProof extends StatelessWidget {
  const _PediatricProof({required this.state});

  final SimulationRunState state;

  @override
  Widget build(BuildContext context) {
    final verified = state == SimulationRunState.verified;
    final running = state == SimulationRunState.running;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AssertionBlock(
          label: 'ASSERT-SCOPE-12',
          title: 'Population exception reaches every projection',
          detail: running
              ? 'Re-evaluating the exact assertion against candidate v0.8.'
              : (verified
                    ? 'PASS • MUT-02 now terminates in all six version-matched artifacts.'
                    : 'FAIL • The order-set branch falls through to the adult default in v0.7.'),
          color: running
              ? RenkeviaColors.amber
              : (verified ? RenkeviaColors.success : RenkeviaColors.danger),
        ),
        const SizedBox(height: 12),
        Text(
          'CAUSAL TRACE',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 8),
        ),
        const SizedBox(height: 8),
        const _TraceLine(
          index: '01',
          title: 'population == PEDIATRIC',
          detail: 'synthetic pathway flag',
          state: _ProofState.done,
        ),
        _TraceLine(
          index: '02',
          title: verified ? 'MUT-02 edge found' : 'MUT-02 edge missing',
          detail: verified ? 'Patch IR v0.8' : 'Patch IR v0.7',
          state: running
              ? _ProofState.running
              : (verified ? _ProofState.done : _ProofState.failed),
        ),
        _TraceLine(
          index: '03',
          title: verified ? '6 / 6 projections match' : 'order-set mismatch',
          detail: verified ? 'atomic compiler pass' : 'EHR-OS-014',
          state: running
              ? _ProofState.waiting
              : (verified ? _ProofState.done : _ProofState.failed),
          last: true,
        ),
        const SizedBox(height: 12),
        _SourceRegion(verified: verified),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: RenkeviaColors.graphite,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PATCH IR DELTA',
                style: TextStyle(
                  color: Color(0xFF91A7A4),
                  fontSize: 8,
                  letterSpacing: 0.7,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                verified
                    ? '+ exception PED-07 → MUT-02\n+ source SRC-006#T3:C7\n+ projected 6 / 6'
                    : '- exception PED-07 → absent\n! assertion ASSERT-SCOPE-12\n! approval gate → blocked',
                style: TextStyle(
                  color: verified
                      ? const Color(0xFF77D1AA)
                      : const Color(0xFFFF9D91),
                  fontFamily: 'RenkeviaMono',
                  fontSize: 9,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(
              Icons.lock_clock_outlined,
              color: RenkeviaColors.amber,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                verified
                    ? 'APPROVAL REMAINS LOCKED • 4 specialist audits pending'
                    : 'APPROVAL REMAINS LOCKED • reproducible regression',
                style: const TextStyle(
                  color: Color(0xFF9A6918),
                  fontSize: 8.5,
                  letterSpacing: 0.35,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PassingProof extends StatelessWidget {
  const _PassingProof({required this.suite});

  final SimulationSuite suite;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AssertionBlock(
          label: '${suite.id}-ASSERTIONS',
          title: '${suite.assertionCount} deterministic assertions',
          detail: 'PASS • All four pathways match the sealed answer key.',
          color: RenkeviaColors.success,
        ),
        const SizedBox(height: 14),
        const _TraceLine(
          index: '01',
          title: 'Starting state loaded',
          detail: 'synthetic fixture only',
          state: _ProofState.done,
        ),
        const _TraceLine(
          index: '02',
          title: 'Artifact edges evaluated',
          detail: 'deterministic projection graph',
          state: _ProofState.done,
        ),
        const _TraceLine(
          index: '03',
          title: 'Answer key matched',
          detail: 'no hidden model judgment',
          state: _ProofState.done,
          last: true,
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: RenkeviaColors.successWash,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Evidence ${suite.evidenceId} is bound to this suite. Inputs, expected outcomes, and logs are exportable.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _AssertionBlock extends StatelessWidget {
  const _AssertionBlock({
    required this.label,
    required this.title,
    required this.detail,
    required this.color,
  });

  final String label;
  final String title;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.28)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 8,
              letterSpacing: 0.65,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: RenkeviaColors.ink,
              fontSize: 11,
              height: 1.25,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(detail, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

enum _ProofState { done, running, failed, waiting }

class _TraceLine extends StatelessWidget {
  const _TraceLine({
    required this.index,
    required this.title,
    required this.detail,
    required this.state,
    this.last = false,
  });

  final String index;
  final String title;
  final String detail;
  final _ProofState state;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _ProofState.done => RenkeviaColors.success,
      _ProofState.running => RenkeviaColors.amber,
      _ProofState.failed => RenkeviaColors.danger,
      _ProofState.waiting => RenkeviaColors.inkMuted,
    };
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 25,
            child: Column(
              children: [
                Container(
                  width: 21,
                  height: 21,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    index,
                    style: TextStyle(
                      color: color,
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(width: 1, color: RenkeviaColors.hairline),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: RenkeviaColors.ink,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: const TextStyle(
                      color: RenkeviaColors.inkMuted,
                      fontSize: 8.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceRegion extends StatelessWidget {
  const _SourceRegion({required this.verified});

  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F1E7),
        border: Border.all(color: RenkeviaColors.hairline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.image_outlined,
                size: 14,
                color: RenkeviaColors.violet,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'SRC-006 • archived table scan',
                  style: TextStyle(
                    color: RenkeviaColors.ink,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'T3:C7',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: RenkeviaColors.violet,
                  fontSize: 7.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Container(
            height: 46,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                for (var column = 0; column < 4; column++) ...[
                  Expanded(
                    child: Container(
                      color: column == 2
                          ? (verified
                                ? RenkeviaColors.successWash
                                : RenkeviaColors.amberWash)
                          : const Color(0xFFE9E7E0),
                    ),
                  ),
                  if (column < 3) const SizedBox(width: 4),
                ],
              ],
            ),
          ),
          const SizedBox(height: 7),
          Text(
            verified
                ? 'Region linked to MUT-02 and all six projections.'
                : 'Region proves an exception absent from candidate v0.7.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 8.5),
          ),
        ],
      ),
    );
  }
}

class _PanelHeading extends StatelessWidget {
  const _PanelHeading({
    required this.eyebrow,
    required this.title,
    required this.trailing,
    this.danger = false,
    this.success = false,
  });

  final String eyebrow;
  final String title;
  final String trailing;
  final bool danger;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final accent = danger
        ? RenkeviaColors.danger
        : (success ? RenkeviaColors.success : RenkeviaColors.cyanDark);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 11),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: accent, fontSize: 8),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            trailing,
            style: TextStyle(
              color: accent,
              fontSize: 8,
              letterSpacing: 0.45,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
