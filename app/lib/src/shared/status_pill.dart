import 'package:flutter/material.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.foreground,
    required this.background,
    this.icon,
  });

  final String label;
  final Color foreground;
  final Color background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final labelText = Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foreground,
              fontSize: 10,
              height: 1,
              letterSpacing: 0.55,
              fontWeight: FontWeight.w800,
            ),
          );
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: foreground),
                const SizedBox(width: 5),
              ],
              if (constraints.hasBoundedWidth)
                Flexible(child: labelText)
              else
                labelText,
            ],
          );
        },
      ),
    );
  }
}
