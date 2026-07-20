import 'package:flutter/material.dart';
import 'package:renkevia/src/core/theme/renkevia_theme.dart';

enum RenkeviaJourneyState { complete, current, blocked, waiting }

class RenkeviaJourneyStep {
  const RenkeviaJourneyStep({
    required this.label,
    required this.detail,
    required this.state,
    this.icon,
  });

  final String label;
  final String detail;
  final RenkeviaJourneyState state;
  final IconData? icon;
}

class RenkeviaDecisionHero extends StatelessWidget {
  const RenkeviaDecisionHero({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.summary,
    required this.status,
    required this.action,
    required this.facts,
    this.alert,
    this.alertIcon = Icons.info_outline_rounded,
    this.alertTone = RenkeviaColors.cyanDark,
    this.alertBackground = RenkeviaColors.cyanWash,
  });

  final String eyebrow;
  final String title;
  final String summary;
  final Widget status;
  final Widget action;
  final List<Widget> facts;
  final String? alert;
  final IconData alertIcon;
  final Color alertTone;
  final Color alertBackground;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        final heading = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  eyebrow,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: RenkeviaColors.cyanDark,
                  ),
                ),
                status,
              ],
            ),
            SizedBox(height: compact ? 16 : 21),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Text(
                title,
                textScaler: MediaQuery.textScalerOf(context),
                style: compact
                    ? Theme.of(context).textTheme.headlineLarge
                    : Theme.of(context).textTheme.displayLarge,
              ),
            ),
            const SizedBox(height: 11),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Text(
                summary,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: RenkeviaColors.inkSecondary,
                ),
              ),
            ),
          ],
        );

        return DecoratedBox(
          decoration: BoxDecoration(
            color: RenkeviaColors.surfaceRaised,
            borderRadius: BorderRadius.circular(compact ? 18 : 24),
            boxShadow: RenkeviaShadows.hero,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(compact ? 18 : 24),
            child: CustomPaint(
              painter: const _DependencyTracePainter(),
              child: Padding(
                padding: EdgeInsets.all(compact ? 18 : 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (compact) ...[
                      heading,
                      const SizedBox(height: 18),
                      SizedBox(width: double.infinity, child: action),
                    ] else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: heading),
                          const SizedBox(width: 28),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: action,
                          ),
                        ],
                      ),
                    if (alert case final message?) ...[
                      const SizedBox(height: 20),
                      Semantics(
                        liveRegion: true,
                        label: message,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: alertBackground,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(alertIcon, color: alertTone, size: 19),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  message,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: alertTone,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    Wrap(spacing: 10, runSpacing: 10, children: facts),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class RenkeviaDecisionFact extends StatelessWidget {
  const RenkeviaDecisionFact({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.tone = RenkeviaColors.cyanDark,
    this.background = RenkeviaColors.surfaceMuted,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tone;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context).width;
    final width = viewport < 430
        ? double.infinity
        : (viewport < 760 ? (viewport - 58) / 2 : 210.0);
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: tone),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: RenkeviaColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RenkeviaJourney extends StatelessWidget {
  const RenkeviaJourney({
    super.key,
    required this.steps,
    this.title = 'Decision path',
  });

  final String title;
  final List<RenkeviaJourneyStep> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: RenkeviaColors.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        boxShadow: RenkeviaShadows.panel,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 700;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: RenkeviaColors.inkMuted,
                ),
              ),
              const SizedBox(height: 11),
              if (compact)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var index = 0; index < steps.length; index++)
                      SizedBox(
                        width: constraints.maxWidth < 390
                            ? constraints.maxWidth
                            : (constraints.maxWidth - 8) / 2,
                        child: _JourneyStepCard(
                          index: index,
                          step: steps[index],
                        ),
                      ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var index = 0; index < steps.length; index++) ...[
                      Expanded(
                        child: _JourneyStepCard(
                          index: index,
                          step: steps[index],
                        ),
                      ),
                      if (index < steps.length - 1)
                        Container(
                          width: 22,
                          height: 1,
                          margin: const EdgeInsets.only(top: 27),
                          color: _journeyTone(
                            steps[index].state,
                          ).withValues(alpha: 0.36),
                        ),
                    ],
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class RenkeviaSectionHeading extends StatelessWidget {
  const RenkeviaSectionHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.summary,
    required this.icon,
  });

  final String eyebrow;
  final String title;
  final String summary;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 4, 2, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: RenkeviaColors.cyanWash,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: RenkeviaColors.cyanDark, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: RenkeviaColors.cyanDark,
                  ),
                ),
                const SizedBox(height: 5),
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 5),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Text(
                    summary,
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

class _JourneyStepCard extends StatelessWidget {
  const _JourneyStepCard({required this.index, required this.step});

  final int index;
  final RenkeviaJourneyStep step;

  @override
  Widget build(BuildContext context) {
    final tone = _journeyTone(step.state);
    final active = step.state == RenkeviaJourneyState.current;
    final blocked = step.state == RenkeviaJourneyState.blocked;
    return Container(
      constraints: const BoxConstraints(minHeight: 74),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: active || blocked
            ? tone.withValues(alpha: 0.075)
            : RenkeviaColors.surfaceMuted,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.11),
              shape: BoxShape.circle,
            ),
            child: Icon(
              step.state == RenkeviaJourneyState.complete
                  ? Icons.check_rounded
                  : (step.icon ?? Icons.circle_outlined),
              size: 16,
              color: tone,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: RenkeviaColors.ink),
                ),
                const SizedBox(height: 4),
                Text(
                  step.detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tone),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _journeyTone(RenkeviaJourneyState state) => switch (state) {
  RenkeviaJourneyState.complete => RenkeviaColors.success,
  RenkeviaJourneyState.current => RenkeviaColors.cyanDark,
  RenkeviaJourneyState.blocked => RenkeviaColors.danger,
  RenkeviaJourneyState.waiting => RenkeviaColors.inkMuted,
};

class _DependencyTracePainter extends CustomPainter {
  const _DependencyTracePainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width < 720) return;
    final line = Paint()
      ..color = RenkeviaColors.cyan.withValues(alpha: 0.085)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final node = Paint()
      ..color = RenkeviaColors.cyan.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;
    final x = size.width - 205;
    final path = Path()
      ..moveTo(x, 0)
      ..lineTo(x, 48)
      ..lineTo(x + 78, 92)
      ..lineTo(x + 78, 152)
      ..lineTo(size.width, 196);
    canvas.drawPath(path, line);
    canvas.drawCircle(Offset(x, 48), 4, node);
    canvas.drawCircle(Offset(x + 78, 92), 4, node);
    canvas.drawCircle(Offset(x + 78, 152), 4, node);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
