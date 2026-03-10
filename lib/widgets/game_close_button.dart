import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Botón de cierre (X roja) reutilizable para salir de un juego.
class GameCloseButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;

  const GameCloseButton({
    super.key,
    required this.onTap,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: ColoresApp.rojoError,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close,
          color: ColoresApp.blanco,
          size: size * 0.55,
        ),
      ),
    );
  }
}
