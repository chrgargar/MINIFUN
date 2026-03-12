import 'package:flutter/material.dart';
import 'game_control_buttons.dart';
import 'game_close_button.dart';

/// Header reutilizable para todos los juegos.
/// Incluye stats a la izquierda, y botones de control a la derecha.
class GameHeader extends StatelessWidget {
  final List<Widget> stats;
  final bool isPaused;
  final VoidCallback onPause;
  final VoidCallback onRestart;
  final VoidCallback onClose;
  final Widget guideButton;
  final Widget? hintButton;

  const GameHeader({
    super.key,
    required this.stats,
    required this.isPaused,
    required this.onPause,
    required this.onRestart,
    required this.onClose,
    required this.guideButton,
    this.hintButton,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final btnSize = (sw * 0.09).clamp(28.0, 40.0);
    final hPad = (sw * 0.028).clamp(8.0, 14.0);
    final gap = (sw * 0.016).clamp(4.0, 8.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: hPad * 0.6),
      child: Row(
        children: [
          // Stats a la izquierda (envueltos en Flexible para que se ajusten)
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: stats.expand((widget) => [widget, SizedBox(width: gap)]).toList(),
              ),
            ),
          ),

          SizedBox(width: gap),

          // Controles a la derecha
          GamePauseButton(isPaused: isPaused, onPressed: onPause, size: btnSize),
          SizedBox(width: gap),
          GameRestartButton(onPressed: onRestart, size: btnSize),
          SizedBox(width: gap),
          if (hintButton != null) ...[
            hintButton!,
            SizedBox(width: gap),
          ],
          guideButton,
          SizedBox(width: gap),
          GameCloseButton(onTap: onClose, size: btnSize),
        ],
      ),
    );
  }
}
