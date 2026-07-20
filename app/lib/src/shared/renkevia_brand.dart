import 'package:flutter/material.dart';
import 'package:renkevia/src/core/theme/renkevia_theme.dart';

/// RENKEVIA's custom dependency-path monogram.
///
/// The mark is drawn rather than typeset: a single institutional change path
/// forms the bowl and leg of an R, while the amber node marks the point where
/// human review interrupts an otherwise continuous automated flow.
class RenkeviaMark extends StatelessWidget {
  const RenkeviaMark({super.key, this.size = 38, this.foreground, this.accent});

  final double size;
  final Color? foreground;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'RENKEVIA',
      image: true,
      child: ExcludeSemantics(
        child: CustomPaint(
          size: Size.square(size),
          painter: _RenkeviaMarkPainter(
            foreground: foreground ?? RenkeviaColors.graphite,
            accent: accent ?? RenkeviaColors.cyan,
          ),
        ),
      ),
    );
  }
}

class RenkeviaWordmark extends StatelessWidget {
  const RenkeviaWordmark({
    super.key,
    this.onDark = false,
    this.compact = false,
  });

  final bool onDark;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final foreground = onDark ? Colors.white : RenkeviaColors.ink;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RenkeviaMark(
          size: compact ? 31 : 38,
          foreground: foreground,
          accent: RenkeviaColors.cyan,
        ),
        if (!compact) ...[
          const SizedBox(width: 10),
          Text(
            'RENKEVIA',
            style: TextStyle(
              color: foreground,
              fontSize: 15,
              height: 1,
              letterSpacing: 2,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ],
    );
  }
}

class _RenkeviaMarkPainter extends CustomPainter {
  const _RenkeviaMarkPainter({required this.foreground, required this.accent});

  final Color foreground;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 48;
    final main = Paint()
      ..color = foreground
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.2 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final trace = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1 * scale
      ..strokeCap = StrokeCap.round;

    final r = Path()
      ..moveTo(11 * scale, 39 * scale)
      ..lineTo(11 * scale, 9 * scale)
      ..lineTo(23.5 * scale, 9 * scale)
      ..cubicTo(
        32.5 * scale,
        9 * scale,
        37 * scale,
        13.4 * scale,
        37 * scale,
        20 * scale,
      )
      ..cubicTo(
        37 * scale,
        26.5 * scale,
        32.3 * scale,
        30.5 * scale,
        23.5 * scale,
        30.5 * scale,
      )
      ..lineTo(11.5 * scale, 30.5 * scale)
      ..moveTo(25 * scale, 30.5 * scale)
      ..lineTo(39 * scale, 40 * scale);
    canvas.drawPath(r, main);

    final dependencyTrace = Path()
      ..moveTo(4 * scale, 15.5 * scale)
      ..lineTo(11 * scale, 15.5 * scale)
      ..moveTo(37 * scale, 20 * scale)
      ..lineTo(44 * scale, 20 * scale)
      ..moveTo(5 * scale, 39 * scale)
      ..lineTo(11 * scale, 39 * scale);
    canvas.drawPath(dependencyTrace, trace);

    final node = Paint()..color = accent;
    canvas.drawCircle(Offset(4 * scale, 15.5 * scale), 2.3 * scale, node);
    canvas.drawCircle(Offset(44 * scale, 20 * scale), 2.3 * scale, node);

    final humanGate = Paint()..color = RenkeviaColors.amber;
    canvas.drawCircle(Offset(39 * scale, 40 * scale), 2.8 * scale, humanGate);
  }

  @override
  bool shouldRepaint(covariant _RenkeviaMarkPainter oldDelegate) {
    return foreground != oldDelegate.foreground || accent != oldDelegate.accent;
  }
}
