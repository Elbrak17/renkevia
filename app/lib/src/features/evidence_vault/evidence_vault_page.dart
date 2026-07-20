import 'package:flutter/material.dart';
import 'package:renkevia/src/core/theme/renkevia_theme.dart';
import 'package:renkevia/src/features/evidence_vault/evidence_vault_fixture.dart';
import 'package:renkevia/src/features/legacy_ehr/legacy_ehr_fixture.dart';
import 'package:renkevia/src/features/legacy_ehr/legacy_ehr_sandbox_page.dart';
import 'package:renkevia/src/features/workspace/demo_run_controller.dart';
import 'package:renkevia/src/shared/decision_surface.dart';
import 'package:renkevia/src/shared/status_pill.dart';

class EvidenceVaultPage extends StatelessWidget {
  const EvidenceVaultPage({super.key, required this.controller});

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
            _VaultHeader(controller: controller),
            const SizedBox(height: 16),
            _VaultTrace(controller: controller),
            const SizedBox(height: 28),
            const RenkeviaSectionHeading(
              eyebrow: 'HUMAN REVIEW',
              title: 'See each specialist’s conclusion before approval',
              summary:
                  'Reviewers remain independent, their disagreement stays visible, and the approval gate explains exactly what still prevents a final write.',
              icon: Icons.groups_2_outlined,
            ),
            const SizedBox(height: 14),
            _ReviewWorkspace(controller: controller),
            const SizedBox(height: 28),
            const RenkeviaSectionHeading(
              eyebrow: 'ACCOUNTABILITY',
              title: 'Trace, reverse and audit the entire change',
              summary:
                  'Raw identifiers and hashes live here for auditors. The primary approval view above stays focused on the decision and its unresolved conditions.',
              icon: Icons.history_rounded,
            ),
            const SizedBox(height: 14),
            _ProofLedger(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _VaultHeader extends StatelessWidget {
  const _VaultHeader({required this.controller});

  final DemoRunController controller;

  Future<void> _openLegacySandbox(BuildContext context) async {
    final proof = await Navigator.of(context).push<LegacyStagingProof>(
      MaterialPageRoute<LegacyStagingProof>(
        builder: (_) => const LegacyEhrSandboxPage(),
        settings: const RouteSettings(name: '/legacy-ehr'),
      ),
    );
    if (proof != null) controller.acceptLegacyStagingProof(proof);
  }

  @override
  Widget build(BuildContext context) {
    final state = controller.evidenceVaultRunState;
    final verified = controller.simulationVerified;
    final reviewing = state == EvidenceVaultRunState.reviewing;
    final sealed = state == EvidenceVaultRunState.sealed;
    final legacyVerified = controller.legacyStagingVerified;
    final status = legacyVerified
        ? (
            'STAGED • AWAITING HUMAN APPROVAL',
            RenkeviaColors.violet,
            const Color(0xFFEDEBF6),
          )
        : switch ((verified, state)) {
            (false, _) => (
              'UPSTREAM GATE • LOCKED',
              RenkeviaColors.danger,
              RenkeviaColors.dangerWash,
            ),
            (true, EvidenceVaultRunState.ready) => (
              '4 REVIEWS REQUIRED',
              const Color(0xFF9A6918),
              RenkeviaColors.amberWash,
            ),
            (true, EvidenceVaultRunState.reviewing) => (
              'INDEPENDENT REVIEW REPLAY',
              const Color(0xFF9A6918),
              RenkeviaColors.amberWash,
            ),
            (true, EvidenceVaultRunState.sealed) => (
              'VAULT SEALED • 1 DISSENT',
              RenkeviaColors.success,
              RenkeviaColors.successWash,
            ),
          };
    final action = Semantics(
      button: true,
      label: !verified
          ? 'Open safety checks and verify the revised plan'
          : (sealed
                ? (legacyVerified
                      ? 'Legacy staging is proven; a named human decision is required'
                      : 'Open the fictional legacy system to prepare staging')
                : 'Request four independent specialist reviews'),
      child: FilledButton.icon(
        key: const Key('evidence-vault-primary-button'),
        onPressed: !verified
            ? () => controller.selectSection(WorkspaceSection.simulationLab)
            : (state == EvidenceVaultRunState.ready
                  ? controller.runSpecialistReviews
                  : (sealed && !legacyVerified
                        ? () => _openLegacySandbox(context)
                        : null)),
        icon: reviewing
            ? const SizedBox.square(
                dimension: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                sealed
                    ? (legacyVerified
                          ? Icons.how_to_reg_outlined
                          : Icons.open_in_new_rounded)
                    : (verified
                          ? Icons.groups_outlined
                          : Icons.arrow_back_rounded),
                size: 18,
              ),
        label: Text(
          !verified
              ? 'Complete safety checks first'
              : switch (state) {
                  EvidenceVaultRunState.ready => 'Request specialist review',
                  EvidenceVaultRunState.reviewing =>
                    'Four reviews in progress…',
                  EvidenceVaultRunState.sealed =>
                    legacyVerified
                        ? 'Awaiting named approver'
                        : 'Prepare legacy staging',
                },
        ),
      ),
    );
    return RenkeviaDecisionHero(
      eyebrow: 'STEP 4 OF 4  •  APPROVAL RECORD',
      title: legacyVerified
          ? 'Everything is ready—except the human decision.'
          : (sealed
                ? 'Agreement is useful. Preserved disagreement is safer.'
                : 'Turn every claim into an accountable approval record.'),
      summary: legacyVerified
          ? 'The fictional legacy screen was rechecked, prepared in staging and captured as visual proof. RENKEVIA stops here: the final write remains disabled until a named authorized person approves it.'
          : (sealed
                ? 'Pharmacy, clinical informatics, pediatric safety and an adversarial reviewer examined the same package independently. Their evidence, dissent and exact rollback now travel with the change.'
                : 'Four specialist perspectives challenge the same revision without sharing conclusions first. RENKEVIA preserves disagreement, ties every material claim to evidence and keeps rollback beside the approval decision.'),
      status: StatusPill(
        label: legacyVerified
            ? 'READY FOR HUMAN DECISION'
            : (sealed ? '4 REVIEWS COMPLETE • 1 DISSENT' : status.$1),
        icon: legacyVerified
            ? Icons.how_to_reg_outlined
            : (sealed
                  ? Icons.inventory_2_outlined
                  : (reviewing
                        ? Icons.groups_outlined
                        : Icons.lock_clock_outlined)),
        foreground: status.$2,
        background: status.$3,
      ),
      action: action,
      alert: legacyVerified
          ? 'Human boundary: RENKEVIA prepared the legacy change but cannot press the final commit button. The approval control remains intentionally locked.'
          : (sealed
                ? 'Open concern: the legacy EHR offers no API. Its screen must be visually rechecked before staging, and final commit still requires a person.'
                : 'The reviewers work independently so one confident answer cannot erase pharmacy, pediatric or legacy-system concerns.'),
      alertIcon: legacyVerified
          ? Icons.pan_tool_alt_outlined
          : (sealed ? Icons.desktop_windows_outlined : Icons.groups_outlined),
      alertTone: legacyVerified
          ? RenkeviaColors.violet
          : (sealed ? RenkeviaColors.amber : status.$2),
      alertBackground: legacyVerified
          ? const Color(0xFFEDEBF6)
          : (sealed ? RenkeviaColors.amberWash : status.$3),
      facts: [
        RenkeviaDecisionFact(
          label: sealed
              ? 'independent perspectives returned'
              : 'required perspectives',
          value: sealed
              ? '4 of 4 reviews'
              : (reviewing ? 'Reviewing…' : '4 reviewers'),
          icon: Icons.groups_2_outlined,
          tone: sealed ? RenkeviaColors.success : RenkeviaColors.amber,
          background: sealed
              ? RenkeviaColors.successWash
              : RenkeviaColors.amberWash,
        ),
        RenkeviaDecisionFact(
          label: sealed ? 'kept visible for the approver' : 'not yet collected',
          value: sealed ? '1 open concern' : 'Dissent pending',
          icon: Icons.record_voice_over_outlined,
          tone: RenkeviaColors.amber,
          background: RenkeviaColors.amberWash,
        ),
        RenkeviaDecisionFact(
          label: sealed ? 'material changes linked' : 'record not sealed',
          value: sealed ? '100% traceable' : 'Evidence pending',
          icon: Icons.link_rounded,
          tone: sealed ? RenkeviaColors.success : RenkeviaColors.inkMuted,
          background: sealed
              ? RenkeviaColors.successWash
              : RenkeviaColors.surfaceMuted,
        ),
        RenkeviaDecisionFact(
          label: sealed ? 'exact restoration available' : 'not yet verified',
          value: sealed ? '6 of 6 reversible' : 'Rollback pending',
          icon: Icons.settings_backup_restore_rounded,
          tone: sealed ? RenkeviaColors.success : RenkeviaColors.inkMuted,
          background: sealed
              ? RenkeviaColors.successWash
              : RenkeviaColors.surfaceMuted,
        ),
      ],
    );
  }
}

class _VaultTrace extends StatelessWidget {
  const _VaultTrace({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.evidenceVaultRunState;
    final verified = controller.simulationVerified;
    final reviewing = state == EvidenceVaultRunState.reviewing;
    final sealed = state == EvidenceVaultRunState.sealed;
    final legacyVerified = controller.legacyStagingVerified;
    return RenkeviaJourney(
      title: 'Approval readiness',
      steps: [
        RenkeviaJourneyStep(
          label: 'Safety proven',
          detail: verified ? '24 pathways pass' : 'Safety checks required',
          icon: Icons.verified_outlined,
          state: verified
              ? RenkeviaJourneyState.complete
              : RenkeviaJourneyState.blocked,
        ),
        RenkeviaJourneyStep(
          label: 'Specialists challenge',
          detail: reviewing
              ? '4 reviews in progress'
              : (sealed ? '4 reviews returned' : 'Not started'),
          icon: Icons.groups_2_outlined,
          state: reviewing
              ? RenkeviaJourneyState.current
              : (sealed
                    ? RenkeviaJourneyState.complete
                    : RenkeviaJourneyState.waiting),
        ),
        RenkeviaJourneyStep(
          label: 'Proof sealed',
          detail: sealed ? 'Evidence + rollback ready' : 'Waiting for reviews',
          icon: Icons.inventory_2_outlined,
          state: sealed
              ? RenkeviaJourneyState.complete
              : RenkeviaJourneyState.waiting,
        ),
        RenkeviaJourneyStep(
          label: 'Human decides',
          detail: legacyVerified
              ? 'Named approval required'
              : (sealed ? 'Legacy staging required' : 'Downstream gate'),
          icon: Icons.how_to_reg_outlined,
          state: legacyVerified
              ? RenkeviaJourneyState.current
              : (sealed
                    ? RenkeviaJourneyState.blocked
                    : RenkeviaJourneyState.waiting),
        ),
      ],
    );
  }
}

class _ReviewWorkspace extends StatelessWidget {
  const _ReviewWorkspace({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    final rail = _ReviewRail(controller: controller);
    final finding = _FindingInspector(controller: controller);
    final gate = _ApprovalGate(controller: controller);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            children: [
              rail,
              const SizedBox(height: 12),
              finding,
              const SizedBox(height: 12),
              gate,
            ],
          );
        }
        if (constraints.maxWidth >= 1110) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 244, child: rail),
              const SizedBox(width: 12),
              Expanded(child: finding),
              const SizedBox(width: 12),
              SizedBox(width: 310, child: gate),
            ],
          );
        }
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 244, child: rail),
                const SizedBox(width: 12),
                Expanded(child: finding),
              ],
            ),
            const SizedBox(height: 12),
            gate,
          ],
        );
      },
    );
  }
}

class _ReviewRail extends StatelessWidget {
  const _ReviewRail({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.evidenceVaultRunState;
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _PanelHeading(
            eyebrow: 'REVIEW MESH',
            title: 'Independent specialists',
            trailing: '4 contexts',
          ),
          const Divider(height: 1),
          for (final review in specialistReviews)
            _ReviewTile(
              review: review,
              state: state,
              selected: controller.selectedSpecialistReviewId == review.id,
              onTap: () => controller.selectSpecialistReview(review.id),
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
                  Icons.call_split_outlined,
                  color: RenkeviaColors.violet,
                  size: 15,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Each reviewer receives a separately hashed context. Shared unsupported claims are not counted as independent evidence.',
                    style: TextStyle(
                      color: RenkeviaColors.inkMuted,
                      fontSize: 9.3,
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

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.review,
    required this.state,
    required this.selected,
    required this.onTap,
  });

  final SpecialistReview review;
  final EvidenceVaultRunState state;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sealed = state == EvidenceVaultRunState.sealed;
    final reviewing = state == EvidenceVaultRunState.reviewing;
    final color = !sealed
        ? (reviewing ? RenkeviaColors.amber : RenkeviaColors.inkMuted)
        : _verdictColor(review.verdict);
    final label = !sealed
        ? (reviewing ? 'REVIEWING' : 'PENDING')
        : switch (review.verdict) {
            ReviewVerdict.agree => 'AGREE',
            ReviewVerdict.conditional => 'CONDITION MET',
            ReviewVerdict.dissent => 'DISSENT',
          };
    return Material(
      color: selected ? RenkeviaColors.cyanWash : Colors.transparent,
      child: InkWell(
        key: Key('review-${review.id}'),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(_reviewIcon(review.id), color: color, size: 15),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: RenkeviaColors.ink,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: 8,
                        letterSpacing: 0.4,
                        fontWeight: FontWeight.w800,
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

IconData _reviewIcon(String id) => switch (id) {
  'pharmacy' => Icons.medication_outlined,
  'clinical-informatics' => Icons.account_tree_outlined,
  'pediatric-safety' => Icons.child_care_outlined,
  _ => Icons.troubleshoot_outlined,
};

Color _verdictColor(ReviewVerdict verdict) => switch (verdict) {
  ReviewVerdict.agree => RenkeviaColors.success,
  ReviewVerdict.conditional => const Color(0xFF9A6918),
  ReviewVerdict.dissent => RenkeviaColors.danger,
};

class _FindingInspector extends StatelessWidget {
  const _FindingInspector({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    final review = specialistReviewById(controller.selectedSpecialistReviewId);
    final state = controller.evidenceVaultRunState;
    final sealed = state == EvidenceVaultRunState.sealed;
    final reviewing = state == EvidenceVaultRunState.reviewing;
    final accent = sealed
        ? _verdictColor(review.verdict)
        : (reviewing ? RenkeviaColors.amber : RenkeviaColors.inkMuted);
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PanelHeading(
            eyebrow: 'SPECIALIST FINDING',
            title: review.role,
            trailing: sealed
                ? review.findingId
                : (reviewing ? 'RUNNING' : 'WAITING'),
            danger: sealed && review.verdict == ReviewVerdict.dissent,
            success: sealed && review.verdict == ReviewVerdict.agree,
            warning:
                reviewing ||
                (sealed && review.verdict == ReviewVerdict.conditional),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(15),
            child: sealed
                ? _SealedFinding(review: review)
                : _PendingFinding(
                    review: review,
                    reviewing: reviewing,
                    accent: accent,
                  ),
          ),
        ],
      ),
    );
  }
}

class _PendingFinding extends StatelessWidget {
  const _PendingFinding({
    required this.review,
    required this.reviewing,
    required this.accent,
  });

  final SpecialistReview review;
  final bool reviewing;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 330,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.11),
              shape: BoxShape.circle,
              border: Border.all(color: accent.withValues(alpha: 0.5)),
            ),
            child: reviewing
                ? Padding(
                    padding: const EdgeInsets.all(15),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: accent,
                    ),
                  )
                : Icon(Icons.hourglass_empty_rounded, color: accent, size: 21),
          ),
          const SizedBox(height: 14),
          Text(
            reviewing
                ? 'Independent context executing'
                : 'Review has not started',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 7),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Text(
              reviewing
                  ? '${review.scope}. The finding remains hidden until this fixture replay returns.'
                  : 'Complete the deterministic regression gate, then launch all four specialist contexts together.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 13),
          StatusPill(
            label: 'INPUT ${review.inputHash}',
            icon: Icons.fingerprint_rounded,
            foreground: RenkeviaColors.violet,
            background: const Color(0xFFEDEBF6),
          ),
        ],
      ),
    );
  }
}

class _SealedFinding extends StatelessWidget {
  const _SealedFinding({required this.review});

  final SpecialistReview review;

  @override
  Widget build(BuildContext context) {
    final color = _verdictColor(review.verdict);
    final verdict = switch (review.verdict) {
      ReviewVerdict.agree => 'AGREEMENT',
      ReviewVerdict.conditional => 'CONDITION SATISFIED',
      ReviewVerdict.dissent => 'DISSENT PRESERVED',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            border: Border.all(color: color.withValues(alpha: 0.32)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                review.verdict == ReviewVerdict.dissent
                    ? Icons.record_voice_over_outlined
                    : Icons.fact_check_outlined,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$verdict • ${review.findingId}',
                      style: TextStyle(
                        color: color,
                        fontSize: 8.5,
                        letterSpacing: 0.55,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      review.finding,
                      style: const TextStyle(
                        color: RenkeviaColors.ink,
                        fontSize: 11,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            Text(
              'EVIDENCE USED',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontSize: 8),
            ),
            const Spacer(),
            Text(
              review.inputHash,
              style: const TextStyle(
                color: RenkeviaColors.violet,
                fontFamily: 'RenkeviaMono',
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final evidenceId in review.evidenceIds)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F1EA),
                  border: Border.all(color: RenkeviaColors.hairline),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.link_rounded,
                      size: 11,
                      color: RenkeviaColors.violet,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      evidenceId,
                      style: const TextStyle(
                        color: RenkeviaColors.ink,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 13),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: RenkeviaColors.graphite,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ROOT COMPILER DISPOSITION',
                style: TextStyle(
                  color: Color(0xFF91A7A4),
                  fontSize: 8,
                  letterSpacing: 0.65,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                review.disposition,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ApprovalGate extends StatelessWidget {
  const _ApprovalGate({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    final sealed =
        controller.evidenceVaultRunState == EvidenceVaultRunState.sealed;
    final legacyVerified = controller.legacyStagingVerified;
    final blockers = evidenceVaultBlockers(
      simulationVerified: controller.simulationVerified,
      state: controller.evidenceVaultRunState,
      legacyStagingVerified: legacyVerified,
    );
    final checks = <(String, bool)>[
      ('Patch IR v0.8 schema-valid', controller.patchRevised),
      ('24 / 24 pathways verified', controller.simulationVerified),
      ('6 / 6 projections source-linked', sealed),
      ('4 / 4 specialist reviews returned', sealed),
      ('Rollback exact for complete + partial staging', sealed),
      ('Legacy screen state visually proven', legacyVerified),
    ];
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PanelHeading(
            eyebrow: 'POLICY-OWNED GATE',
            title: 'Human approval',
            trailing: legacyVerified ? 'AWAITING HUMAN' : 'LOCKED',
            danger: !legacyVerified,
            warning: legacyVerified,
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: legacyVerified
                        ? RenkeviaColors.amberWash
                        : RenkeviaColors.dangerWash,
                    border: Border.all(
                      color:
                          (legacyVerified
                                  ? RenkeviaColors.amber
                                  : RenkeviaColors.danger)
                              .withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_clock_outlined,
                        color: legacyVerified
                            ? const Color(0xFF9A6918)
                            : RenkeviaColors.danger,
                        size: 19,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              legacyVerified
                                  ? 'AWAITING NAMED HUMAN APPROVAL'
                                  : 'APPROVAL REMAINS LOCKED',
                              style: TextStyle(
                                color: legacyVerified
                                    ? const Color(0xFF9A6918)
                                    : RenkeviaColors.danger,
                                fontSize: 8.5,
                                letterSpacing: 0.55,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              legacyVerified
                                  ? 'No machine blocker remains. The demo stops here.'
                                  : sealed
                                  ? 'One machine-evaluated blocker remains.'
                                  : '${blockers.length} prerequisite groups remain.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 13),
                for (final check in checks)
                  _GateCheck(label: check.$1, passed: check.$2),
                const SizedBox(height: 12),
                if (sealed && !legacyVerified)
                  Container(
                    key: const Key('legacy-staging-blocker'),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: RenkeviaColors.amberWash,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.desktop_windows_outlined,
                          color: Color(0xFF9A6918),
                          size: 15,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'LEGACY-01 • Stage v0.8 in the fictional no-API EHR and capture visual parity proof.',
                            style: TextStyle(
                              color: Color(0xFF79510F),
                              fontSize: 9,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (legacyVerified)
                  Container(
                    key: const Key('legacy-staging-proof'),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: RenkeviaColors.successWash,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          color: RenkeviaColors.success,
                          size: 15,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${controller.legacyStagingProof!.proofId} • screen ${controller.legacyStagingProof!.screenshotHash} • state recheck matched',
                            style: const TextStyle(
                              color: RenkeviaColors.success,
                              fontSize: 9,
                              height: 1.4,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('request-approval-button'),
                  onPressed: null,
                  icon: const Icon(Icons.how_to_reg_outlined, size: 17),
                  label: const Text('Request named human approval'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'The Flutter client cannot override server-computed blockers or perform the final write.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: RenkeviaColors.inkMuted,
                    fontSize: 8.5,
                    height: 1.4,
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

class _GateCheck extends StatelessWidget {
  const _GateCheck({required this.label, required this.passed});

  final String label;
  final bool passed;

  @override
  Widget build(BuildContext context) {
    final color = passed ? RenkeviaColors.success : RenkeviaColors.danger;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 17,
            height: 17,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.55)),
            ),
            child: Icon(
              passed ? Icons.check_rounded : Icons.close_rounded,
              size: 11,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: passed ? RenkeviaColors.ink : RenkeviaColors.danger,
                fontSize: 9.2,
                height: 1.35,
                fontWeight: passed ? FontWeight.w500 : FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProofLedger extends StatelessWidget {
  const _ProofLedger({required this.controller});

  final DemoRunController controller;

  @override
  Widget build(BuildContext context) {
    final sealed =
        controller.evidenceVaultRunState == EvidenceVaultRunState.sealed;
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final heading = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'APPEND-ONLY PROOF LEDGER',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: RenkeviaColors.cyanDark,
                        fontSize: 8,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Every summary resolves to raw identifiers and hashes.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                );
                final status = StatusPill(
                  label: sealed ? 'BUNDLE PRV-0.8 • SEALED' : 'BUNDLE PENDING',
                  icon: sealed
                      ? Icons.verified_user_outlined
                      : Icons.hourglass_empty,
                  foreground: sealed
                      ? RenkeviaColors.success
                      : const Color(0xFF9A6918),
                  background: sealed
                      ? RenkeviaColors.successWash
                      : RenkeviaColors.amberWash,
                );
                if (constraints.maxWidth < 560) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [heading, const SizedBox(height: 9), status],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: heading),
                    const SizedBox(width: 10),
                    status,
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                _LedgerTab(
                  key: const Key('vault-tab-provenance'),
                  label: 'Provenance • 6',
                  icon: Icons.link_rounded,
                  selected:
                      controller.selectedVaultLedgerView ==
                      VaultLedgerView.provenance,
                  onTap: () => controller.selectVaultLedgerView(
                    VaultLedgerView.provenance,
                  ),
                ),
                _LedgerTab(
                  key: const Key('vault-tab-rollback'),
                  label: 'Rollback • exact',
                  icon: Icons.settings_backup_restore_rounded,
                  selected:
                      controller.selectedVaultLedgerView ==
                      VaultLedgerView.rollback,
                  onTap: () => controller.selectVaultLedgerView(
                    VaultLedgerView.rollback,
                  ),
                ),
                _LedgerTab(
                  key: const Key('vault-tab-auditLog'),
                  label: 'Audit log • 5',
                  icon: Icons.receipt_long_outlined,
                  selected:
                      controller.selectedVaultLedgerView ==
                      VaultLedgerView.auditLog,
                  onTap: () => controller.selectVaultLedgerView(
                    VaultLedgerView.auditLog,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          const Divider(height: 1),
          if (!sealed)
            const _LedgerPending()
          else
            switch (controller.selectedVaultLedgerView) {
              VaultLedgerView.provenance => const _ProvenanceTable(),
              VaultLedgerView.rollback => const _RollbackTable(),
              VaultLedgerView.auditLog => const _AuditTimeline(),
            },
        ],
      ),
    );
  }
}

class _LedgerTab extends StatelessWidget {
  const _LedgerTab({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? RenkeviaColors.graphite : const Color(0xFFF4F2EB),
          border: Border.all(
            color: selected ? RenkeviaColors.graphite : RenkeviaColors.hairline,
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? RenkeviaColors.cyan : RenkeviaColors.inkMuted,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : RenkeviaColors.ink,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LedgerPending extends StatelessWidget {
  const _LedgerPending();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 170,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: RenkeviaColors.inkMuted,
                size: 24,
              ),
              SizedBox(height: 9),
              Text(
                'Ledger entries appear only after all review contexts return.',
                textAlign: TextAlign.center,
                style: TextStyle(color: RenkeviaColors.inkMuted, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResponsiveLedgerTable extends StatelessWidget {
  const _ResponsiveLedgerTable({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth < 788
            ? 760.0
            : constraints.maxWidth - 28;
        return Padding(
          padding: const EdgeInsets.all(14),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: tableWidth, child: child),
          ),
        );
      },
    );
  }
}

class _ProvenanceTable extends StatelessWidget {
  const _ProvenanceTable();

  @override
  Widget build(BuildContext context) {
    return _ResponsiveLedgerTable(
      child: Column(
        children: [
          const _LedgerHeader(
            columns: [
              'ARTIFACT',
              'MUTATION',
              'SOURCE REGION',
              'CLAIM HASH',
              'STATE',
            ],
          ),
          for (final record in provenanceRecords)
            _ProvenanceRow(record: record),
        ],
      ),
    );
  }
}

class _LedgerHeader extends StatelessWidget {
  const _LedgerHeader({required this.columns});

  final List<String> columns;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: RenkeviaColors.graphite,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          for (final column in columns)
            Expanded(
              flex: column == 'ARTIFACT' ? 2 : 1,
              child: Text(
                column,
                style: const TextStyle(
                  color: Color(0xFFA8B9B7),
                  fontSize: 8,
                  letterSpacing: 0.55,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProvenanceRow extends StatelessWidget {
  const _ProvenanceRow({required this.record});

  final ProvenanceRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: RenkeviaColors.hairline)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.artifactId,
                  style: const TextStyle(
                    color: RenkeviaColors.ink,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  record.artifact,
                  style: const TextStyle(
                    color: RenkeviaColors.inkMuted,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _MonoText(record.mutationId)),
          Expanded(child: _MonoText('${record.sourceId}#${record.region}')),
          Expanded(child: _MonoText(record.claimHash)),
          const Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 12,
                  color: RenkeviaColors.success,
                ),
                SizedBox(width: 5),
                Text(
                  'LINKED',
                  style: TextStyle(
                    color: RenkeviaColors.success,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
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

class _RollbackTable extends StatelessWidget {
  const _RollbackTable();

  @override
  Widget build(BuildContext context) {
    return _ResponsiveLedgerTable(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: RenkeviaColors.successWash,
              border: Border.all(
                color: RenkeviaColors.success.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.verified_outlined,
                  color: RenkeviaColors.success,
                  size: 18,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'ROLLBACK EXACT • 6 / 6 • complete and partially staged fixtures restore PRE-8D4A',
                    style: TextStyle(
                      color: RenkeviaColors.success,
                      fontSize: 9,
                      letterSpacing: 0.35,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          const _LedgerHeader(
            columns: [
              'ARTIFACT',
              'PRE-PATCH HASH',
              'CANDIDATE HASH',
              'RESTORED HASH',
              'EXACT',
            ],
          ),
          for (final record in rollbackRecords)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: RenkeviaColors.hairline),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _MonoText(record.artifactId, strong: true),
                  ),
                  Expanded(child: _MonoText(record.beforeHash)),
                  Expanded(child: _MonoText(record.candidateHash)),
                  Expanded(child: _MonoText(record.restoredHash)),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          record.isExact ? Icons.check_circle : Icons.cancel,
                          size: 12,
                          color: record.isExact
                              ? RenkeviaColors.success
                              : RenkeviaColors.danger,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          record.isExact ? 'MATCH' : 'MISMATCH',
                          style: TextStyle(
                            color: record.isExact
                                ? RenkeviaColors.success
                                : RenkeviaColors.danger,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
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

class _AuditTimeline extends StatelessWidget {
  const _AuditTimeline();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          for (var index = 0; index < vaultAuditEvents.length; index++)
            _AuditEventRow(
              event: vaultAuditEvents[index],
              last: index == vaultAuditEvents.length - 1,
            ),
        ],
      ),
    );
  }
}

class _AuditEventRow extends StatelessWidget {
  const _AuditEventRow({required this.event, required this.last});

  final VaultAuditEvent event;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    final action = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.action,
          style: const TextStyle(
            color: RenkeviaColors.ink,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          event.actor,
          style: const TextStyle(color: RenkeviaColors.inkMuted, fontSize: 8.5),
        ),
      ],
    );
    final content = compact
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MonoText('${event.time} • ${event.id}'),
              const SizedBox(height: 5),
              action,
              const SizedBox(height: 5),
              _MonoText('${event.inputHash} → ${event.outputHash}'),
            ],
          )
        : Row(
            children: [
              SizedBox(
                width: 92,
                child: _MonoText('${event.time}\n${event.id}'),
              ),
              Expanded(flex: 2, child: action),
              Expanded(
                child: _MonoText('${event.inputHash} → ${event.outputHash}'),
              ),
            ],
          );
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 25,
            child: Column(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: RenkeviaColors.cyanWash,
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(color: RenkeviaColors.cyanDark),
                    ),
                  ),
                  child: const Icon(
                    Icons.fingerprint_rounded,
                    size: 10,
                    color: RenkeviaColors.cyanDark,
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(width: 1, color: RenkeviaColors.hairline),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 12),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonoText extends StatelessWidget {
  const _MonoText(this.value, {this.strong = false});

  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: strong ? RenkeviaColors.ink : RenkeviaColors.inkMuted,
        fontFamily: 'RenkeviaMono',
        fontSize: 8.5,
        height: 1.35,
        fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: RenkeviaColors.surface,
        border: Border.all(color: RenkeviaColors.hairline),
        borderRadius: BorderRadius.circular(11),
      ),
      child: child,
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
    this.warning = false,
  });

  final String eyebrow;
  final String title;
  final String trailing;
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
