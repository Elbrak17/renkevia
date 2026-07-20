import 'package:flutter/material.dart';
import 'package:renkevia/src/core/theme/renkevia_theme.dart';
import 'package:renkevia/src/features/response_room/widgets/dependency_graph.dart';
import 'package:renkevia/src/features/workspace/demo_run_controller.dart';
import 'package:renkevia/src/shared/responsive_metric_width.dart';
import 'package:renkevia/src/shared/status_pill.dart';

class ResponseRoomPage extends StatelessWidget {
  const ResponseRoomPage({super.key, required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
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
            _IncidentHeader(controller: controller),
            const SizedBox(height: 16),
            _RunStages(state: controller.compileState),
            const SizedBox(height: 16),
            _Workspace(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _IncidentHeader extends StatelessWidget {
  const _IncidentHeader({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 680;
        final incident = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 7,
              children: [
                Text(
                  'RESPONSE ROOM / 01',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const StatusPill(
                  label: 'SEV-1 OPERATIONAL',
                  icon: Icons.priority_high_rounded,
                  foreground: RenkeviaColors.danger,
                  background: RenkeviaColors.dangerWash,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Critical IV carrier shortage',
              style: compact
                  ? Theme.of(context).textTheme.headlineMedium
                  : Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 7),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Text(
                'Compile one institution-wide response from a contradictory synthetic corpus—before any artifact can drift alone.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (compact) ...[
              incident,
              const SizedBox(height: 14),
              _CompileButton(controller: controller),
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: incident),
                  const SizedBox(width: 20),
                  _CompileButton(controller: controller),
                ],
              ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                const _Metric(
                  label: 'CORPUS',
                  value: '12',
                  detail: 'mixed artifacts',
                  icon: Icons.folder_copy_outlined,
                ),
                const _Metric(
                  label: 'BLAST RADIUS',
                  value: '7',
                  detail: 'linked systems',
                  icon: Icons.hub_outlined,
                ),
                const _Metric(
                  label: 'PATIENT SUITES',
                  value: '24',
                  detail: 'synthetic paths',
                  icon: Icons.fact_check_outlined,
                ),
                _Metric(
                  label: 'BLOCKERS',
                  value: controller.pediatricBlockerRevealed ? '1' : '—',
                  detail: controller.pediatricBlockerRevealed
                      ? 'critical exception'
                      : 'mapping pending',
                  icon: controller.pediatricBlockerRevealed
                      ? Icons.report_gmailerrorred_outlined
                      : Icons.hourglass_top_rounded,
                  danger: controller.pediatricBlockerRevealed,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _CompileButton extends StatelessWidget {
  const _CompileButton({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.compileState;
    return Semantics(
      button: true,
      label: state == CompileState.blocked
          ? 'Reset the synthetic compilation'
          : 'Run deterministic fixture compilation',
      child: FilledButton.icon(
        key: const Key('compile-fixture-button'),
        onPressed: state == CompileState.mapping
            ? null
            : controller.compileFixture,
        icon: state == CompileState.mapping
            ? const SizedBox.square(
                dimension: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                state == CompileState.blocked
                    ? Icons.restart_alt_rounded
                    : Icons.play_arrow_rounded,
                size: 18,
              ),
        label: Text(switch (state) {
          CompileState.ready => 'Compile fixture',
          CompileState.mapping => 'Mapping 12 artifacts…',
          CompileState.blocked => 'Reset fixture',
        }),
      ),
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
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final foreground = danger ? RenkeviaColors.danger : RenkeviaColors.ink;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final metricWidth = responsiveMetricWidth(
      viewportWidth,
      desktopWidth: 198,
    );
    return Container(
      width: metricWidth,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: danger ? RenkeviaColors.dangerWash : RenkeviaColors.surface,
        border: Border.all(
          color: danger ? const Color(0xFFEBC0B9) : RenkeviaColors.hairline,
        ),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: danger ? RenkeviaColors.danger : RenkeviaColors.cyanDark,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: TextStyle(
              color: foreground,
              fontSize: 20,
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
                    color: danger
                        ? RenkeviaColors.danger
                        : RenkeviaColors.inkMuted,
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

class _RunStages extends StatelessWidget {
  const _RunStages({required this.state});

  final CompileState state;

  @override
  Widget build(BuildContext context) {
    final activeIndex = switch (state) {
      CompileState.ready => 0,
      CompileState.mapping => 1,
      CompileState.blocked => 2,
    };
    const stages = [
      ('01', 'Ingest', '12 artifacts sealed'),
      ('02', 'Map', 'Evidence-linked graph'),
      ('03', 'Challenge', 'Population exceptions'),
      ('04', 'Compile', 'Patch IR candidate'),
      ('05', 'Verify', 'Patient regressions'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final vertical = constraints.maxWidth < 680;
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 13, 16, 12),
          decoration: BoxDecoration(
            color: RenkeviaColors.graphite,
            borderRadius: BorderRadius.circular(11),
          ),
          child: vertical
              ? Column(
                  children: [
                    for (var index = 0; index < stages.length; index++) ...[
                      _Stage(
                        number: stages[index].$1,
                        title: stages[index].$2,
                        detail: stages[index].$3,
                        completed: index < activeIndex,
                        active: index == activeIndex,
                        blocked:
                            state == CompileState.blocked &&
                            index == activeIndex,
                      ),
                      if (index < stages.length - 1)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 1,
                            height: 10,
                            margin: const EdgeInsets.only(left: 14),
                            color: index < activeIndex
                                ? RenkeviaColors.cyan
                                : RenkeviaColors.hairlineDark,
                          ),
                        ),
                    ],
                  ],
                )
              : Row(
                  children: [
                    for (var index = 0; index < stages.length; index++) ...[
                      Expanded(
                        child: _Stage(
                          number: stages[index].$1,
                          title: stages[index].$2,
                          detail: stages[index].$3,
                          completed: index < activeIndex,
                          active: index == activeIndex,
                          blocked:
                              state == CompileState.blocked &&
                              index == activeIndex,
                        ),
                      ),
                      if (index < stages.length - 1)
                        Container(
                          width: 26,
                          height: 1,
                          color: index < activeIndex
                              ? RenkeviaColors.cyan
                              : RenkeviaColors.hairlineDark,
                        ),
                    ],
                  ],
                ),
        );
      },
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage({
    required this.number,
    required this.title,
    required this.detail,
    required this.completed,
    required this.active,
    required this.blocked,
  });

  final String number;
  final String title;
  final String detail;
  final bool completed;
  final bool active;
  final bool blocked;

  @override
  Widget build(BuildContext context) {
    final accent = blocked
        ? RenkeviaColors.danger
        : (active || completed ? RenkeviaColors.cyan : const Color(0xFF71817F));
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: active || completed
                ? accent.withValues(alpha: 0.14)
                : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: accent),
          ),
          child: Center(
            child: completed
                ? Icon(Icons.check_rounded, color: accent, size: 14)
                : Text(
                    number,
                    style: TextStyle(
                      color: accent,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: active || completed
                      ? Colors.white
                      : const Color(0xFF9AA8A6),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF71817F), fontSize: 8),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Workspace extends StatelessWidget {
  const _Workspace({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            children: [
              SizedBox(
                height: 330,
                child: _EvidenceRail(controller: controller),
              ),
              const SizedBox(height: 12),
              SizedBox(height: 540, child: _GraphPanel(controller: controller)),
              const SizedBox(height: 12),
              SizedBox(
                height: 360,
                child: _EvidenceInspector(controller: controller),
              ),
            ],
          );
        }
        final showInspectorBeside = constraints.maxWidth >= 1060;
        final core = SizedBox(
          height: 570,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 238,
                child: _EvidenceRail(controller: controller),
              ),
              const SizedBox(width: 12),
              Expanded(child: _GraphPanel(controller: controller)),
              if (showInspectorBeside) ...[
                const SizedBox(width: 12),
                SizedBox(
                  width: 286,
                  child: _EvidenceInspector(controller: controller),
                ),
              ],
            ],
          ),
        );
        if (showInspectorBeside) return core;
        return Column(
          children: [
            core,
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: _EvidenceInspector(controller: controller),
            ),
          ],
        );
      },
    );
  }
}

class _GraphPanel extends StatelessWidget {
  const _GraphPanel({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(15, 13, 12, 11),
            child: _GraphHeader(),
          ),
          const Divider(height: 1),
          Expanded(
            child: DependencyGraph(
              blockerRevealed: controller.pediatricBlockerRevealed,
              onEvidenceRequested: controller.selectEvidence,
            ),
          ),
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 13),
            decoration: const BoxDecoration(
              color: Color(0xFFF6F5EF),
              border: Border(top: BorderSide(color: RenkeviaColors.hairline)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: RenkeviaColors.inkMuted,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    controller.pediatricBlockerRevealed
                        ? 'PED-07 contradicts the candidate scope. Approval remains locked until the exception is compiled and retested.'
                        : 'Run the fixture compiler to challenge this apparently adult-only change against hidden population dependencies.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
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

class _GraphLegend extends StatelessWidget {
  const _GraphLegend({required this.color, required this.label});

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
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: RenkeviaColors.inkMuted,
            fontSize: 8,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _GraphHeader extends StatelessWidget {
  const _GraphHeader();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showFullLegend = constraints.maxWidth >= 760;
        return Row(
          children: [
            const Icon(
              Icons.hub_outlined,
              size: 17,
              color: RenkeviaColors.cyanDark,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Institutional dependency map',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (!showFullLegend)
                    Text(
                      '7 systems • 11 typed edges',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
            if (showFullLegend) ...[
              Text(
                '7 systems • 11 typed edges',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 14),
              const _GraphLegend(
                color: RenkeviaColors.cyan,
                label: 'Supported',
              ),
              const SizedBox(width: 10),
              const _GraphLegend(
                color: RenkeviaColors.amber,
                label: 'Unresolved',
              ),
              const SizedBox(width: 10),
              const _GraphLegend(
                color: RenkeviaColors.danger,
                label: 'Blocking',
              ),
            ] else
              const StatusPill(
                label: '3 STATES',
                foreground: RenkeviaColors.cyanDark,
                background: RenkeviaColors.cyanWash,
              ),
          ],
        );
      },
    );
  }
}

class _EvidenceRail extends StatelessWidget {
  const _EvidenceRail({required this.controller});

  final DemoRunController controller;

  static const records = [
    _EvidenceRecord(
      'SRC-001',
      'Shortage notice',
      'Memo • 3 pages',
      Icons.campaign_outlined,
      'NEW',
    ),
    _EvidenceRecord(
      'SRC-002',
      'IV carrier policy',
      'PDF • 18 pages',
      Icons.policy_outlined,
      '2026',
    ),
    _EvidenceRecord(
      'SRC-003',
      'Adult order set',
      'Legacy export • XML',
      Icons.account_tree_outlined,
      'v14',
    ),
    _EvidenceRecord(
      'SRC-004',
      'Pump library',
      'Table • CSV',
      Icons.tune_outlined,
      'v9.2',
    ),
    _EvidenceRecord(
      'SRC-005',
      'Pharmacy labels',
      'Scans • 6 images',
      Icons.document_scanner_outlined,
      'OCR',
    ),
    _EvidenceRecord(
      'SRC-006',
      'Pediatric exception',
      'Scanned table • 2019',
      Icons.child_care_outlined,
      'STALE',
    ),
    _EvidenceRecord(
      'SRC-007',
      'Change record 842',
      'Form • 5 pages',
      Icons.history_outlined,
      '2024',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'SEALED CORPUS',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                const SizedBox(width: 7),
                const Icon(
                  Icons.verified_rounded,
                  size: 14,
                  color: RenkeviaColors.success,
                ),
                const SizedBox(width: 4),
                const Text(
                  '12 / 12',
                  style: TextStyle(
                    color: RenkeviaColors.success,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 7),
              itemCount: records.length,
              separatorBuilder: (_, _) => const SizedBox(height: 1),
              itemBuilder: (context, index) {
                final record = records[index];
                final selected = controller.selectedEvidenceId == record.id;
                final critical =
                    controller.pediatricBlockerRevealed &&
                    record.id == 'SRC-006';
                return _EvidenceTile(
                  record: record,
                  selected: selected,
                  critical: critical,
                  onTap: () => controller.selectEvidence(record.id),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF6F5EF),
              border: Border(top: BorderSide(color: RenkeviaColors.hairline)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  size: 15,
                  color: RenkeviaColors.success,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Checksums locked • source regions addressable',
                    style: Theme.of(context).textTheme.bodyMedium,
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

class _EvidenceRecord {
  const _EvidenceRecord(this.id, this.title, this.detail, this.icon, this.tag);

  final String id;
  final String title;
  final String detail;
  final IconData icon;
  final String tag;
}

class _EvidenceTile extends StatelessWidget {
  const _EvidenceTile({
    required this.record,
    required this.selected,
    required this.critical,
    required this.onTap,
  });

  final _EvidenceRecord record;
  final bool selected;
  final bool critical;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: '${record.title}, ${record.detail}',
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 7),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
          decoration: BoxDecoration(
            color: critical
                ? RenkeviaColors.dangerWash
                : (selected ? RenkeviaColors.cyanWash : Colors.transparent),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: critical
                  ? const Color(0xFFE9B7B0)
                  : (selected ? const Color(0xFFB8DFD9) : Colors.transparent),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: critical ? Colors.white : RenkeviaColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: RenkeviaColors.hairline),
                ),
                child: Icon(
                  record.icon,
                  size: 15,
                  color: critical
                      ? RenkeviaColors.danger
                      : RenkeviaColors.cyanDark,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: critical
                            ? RenkeviaColors.danger
                            : RenkeviaColors.ink,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      record.detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 9),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Text(
                record.tag,
                style: TextStyle(
                  color: critical
                      ? RenkeviaColors.danger
                      : RenkeviaColors.inkMuted,
                  fontSize: 7,
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EvidenceInspector extends StatelessWidget {
  const _EvidenceInspector({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    final pediatric = controller.selectedEvidenceId == 'SRC-006';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 12, 11),
            child: Row(
              children: [
                Text(
                  'EVIDENCE INSPECTOR',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const Spacer(),
                const Icon(
                  Icons.open_in_full_rounded,
                  size: 14,
                  color: RenkeviaColors.inkMuted,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: pediatric
                  ? _PediatricEvidence(
                      blocked: controller.pediatricBlockerRevealed,
                    )
                  : const _ShortageEvidence(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortageEvidence extends StatelessWidget {
  const _ShortageEvidence();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StatusPill(
          label: 'SOURCE REGION • P1:R04',
          foreground: RenkeviaColors.cyanDark,
          background: RenkeviaColors.cyanWash,
        ),
        const SizedBox(height: 13),
        Text(
          'Synthetic shortage notice',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 5),
        Text(
          'Received 17 Jul 2026 • 08:42 UTC',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        const _DocumentExcerpt(
          eyebrow: 'EXTRACTED CLAIM',
          text:
              'Primary IV carrier inventory is projected below the institutional response threshold within 48 hours.',
          accent: RenkeviaColors.cyanDark,
        ),
        const SizedBox(height: 15),
        const _InspectorRow(label: 'Checksum', value: '8b77…a91c'),
        const _InspectorRow(label: 'Modality', value: 'Digital PDF'),
        const _InspectorRow(label: 'Linked nodes', value: '7 systems'),
        const _InspectorRow(label: 'Claim status', value: 'Supported'),
        const SizedBox(height: 16),
        const _TrustNote(
          icon: Icons.lock_outline_rounded,
          title: 'Immutable source',
          text:
              'The artifact is sealed. Derived claims retain this exact region and content hash.',
        ),
      ],
    );
  }
}

class _PediatricEvidence extends StatelessWidget {
  const _PediatricEvidence({required this.blocked});

  final bool blocked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatusPill(
          label: blocked
              ? 'BLOCKING REGION • T3:C7'
              : 'UNRESOLVED REGION • T3:C7',
          icon: blocked ? Icons.block_outlined : Icons.warning_amber_rounded,
          foreground: blocked ? RenkeviaColors.danger : const Color(0xFF9A6918),
          background: blocked
              ? RenkeviaColors.dangerWash
              : RenkeviaColors.amberWash,
        ),
        const SizedBox(height: 13),
        Text(
          'Pediatric exception table',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 5),
        Text(
          'Scanned appendix • approved 2019',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 15),
        Container(
          height: 116,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EEE7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: RenkeviaColors.hairline),
          ),
          child: Stack(
            children: [
              Column(
                children: List.generate(
                  5,
                  (index) => Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: const Color(
                              0xFFB9B8B0,
                            ).withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 58,
                right: 7,
                top: 42,
                height: 27,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        (blocked ? RenkeviaColors.danger : RenkeviaColors.amber)
                            .withValues(alpha: 0.18),
                    border: Border.all(
                      color: blocked
                          ? RenkeviaColors.danger
                          : RenkeviaColors.amber,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const Positioned(
                left: 7,
                top: 5,
                child: Text(
                  'OCR PREVIEW • SYNTHETIC',
                  style: TextStyle(
                    color: RenkeviaColors.inkMuted,
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 13),
        _DocumentExcerpt(
          eyebrow: blocked ? 'CONTRADICTING CLAIM' : 'LOW-CONFIDENCE OCR',
          text:
              'PED-07 retains a population-specific carrier exception not represented in the candidate adult order set.',
          accent: blocked ? RenkeviaColors.danger : const Color(0xFF9A6918),
        ),
        const SizedBox(height: 15),
        const _InspectorRow(label: 'Checksum', value: 'c419…72e0'),
        const _InspectorRow(label: 'Modality', value: 'Scanned table'),
        const _InspectorRow(label: 'OCR confidence', value: '0.82 • review'),
        _InspectorRow(
          label: 'Patch impact',
          value: blocked ? 'Approval blocker' : 'Unresolved',
        ),
        const SizedBox(height: 15),
        _TrustNote(
          icon: blocked ? Icons.gpp_bad_outlined : Icons.visibility_outlined,
          title: blocked ? 'Human review required' : 'Visual region retained',
          text: blocked
              ? 'The compiler cannot silently normalize this exception. A reviewer must resolve it before Patch IR can advance.'
              : 'RENKEVIA preserves the image region beside OCR text so reviewers can inspect the original encoding.',
          danger: blocked,
        ),
      ],
    );
  }
}

class _DocumentExcerpt extends StatelessWidget {
  const _DocumentExcerpt({
    required this.eyebrow,
    required this.text,
    required this.accent,
  });

  final String eyebrow;
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 11, 11),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        border: Border(left: BorderSide(color: accent, width: 3)),
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: TextStyle(
              color: accent,
              fontSize: 8,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: RenkeviaColors.ink,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _InspectorRow extends StatelessWidget {
  const _InspectorRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: const TextStyle(
              color: RenkeviaColors.ink,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustNote extends StatelessWidget {
  const _TrustNote({
    required this.icon,
    required this.title,
    required this.text,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String text;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final accent = danger ? RenkeviaColors.danger : RenkeviaColors.cyanDark;
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: danger ? RenkeviaColors.dangerWash : RenkeviaColors.cyanWash,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
