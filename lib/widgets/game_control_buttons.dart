import 'package:flutter/material.dart';

/// Widget reutilizable de botón de pausa para juegos
class GamePauseButton extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onPressed;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const GamePauseButton({
    super.key,
    required this.isPaused,
    required this.onPressed,
    this.size = 50,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark ? const Color(0xFF2D1B3D) : const Color(0xFFF3E5F5));
    final icColor = iconColor ?? const Color(0xFF7B3FF2);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: icColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: icColor.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Icon(
          isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
          color: icColor,
          size: size * 0.6,
        ),
      ),
    );
  }
}

/// Widget reutilizable de botón de reiniciar para juegos
class GameRestartButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const GameRestartButton({
    super.key,
    required this.onPressed,
    this.size = 50,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark ? const Color(0xFF2D1B3D) : const Color(0xFFF3E5F5));
    final icColor = iconColor ?? const Color(0xFF7B3FF2);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: icColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: icColor.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Icon(
          Icons.refresh_rounded,
          color: icColor,
          size: size * 0.6,
        ),
      ),
    );
  }
}

/// Widget que combina botones de pausa y reiniciar en una fila
class GameControlBar extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onPausePressed;
  final VoidCallback onRestartPressed;
  final double buttonSize;
  final double spacing;
  final Color? backgroundColor;
  final Color? iconColor;

  const GameControlBar({
    super.key,
    required this.isPaused,
    required this.onPausePressed,
    required this.onRestartPressed,
    this.buttonSize = 50,
    this.spacing = 16,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GamePauseButton(
          isPaused: isPaused,
          onPressed: onPausePressed,
          size: buttonSize,
          backgroundColor: backgroundColor,
          iconColor: iconColor,
        ),
        SizedBox(width: spacing),
        GameRestartButton(
          onPressed: onRestartPressed,
          size: buttonSize,
          backgroundColor: backgroundColor,
          iconColor: iconColor,
        ),
      ],
    );
  }
}
