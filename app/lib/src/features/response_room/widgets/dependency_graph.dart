import 'package:flutter/material.dart';
import 'package:renkevia/src/core/theme/renkevia_theme.dart';

class DependencyGraph extends StatelessWidget {
  const DependencyGraph({
    super.key,
    required this.blockerRevealed,
    required this.onEvidenceRequested,
  });

  final bool blockerRevealed;
  final ValueChanged<String> onEvidenceRequested;

  @override
  Widget build(BuildContext context) {
    final nodes = <_GraphNode>[
      const _GraphNode(
        alignment: Alignment(-0.82, -0.70),
        icon: Icons.campaign_outlined,
        eyebrow: 'SOURCE',
        title: 'Shortage notice',
        detail: '48h threshold',
        state: _NodeState.supported,
        evidenceId: 'SRC-001',
      ),
      const _GraphNode(
        alignment: Alignment(-0.25, -0.72),
        icon: Icons.policy_outlined,
        eyebrow: 'POLICY',
        title: 'IV carrier policy',
        detail: 'Institutional v6',
        state: _NodeState.supported,
        evidenceId: 'SRC-002',
      ),
      const _GraphNode(
        alignment: Alignment(0.35, -0.68),
        icon: Icons.account_tree_outlined,
        eyebrow: 'ORDER SET',
        title: 'Adult IV therapy',
        detail: 'Legacy export v14',
        state: _NodeState.supported,
        evidenceId: 'SRC-003',
      ),
      const _GraphNode(
        alignment: Alignment(-0.64, 0.02),
        icon: Icons.tune_outlined,
        eyebrow: 'DEVICE',
        title: 'Pump library',
        detail: '42 linked entries',
        state: _NodeState.supported,
        evidenceId: 'SRC-004',
      ),
      const _GraphNode(
        alignment: Alignment(-0.02, 0.03),
        icon: Icons.document_scanner_outlined,
        eyebrow: 'ARTIFACT',
        title: 'Pharmacy labels',
        detail: '6 scanned formats',
        state: _NodeState.unresolved,
        evidenceId: 'SRC-005',
      ),
      _GraphNode(
        alignment: const Alignment(0.64, 0.03),
        icon: Icons.child_care_outlined,
        eyebrow: blockerRevealed ? 'PED-07 • BLOCKER' : 'POPULATION',
        title: 'Pediatric pathway',
        detail: blockerRevealed
            ? 'Exception contradicts scope'
            : 'Dependency unchallenged',
        state: blockerRevealed ? _NodeState.blocking : _NodeState.unresolved,
        evidenceId: 'SRC-006',
      ),
      const _GraphNode(
        alignment: Alignment(-0.30, 0.72),
        icon: Icons.monitor_heart_outlined,
        eyebrow: 'LEGACY EHR',
        title: 'Staging order set',
        detail: 'No API • visual write',
        state: _NodeState.control,
        evidenceId: 'SRC-003',
      ),
      _GraphNode(
        alignment: const Alignment(0.55, 0.72),
        icon: blockerRevealed
            ? Icons.lock_outline_rounded
            : Icons.verified_user_outlined,
        eyebrow: 'HUMAN GATE',
        title: blockerRevealed ? 'Approval locked' : 'Review pending',
        detail: blockerRevealed
            ? '1 critical contradiction'
            : 'No write capability',
        state: blockerRevealed ? _NodeState.blocking : _NodeState.control,
        evidenceId: 'SRC-007',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Semantics(
          label:
              'Dependency graph with seven linked hospital systems and one human approval gate',
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _DependencyPainter(blockerRevealed: blockerRevealed),
                ),
              ),
              for (final node in nodes)
                Align(
                  alignment: node.alignment,
                  child: _NodeCard(
                    node: node,
                    onTap: () => onEvidenceRequested(node.evidenceId),
                  ),
                ),
              Positioned(
                left: 12,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: RenkeviaColors.surface.withValues(alpha: 0.92),
                    border: Border.all(color: RenkeviaColors.hairline),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'SELECT A NODE TO TRACE ITS SOURCE REGION',
                    style: TextStyle(
                      color: RenkeviaColors.inkMuted,
                      fontSize: 10,
                      letterSpacing: 0.55,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum _NodeState { supported, unresolved, blocking, control }

class _GraphNode {
  const _GraphNode({
    required this.alignment,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.detail,
    required this.state,
    required this.evidenceId,
  });

  final Alignment alignment;
  final IconData icon;
  final String eyebrow;
  final String title;
  final String detail;
  final _NodeState state;
  final String evidenceId;
}

class _NodeCard extends StatelessWidget {
  const _NodeCard({required this.node, required this.onTap});

  static const size = Size(140, 64);

  final _GraphNode node;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (accent, wash, stateLabel) = switch (node.state) {
      _NodeState.supported => (
        RenkeviaColors.cyanDark,
        RenkeviaColors.cyanWash,
        'supported',
      ),
      _NodeState.unresolved => (
        const Color(0xFF9A6918),
        RenkeviaColors.amberWash,
        'unresolved',
      ),
      _NodeState.blocking => (
        RenkeviaColors.danger,
        RenkeviaColors.dangerWash,
        'blocking',
      ),
      _NodeState.control => (
        RenkeviaColors.violet,
        const Color(0xFFEDEBF6),
        'controlled',
      ),
    };
    return Semantics(
      button: true,
      label: '${node.title}, $stateLabel. Open linked evidence.',
      child: Material(
        color: wash,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: accent.withValues(alpha: 0.58)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(9, 8, 8, 7),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.74),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(node.icon, size: 15, color: accent),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          node.eyebrow,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: accent,
                            fontSize: 10,
                            letterSpacing: 0.45,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          node.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: RenkeviaColors.ink,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          node.detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: RenkeviaColors.inkMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DependencyPainter extends CustomPainter {
  const _DependencyPainter({required this.blockerRevealed});

  final bool blockerRevealed;

  static const alignments = <Alignment>[
    Alignment(-0.82, -0.70),
    Alignment(-0.25, -0.72),
    Alignment(0.35, -0.68),
    Alignment(-0.64, 0.02),
    Alignment(-0.02, 0.03),
    Alignment(0.64, 0.03),
    Alignment(-0.30, 0.72),
    Alignment(0.55, 0.72),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _paintGrid(canvas, size);
    final centers = alignments
        .map((alignment) => _centerFor(size, alignment))
        .toList();

    final regular = Paint()
      ..color = RenkeviaColors.cyanDark.withValues(alpha: 0.45)
      ..strokeWidth = 1.25
      ..style = PaintingStyle.stroke;
    final unresolved = Paint()
      ..color = RenkeviaColors.amber.withValues(alpha: 0.78)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final blocking = Paint()
      ..color = RenkeviaColors.danger.withValues(alpha: 0.9)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final controlled = Paint()
      ..color = RenkeviaColors.violet.withValues(alpha: 0.58)
      ..strokeWidth = 1.25
      ..style = PaintingStyle.stroke;

    _edge(canvas, centers[0], centers[1], regular);
    _edge(canvas, centers[0], centers[3], regular);
    _edge(canvas, centers[1], centers[2], regular);
    _edge(canvas, centers[1], centers[4], unresolved);
    _edge(
      canvas,
      centers[2],
      centers[5],
      blockerRevealed ? blocking : unresolved,
    );
    _edge(canvas, centers[3], centers[4], regular);
    _edge(canvas, centers[3], centers[6], controlled);
    _edge(canvas, centers[4], centers[6], controlled);
    _edge(canvas, centers[4], centers[7], unresolved);
    _edge(
      canvas,
      centers[5],
      centers[7],
      blockerRevealed ? blocking : unresolved,
    );
    _edge(canvas, centers[6], centers[7], controlled);
  }

  void _paintGrid(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = RenkeviaColors.hairline.withValues(alpha: 0.34)
      ..strokeWidth = 0.6;
    for (double x = 18; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 18; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  Offset _centerFor(Size size, Alignment alignment) {
    final availableWidth = size.width - _NodeCard.size.width;
    final availableHeight = size.height - _NodeCard.size.height;
    return Offset(
      _NodeCard.size.width / 2 + availableWidth * ((alignment.x + 1) / 2),
      _NodeCard.size.height / 2 + availableHeight * ((alignment.y + 1) / 2),
    );
  }

  void _edge(Canvas canvas, Offset from, Offset to, Paint paint) {
    final direction = to - from;
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(
        from.dx + direction.dx * 0.42,
        from.dy,
        to.dx - direction.dx * 0.42,
        to.dy,
        to.dx,
        to.dy,
      );
    canvas.drawPath(path, paint);

    final dotPaint = Paint()..color = paint.color;
    canvas.drawCircle(to, paint.strokeWidth + 1.1, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _DependencyPainter oldDelegate) {
    return oldDelegate.blockerRevealed != blockerRevealed;
  }
}
