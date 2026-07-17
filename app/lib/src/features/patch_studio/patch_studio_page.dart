import 'package:flutter/material.dart';
import 'package:renkevia/src/core/theme/renkevia_theme.dart';
import 'package:renkevia/src/features/workspace/demo_run_controller.dart';
import 'package:renkevia/src/shared/status_pill.dart';

class PatchStudioPage extends StatelessWidget {
  const PatchStudioPage({super.key, required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: RenkeviaColors.canvas,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PatchHeader(controller: controller),
            const SizedBox(height: 16),
            _CompileTrace(state: controller.patchCompileState),
            const SizedBox(height: 16),
            _PatchWorkspace(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _PatchHeader extends StatelessWidget {
  const _PatchHeader({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    final revised = controller.patchRevised;
    final recompiling =
        controller.patchCompileState == PatchCompileState.recompiling;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'PATCH STUDIO / 02',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(width: 10),
                      StatusPill(
                        label: revised
                            ? 'REVISED • RETEST REQUIRED'
                            : 'CANDIDATE • BLOCKED',
                        icon: revised
                            ? Icons.rule_folder_outlined
                            : Icons.block_outlined,
                        foreground: revised
                            ? const Color(0xFF9A6918)
                            : RenkeviaColors.danger,
                        background: revised
                            ? RenkeviaColors.amberWash
                            : RenkeviaColors.dangerWash,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'One Patch IR. Six synchronized artifacts.',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 7),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 780),
                    child: Text(
                      revised
                          ? 'The pediatric exception changed every affected projection together. The candidate must still survive patient-pathway regressions.'
                          : 'The candidate is internally coherent for adults, but PED-07 proves its scope is incomplete. Fix the source of truth—not six files by hand.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Semantics(
              button: true,
              label: revised
                  ? 'Patch revised; simulation is required next'
                  : 'Recompile every artifact with the pediatric exception',
              child: FilledButton.icon(
                key: const Key('recompile-patch-button'),
                onPressed:
                    controller.patchCompileState == PatchCompileState.blocked
                    ? controller.recompilePatch
                    : null,
                icon: recompiling
                    ? const SizedBox.square(
                        dimension: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        revised
                            ? Icons.check_rounded
                            : Icons.account_tree_outlined,
                        size: 18,
                      ),
                label: Text(switch (controller.patchCompileState) {
                  PatchCompileState.blocked => 'Compile PED-07 exception',
                  PatchCompileState.recompiling => 'Projecting six artifacts…',
                  PatchCompileState.revised => 'Recompiled • verify next',
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PatchMetric(
              label: 'PATCH IR',
              value: revised ? 'v0.8' : 'v0.7',
              detail: revised ? 'revision candidate' : 'blocked candidate',
              icon: Icons.schema_outlined,
            ),
            const _PatchMetric(
              label: 'PROJECTIONS',
              value: '6',
              detail: 'one compiler pass',
              icon: Icons.copy_all_outlined,
            ),
            const _PatchMetric(
              label: 'SOURCE LINKS',
              value: '9',
              detail: 'immutable regions',
              icon: Icons.link_rounded,
            ),
            _PatchMetric(
              label: revised ? 'NEXT GATE' : 'BLOCKERS',
              value: revised ? '24' : '1',
              detail: revised ? 'patient suites' : 'PED-07 exception',
              icon: revised
                  ? Icons.fact_check_outlined
                  : Icons.report_gmailerrorred_outlined,
              danger: !revised,
              warning: revised,
            ),
          ],
        ),
      ],
    );
  }
}

class _PatchMetric extends StatelessWidget {
  const _PatchMetric({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    this.danger = false,
    this.warning = false,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final bool danger;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final accent = danger
        ? RenkeviaColors.danger
        : (warning ? const Color(0xFF9A6918) : RenkeviaColors.cyanDark);
    final wash = danger
        ? RenkeviaColors.dangerWash
        : (warning ? RenkeviaColors.amberWash : RenkeviaColors.surface);
    return Container(
      width: 198,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: wash,
        border: Border.all(
          color: danger
              ? const Color(0xFFEBC0B9)
              : (warning ? const Color(0xFFE9D09E) : RenkeviaColors.hairline),
        ),
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

class _CompileTrace extends StatelessWidget {
  const _CompileTrace({required this.state});

  final PatchCompileState state;

  @override
  Widget build(BuildContext context) {
    final revised = state == PatchCompileState.revised;
    final recompiling = state == PatchCompileState.recompiling;
    final steps = [
      const _TraceStep(
        icon: Icons.source_outlined,
        title: 'Evidence bound',
        detail: '9 source regions',
        state: _TraceState.done,
      ),
      _TraceStep(
        icon: Icons.schema_outlined,
        title: revised ? 'Patch IR v0.8' : 'Patch IR v0.7',
        detail: recompiling ? 'Applying MUT-02' : 'Typed & schema-valid',
        state: recompiling ? _TraceState.active : _TraceState.done,
      ),
      _TraceStep(
        icon: Icons.call_split_outlined,
        title: 'Six projections',
        detail: revised
            ? 'All at revision v0.8'
            : (recompiling ? 'Atomic projection pass' : 'One scope missing'),
        state: revised
            ? _TraceState.done
            : (recompiling ? _TraceState.active : _TraceState.blocked),
      ),
      _TraceStep(
        icon: Icons.lock_clock_outlined,
        title: 'Approval gate',
        detail: revised ? 'Simulation required' : 'PED-07 blocking',
        state: revised ? _TraceState.waiting : _TraceState.blocked,
      ),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: RenkeviaColors.graphite,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          for (var index = 0; index < steps.length; index++) ...[
            Expanded(child: steps[index]),
            if (index < steps.length - 1)
              Container(
                width: 34,
                height: 1,
                color: _traceColor(
                  steps[index + 1].state,
                ).withValues(alpha: 0.7),
              ),
          ],
        ],
      ),
    );
  }
}

enum _TraceState { done, active, blocked, waiting }

Color _traceColor(_TraceState state) => switch (state) {
  _TraceState.done => RenkeviaColors.cyan,
  _TraceState.active => RenkeviaColors.amber,
  _TraceState.blocked => RenkeviaColors.danger,
  _TraceState.waiting => const Color(0xFF71817F),
};

class _TraceStep extends StatelessWidget {
  const _TraceStep({
    required this.icon,
    required this.title,
    required this.detail,
    required this.state,
  });

  final IconData icon;
  final String title;
  final String detail;
  final _TraceState state;

  @override
  Widget build(BuildContext context) {
    final accent = _traceColor(state);
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
          child: Icon(icon, color: accent, size: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: accent, fontSize: 8),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PatchWorkspace extends StatelessWidget {
  const _PatchWorkspace({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showReviewBeside = constraints.maxWidth >= 1080;
        final core = SizedBox(
          height: 650,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 252,
                child: _PatchIrOutline(controller: controller),
              ),
              const SizedBox(width: 12),
              Expanded(child: _ArtifactDiffPanel(controller: controller)),
              if (showReviewBeside) ...[
                const SizedBox(width: 12),
                SizedBox(
                  width: 290,
                  child: _ReviewRail(controller: controller),
                ),
              ],
            ],
          ),
        );
        if (showReviewBeside) return core;
        return Column(
          children: [
            core,
            const SizedBox(height: 12),
            SizedBox(height: 410, child: _ReviewRail(controller: controller)),
          ],
        );
      },
    );
  }
}

class _PatchIrOutline extends StatelessWidget {
  const _PatchIrOutline({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    final revised = controller.patchRevised;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 13, 11),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PATCH IR OUTLINE',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        revised ? 'schema v1 • rev 0.8' : 'schema v1 • rev 0.7',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: RenkeviaColors.success,
                  size: 17,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
              children: [
                const _OutlineSection(
                  label: 'PRECONDITIONS',
                  count: '3',
                  children: [
                    _OutlineLeaf('PRE-01', 'Inventory threshold < 48h'),
                    _OutlineLeaf('PRE-02', 'Alternate carrier verified'),
                    _OutlineLeaf('PRE-03', 'Affected systems sealed'),
                  ],
                ),
                const SizedBox(height: 7),
                _OutlineSection(
                  label: 'MUTATIONS',
                  count: revised ? '2' : '1 + 1 blocked',
                  children: [
                    _MutationTile(
                      id: 'MUT-01',
                      title: 'Substitute adult carrier',
                      detail: '6 projections • SRC-001/002',
                      selected: controller.selectedMutationId == 'MUT-01',
                      state: _MutationState.supported,
                      onTap: () => controller.selectMutation('MUT-01'),
                    ),
                    _MutationTile(
                      id: 'MUT-02',
                      title: revised
                          ? 'Encode pediatric exception'
                          : 'PED-07 exception missing',
                      detail: revised
                          ? '6 projections • SRC-006#T3:C7'
                          : 'Blocking source region uncovered',
                      selected: controller.selectedMutationId == 'MUT-02',
                      state: revised
                          ? _MutationState.revised
                          : _MutationState.blocking,
                      onTap: () => controller.selectMutation('MUT-02'),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                _OutlineSection(
                  label: 'VALIDATIONS',
                  count: revised ? '4 pending' : '1 failed',
                  children: [
                    _OutlineLeaf(
                      'VAL-07',
                      revised
                          ? 'Pediatric suite queued'
                          : 'Pediatric scope unresolved',
                      danger: !revised,
                      warning: revised,
                    ),
                    const _OutlineLeaf('VAL-11', 'Projection coverage = 100%'),
                  ],
                ),
                const SizedBox(height: 7),
                const _OutlineSection(
                  label: 'ROLLBACK',
                  count: '6 actions',
                  children: [
                    _OutlineLeaf('RBK-01', 'Restore sealed revision set'),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF6F5EF),
              border: Border(top: BorderSide(color: RenkeviaColors.hairline)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.code_rounded,
                  size: 15,
                  color: RenkeviaColors.violet,
                ),
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Schema-valid • deterministic projection only',
                    style: TextStyle(
                      color: RenkeviaColors.inkMuted,
                      fontSize: 9,
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

class _OutlineSection extends StatelessWidget {
  const _OutlineSection({
    required this.label,
    required this.count,
    required this.children,
  });

  final String label;
  final String count;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(7, 6, 7, 5),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              Text(
                count,
                style: const TextStyle(
                  color: RenkeviaColors.inkMuted,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }
}

class _OutlineLeaf extends StatelessWidget {
  const _OutlineLeaf(
    this.id,
    this.title, {
    this.danger = false,
    this.warning = false,
  });

  final String id;
  final String title;
  final bool danger;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final accent = danger
        ? RenkeviaColors.danger
        : (warning ? const Color(0xFF9A6918) : RenkeviaColors.inkMuted);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 5, 5, 5),
      child: Row(
        children: [
          Icon(
            danger
                ? Icons.error_outline_rounded
                : (warning
                      ? Icons.pending_actions_outlined
                      : Icons.subdirectory_arrow_right_rounded),
            size: 13,
            color: accent,
          ),
          const SizedBox(width: 6),
          Text(
            id,
            style: TextStyle(
              color: accent,
              fontSize: 7,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: accent, fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }
}

enum _MutationState { supported, blocking, revised }

class _MutationTile extends StatelessWidget {
  const _MutationTile({
    required this.id,
    required this.title,
    required this.detail,
    required this.selected,
    required this.state,
    required this.onTap,
  });

  final String id;
  final String title;
  final String detail;
  final bool selected;
  final _MutationState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = switch (state) {
      _MutationState.supported => RenkeviaColors.cyanDark,
      _MutationState.blocking => RenkeviaColors.danger,
      _MutationState.revised => const Color(0xFF9A6918),
    };
    final wash = switch (state) {
      _MutationState.supported => RenkeviaColors.cyanWash,
      _MutationState.blocking => RenkeviaColors.dangerWash,
      _MutationState.revised => RenkeviaColors.amberWash,
    };
    return Semantics(
      button: true,
      selected: selected,
      label: '$id, $title',
      child: InkWell(
        key: Key('mutation-$id'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.fromLTRB(9, 9, 7, 8),
          decoration: BoxDecoration(
            color: selected ? wash : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: 0.45)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 23,
                height: 23,
                decoration: BoxDecoration(
                  color: selected ? Colors.white.withValues(alpha: 0.75) : wash,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  state == _MutationState.blocking
                      ? Icons.block_outlined
                      : Icons.change_circle_outlined,
                  color: accent,
                  size: 13,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$id  $title',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: accent,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      detail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: RenkeviaColors.inkMuted,
                        fontSize: 8,
                        height: 1.25,
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

class _ArtifactDiffPanel extends StatelessWidget {
  const _ArtifactDiffPanel({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    final artifact = controller.selectedPatchArtifact;
    final revised = controller.patchRevised;
    final spec = _artifactSpec(artifact, revised: revised);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 12, 12, 10),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: RenkeviaColors.cyanWash,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(
                    spec.icon,
                    color: RenkeviaColors.cyanDark,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spec.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${spec.code} • deterministic projection • ${revised ? 'Patch IR v0.8' : 'Patch IR v0.7'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                StatusPill(
                  label: revised ? 'REVISED' : 'CANDIDATE',
                  icon: revised
                      ? Icons.sync_rounded
                      : Icons.warning_amber_rounded,
                  foreground: revised
                      ? RenkeviaColors.cyanDark
                      : const Color(0xFF9A6918),
                  background: revised
                      ? RenkeviaColors.cyanWash
                      : RenkeviaColors.amberWash,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: PatchArtifact.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final item = PatchArtifact.values[index];
                final itemSpec = _artifactSpec(item, revised: revised);
                final selected = item == artifact;
                final linked = _mutationAffects(
                  controller.selectedMutationId,
                  item,
                );
                return Semantics(
                  selected: selected,
                  button: true,
                  label:
                      'Open ${itemSpec.title} projection${linked ? ', linked to ${controller.selectedMutationId}' : ''}',
                  child: InkWell(
                    key: Key('artifact-${item.name}'),
                    onTap: () => controller.selectPatchArtifact(item),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      decoration: BoxDecoration(
                        color: selected
                            ? RenkeviaColors.graphite
                            : (linked
                                  ? const Color(0xFFF0EEF8)
                                  : RenkeviaColors.surfaceRaised),
                        border: Border.all(
                          color: selected
                              ? RenkeviaColors.graphite
                              : (linked
                                    ? const Color(0xFFC9C5E1)
                                    : RenkeviaColors.hairline),
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            itemSpec.icon,
                            size: 12,
                            color: selected
                                ? RenkeviaColors.cyan
                                : (linked
                                      ? RenkeviaColors.violet
                                      : RenkeviaColors.inkMuted),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            itemSpec.shortTitle,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : RenkeviaColors.ink,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (linked) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.link_rounded,
                              key: Key('affected-${item.name}'),
                              size: 9,
                              color: selected
                                  ? RenkeviaColors.cyan
                                  : RenkeviaColors.violet,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ColoredBox(
              color: const Color(0xFFF8F7F2),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(15, 14, 15, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DiffMetadata(spec: spec, revised: revised),
                    const SizedBox(height: 12),
                    _UnifiedDiff(spec: spec),
                    const SizedBox(height: 12),
                    _CausalLinks(
                      revised: revised,
                      mutationId: controller.selectedMutationId,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _ProjectionLedger(
            selected: artifact,
            revised: revised,
            recompiling:
                controller.patchCompileState == PatchCompileState.recompiling,
          ),
        ],
      ),
    );
  }
}

const _pediatricProjectionSet = <PatchArtifact>{
  PatchArtifact.policy,
  PatchArtifact.orderSet,
  PatchArtifact.pumpLibrary,
  PatchArtifact.label,
  PatchArtifact.communication,
  PatchArtifact.legacyEhr,
};

bool _mutationAffects(String mutationId, PatchArtifact artifact) {
  if (mutationId == 'MUT-02') return _pediatricProjectionSet.contains(artifact);
  return true;
}

class _ArtifactSpec {
  const _ArtifactSpec({
    required this.title,
    required this.shortTitle,
    required this.code,
    required this.icon,
    required this.path,
    required this.lines,
  });

  final String title;
  final String shortTitle;
  final String code;
  final IconData icon;
  final String path;
  final List<_DiffLine> lines;
}

_ArtifactSpec _artifactSpec(PatchArtifact artifact, {required bool revised}) {
  final commonException = <_DiffLine>[
    const _DiffLine(_DiffKind.context, '  scope: adult_infusion'),
    const _DiffLine(_DiffKind.remove, '- carrier: STANDARD-A'),
    const _DiffLine(_DiffKind.add, '+ carrier: ALTERNATE-B'),
    if (revised) ...[
      const _DiffLine(
        _DiffKind.add,
        '+ exception PED-07 when population == PEDIATRIC:',
      ),
      const _DiffLine(_DiffKind.add, '+   retain_carrier: STANDARD-A'),
      const _DiffLine(_DiffKind.add, '+   source: SRC-006#T3:C7'),
    ] else
      const _DiffLine(
        _DiffKind.warning,
        '! population exception is not represented',
      ),
    const _DiffLine(_DiffKind.context, '  audit: CHANGE-842'),
  ];
  return switch (artifact) {
    PatchArtifact.policy => _ArtifactSpec(
      title: 'IV carrier conservation policy',
      shortTitle: 'Policy',
      code: 'POL-IV-006',
      icon: Icons.policy_outlined,
      path: '/policy/iv-carrier-v6.md',
      lines: commonException,
    ),
    PatchArtifact.orderSet => _ArtifactSpec(
      title: 'Adult IV therapy order set',
      shortTitle: 'Order set',
      code: 'EHR-OS-014',
      icon: Icons.account_tree_outlined,
      path: '/ehr/order-set/adult-iv-v14.xml',
      lines: commonException,
    ),
    PatchArtifact.pumpLibrary => _ArtifactSpec(
      title: 'Infusion pump library fragment',
      shortTitle: 'Pump',
      code: 'PUMP-LIB-092',
      icon: Icons.tune_outlined,
      path: '/devices/pump-library-v9.2.csv',
      lines: [
        const _DiffLine(_DiffKind.context, '  profile,carrier,limit,scope'),
        const _DiffLine(_DiffKind.remove, '- ADULT_IV,STANDARD-A,120,adult'),
        const _DiffLine(_DiffKind.add, '+ ADULT_IV,ALTERNATE-B,120,adult'),
        if (revised)
          const _DiffLine(_DiffKind.add, '+ PED_IV,STANDARD-A,80,pediatric')
        else
          const _DiffLine(_DiffKind.warning, '! PED_IV mapping unverified'),
        const _DiffLine(_DiffKind.context, '  checksum,7fb1…9ca2'),
      ],
    ),
    PatchArtifact.label => _ArtifactSpec(
      title: 'Pharmacy label template',
      shortTitle: 'Label',
      code: 'LBL-IV-031',
      icon: Icons.document_scanner_outlined,
      path: '/pharmacy/labels/iv-carrier-031.svg',
      lines: commonException,
    ),
    PatchArtifact.communication => _ArtifactSpec(
      title: 'Clinical operations bulletin',
      shortTitle: 'Bulletin',
      code: 'COMMS-247',
      icon: Icons.campaign_outlined,
      path: '/operations/bulletin-247.md',
      lines: commonException,
    ),
    PatchArtifact.legacyEhr => _ArtifactSpec(
      title: 'Legacy EHR staging record',
      shortTitle: 'Legacy EHR',
      code: 'STAGE-OS-014',
      icon: Icons.monitor_heart_outlined,
      path: '/staging/legacy-ehr/order-set-014.json',
      lines: [
        const _DiffLine(
          _DiffKind.context,
          '  "target": "Adult IV Therapy v14",',
        ),
        const _DiffLine(_DiffKind.remove, '- "carrier": "STANDARD-A",'),
        const _DiffLine(_DiffKind.add, '+ "carrier": "ALTERNATE-B",'),
        if (revised)
          const _DiffLine(
            _DiffKind.add,
            '+ "guard": "population != PEDIATRIC",',
          )
        else
          const _DiffLine(_DiffKind.warning, '! no population guard'),
        const _DiffLine(_DiffKind.context, '  "write": "HUMAN_APPROVAL_ONLY"'),
      ],
    ),
  };
}

class _DiffMetadata extends StatelessWidget {
  const _DiffMetadata({required this.spec, required this.revised});

  final _ArtifactSpec spec;
  final bool revised;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 7,
      children: [
        _MetadataChip(icon: Icons.route_outlined, label: spec.path),
        _MetadataChip(
          icon: Icons.fingerprint_rounded,
          label: revised ? 'projection 8f2a…91c4' : 'projection 4d8c…0b17',
        ),
        const _MetadataChip(
          icon: Icons.lock_outline_rounded,
          label: 'write disabled',
          warning: true,
        ),
      ],
    );
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({
    required this.icon,
    required this.label,
    this.warning = false,
  });

  final IconData icon;
  final String label;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final accent = warning ? const Color(0xFF9A6918) : RenkeviaColors.inkMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: warning ? RenkeviaColors.amberWash : RenkeviaColors.surface,
        border: Border.all(
          color: warning ? const Color(0xFFE9D09E) : RenkeviaColors.hairline,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: accent),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

enum _DiffKind { context, remove, add, warning }

class _DiffLine {
  const _DiffLine(this.kind, this.text);

  final _DiffKind kind;
  final String text;
}

class _UnifiedDiff extends StatelessWidget {
  const _UnifiedDiff({required this.spec});

  final _ArtifactSpec spec;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: RenkeviaColors.graphite,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: RenkeviaColors.hairlineDark),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: const BoxDecoration(
              color: RenkeviaColors.graphiteSoft,
              border: Border(
                bottom: BorderSide(color: RenkeviaColors.hairlineDark),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.difference_outlined,
                  size: 14,
                  color: RenkeviaColors.cyan,
                ),
                const SizedBox(width: 7),
                const Expanded(
                  child: Text(
                    'STRUCTURED PROJECTION DIFF',
                    style: TextStyle(
                      color: Color(0xFFB9C5C3),
                      fontSize: 8,
                      letterSpacing: 0.65,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${spec.lines.length} typed lines',
                  style: const TextStyle(color: Color(0xFF7E8D8B), fontSize: 8),
                ),
              ],
            ),
          ),
          for (var index = 0; index < spec.lines.length; index++)
            _DiffLineRow(index: index + 18, line: spec.lines[index]),
        ],
      ),
    );
  }
}

class _DiffLineRow extends StatelessWidget {
  const _DiffLineRow({required this.index, required this.line});

  final int index;
  final _DiffLine line;

  @override
  Widget build(BuildContext context) {
    final (accent, background, marker) = switch (line.kind) {
      _DiffKind.context => (const Color(0xFFAAB7B5), Colors.transparent, ' '),
      _DiffKind.remove => (
        const Color(0xFFF0A39B),
        const Color(0xFF342525),
        '−',
      ),
      _DiffKind.add => (const Color(0xFF83D8C9), const Color(0xFF18302E), '+'),
      _DiffKind.warning => (
        const Color(0xFFF2C66F),
        const Color(0xFF332D20),
        '!',
      ),
    };
    return Container(
      color: background,
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            child: Text(
              '$index',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF667472), fontSize: 8),
            ),
          ),
          Container(width: 1, height: 17, color: const Color(0xFF344240)),
          SizedBox(
            width: 27,
            child: Text(
              marker,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: accent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              line.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: accent,
                fontFamily: 'monospace',
                fontSize: 9,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}

class _CausalLinks extends StatelessWidget {
  const _CausalLinks({required this.revised, required this.mutationId});

  final bool revised;
  final String mutationId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: revised ? RenkeviaColors.cyanWash : RenkeviaColors.dangerWash,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: revised ? const Color(0xFFB8DFD9) : const Color(0xFFE9B7B0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            revised ? Icons.hub_outlined : Icons.account_tree_outlined,
            size: 16,
            color: revised ? RenkeviaColors.cyanDark : RenkeviaColors.danger,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  revised
                      ? 'CAUSAL CHAIN RETAINED'
                      : 'CAUSAL GAP • APPROVAL BLOCKER',
                  style: TextStyle(
                    color: revised
                        ? RenkeviaColors.cyanDark
                        : RenkeviaColors.danger,
                    fontSize: 8,
                    letterSpacing: 0.55,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  revised
                      ? 'SRC-006#T3:C7 → MUT-02 → 6 affected projections → VAL-07 patient suite. Selected context: $mutationId.'
                      : 'SRC-006#T3:C7 has no mutation edge in Patch IR v0.7. Independent file editing is disabled.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: RenkeviaColors.ink,
                    fontSize: 9,
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

class _ProjectionLedger extends StatelessWidget {
  const _ProjectionLedger({
    required this.selected,
    required this.revised,
    required this.recompiling,
  });

  final PatchArtifact selected;
  final bool revised;
  final bool recompiling;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF6F5EF),
        border: Border(top: BorderSide(color: RenkeviaColors.hairline)),
      ),
      child: Row(
        children: [
          Icon(
            recompiling ? Icons.sync_rounded : Icons.link_rounded,
            size: 15,
            color: recompiling ? RenkeviaColors.amber : RenkeviaColors.violet,
          ),
          const SizedBox(width: 7),
          Text(
            recompiling ? 'ATOMIC PROJECTION PASS' : 'REVISION COHERENCE',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const Spacer(),
          for (final artifact in PatchArtifact.values) ...[
            _RevisionDot(
              label: _artifactSpec(artifact, revised: revised).shortTitle,
              selected: artifact == selected,
              revised: revised,
              working: recompiling,
            ),
            if (artifact != PatchArtifact.values.last) const SizedBox(width: 7),
          ],
        ],
      ),
    );
  }
}

class _RevisionDot extends StatelessWidget {
  const _RevisionDot({
    required this.label,
    required this.selected,
    required this.revised,
    required this.working,
  });

  final String label;
  final bool selected;
  final bool revised;
  final bool working;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$label • ${revised ? 'v0.8' : 'v0.7'}',
      child: Container(
        width: selected ? 21 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: working
              ? RenkeviaColors.amber
              : (selected ? RenkeviaColors.violet : RenkeviaColors.cyanDark),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class _ReviewRail extends StatelessWidget {
  const _ReviewRail({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    final revised = controller.patchRevised;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 12, 11),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'SPECIALIST CHALLENGE',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                const SizedBox(width: 6),
                StatusPill(
                  label: revised ? '1 RETEST' : '1 BLOCK',
                  foreground: revised
                      ? const Color(0xFF9A6918)
                      : RenkeviaColors.danger,
                  background: revised
                      ? RenkeviaColors.amberWash
                      : RenkeviaColors.dangerWash,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                const _ReviewCard(
                  initials: 'RX',
                  role: 'Pharmacy Agent',
                  verdict: 'SUPPORTED',
                  detail:
                      'Carrier substitution and conservation language agree with SRC-001 and policy v6.',
                  state: _ReviewState.supported,
                  source: 'SRC-001 • SRC-002',
                ),
                const SizedBox(height: 8),
                const _ReviewCard(
                  initials: 'CI',
                  role: 'Clinical Informatics',
                  verdict: 'SUPPORTED',
                  detail:
                      'Projection schemas remain compatible with the pump fragment and staged legacy target.',
                  state: _ReviewState.supported,
                  source: 'SRC-003 • SRC-004',
                ),
                const SizedBox(height: 8),
                _ReviewCard(
                  initials: 'PS',
                  role: 'Pediatric Safety',
                  verdict: revised ? 'RETEST REQUIRED' : 'BLOCKING DISSENT',
                  detail: revised
                      ? 'Original dissent is retained. MUT-02 now encodes PED-07, but VAL-07 must prove the correction.'
                      : 'PED-07 retains STANDARD-A for the synthetic pediatric pathway. Candidate scope is incomplete.',
                  state: revised ? _ReviewState.retest : _ReviewState.blocking,
                  source: 'SRC-006#T3:C7',
                ),
                const SizedBox(height: 8),
                _ReviewCard(
                  initials: 'AA',
                  role: 'Adversarial Auditor',
                  verdict: revised ? 'NO ORPHAN DIFFS' : 'DEPENDENCY MISSED',
                  detail: revised
                      ? 'All MUT-02 edges terminate in a version-matched projection or explicit validation.'
                      : 'The candidate has six syntactically valid outputs but no population exception edge.',
                  state: revised
                      ? _ReviewState.supported
                      : _ReviewState.blocking,
                  source: 'Graph audit • deterministic',
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: revised
                  ? RenkeviaColors.amberWash
                  : RenkeviaColors.dangerWash,
              border: const Border(
                top: BorderSide(color: RenkeviaColors.hairline),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_clock_outlined,
                  size: 16,
                  color: revised
                      ? const Color(0xFF9A6918)
                      : RenkeviaColors.danger,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'APPROVAL REMAINS LOCKED',
                        style: TextStyle(
                          color: revised
                              ? const Color(0xFF9A6918)
                              : RenkeviaColors.danger,
                          fontSize: 8,
                          letterSpacing: 0.55,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        revised
                            ? 'Patch compilation cannot satisfy a patient-safety assertion. Proceed to Simulation Lab.'
                            : 'The root compiler cannot erase specialist dissent or enable a write.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: RenkeviaColors.ink,
                          fontSize: 9,
                        ),
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

enum _ReviewState { supported, blocking, retest }

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.initials,
    required this.role,
    required this.verdict,
    required this.detail,
    required this.state,
    required this.source,
  });

  final String initials;
  final String role;
  final String verdict;
  final String detail;
  final _ReviewState state;
  final String source;

  @override
  Widget build(BuildContext context) {
    final accent = switch (state) {
      _ReviewState.supported => RenkeviaColors.success,
      _ReviewState.blocking => RenkeviaColors.danger,
      _ReviewState.retest => const Color(0xFF9A6918),
    };
    final wash = switch (state) {
      _ReviewState.supported => RenkeviaColors.successWash,
      _ReviewState.blocking => RenkeviaColors.dangerWash,
      _ReviewState.retest => RenkeviaColors.amberWash,
    };
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: wash,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white.withValues(alpha: 0.78),
                child: Text(
                  initials,
                  style: TextStyle(
                    color: accent,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: RenkeviaColors.ink,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      verdict,
                      style: TextStyle(
                        color: accent,
                        fontSize: 7,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                state == _ReviewState.supported
                    ? Icons.check_circle_outline_rounded
                    : (state == _ReviewState.blocking
                          ? Icons.block_outlined
                          : Icons.pending_actions_outlined),
                color: accent,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: RenkeviaColors.ink,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.link_rounded, size: 11, color: accent),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  source,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accent,
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
