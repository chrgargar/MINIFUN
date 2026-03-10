import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Badge reutilizable para mostrar estadísticas en headers de juegos.
/// Ej: tiempo, score, nivel, banderas, progreso.
class GameStatBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color color;
  final bool isWarning;
  final double fontSize;
  final double hPad;
  final double gap;

  const GameStatBadge({
    super.key,
    required this.text,
    this.icon,
    this.color = const Color(0xFF7B3FF2), // moradoPrincipal
    this.isWarning = false,
    this.fontSize = 13,
    this.hPad = 10,
    this.gap = 4,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = isWarning ? ColoresApp.rojoError : color;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: hPad * 0.4),
      decoration: BoxDecoration(
        color: displayColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize, color: displayColor),
            SizedBox(width: gap * 0.6),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: displayColor,
            ),
          ),
        ],
      ),
    );
  }
}
