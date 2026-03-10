import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Botón de pista reutilizable con badge de contador.
/// Usado por Ahorcado, SopaDeLetras, y otros juegos con sistema de pistas.
class HintButton extends StatelessWidget {
  final int hintsRemaining;
  final VoidCallback? onTap;
  final double size;

  const HintButton({
    super.key,
    required this.hintsRemaining,
    required this.onTap,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasHints = hintsRemaining > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: hasHints ? Colors.amber : Colors.grey,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.lightbulb, color: Colors.white, size: size * 0.55),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.4,
                height: size * 0.4,
                decoration: BoxDecoration(
                  color: ColoresApp.moradoPrincipal,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Center(
                  child: Text(
                    '$hintsRemaining',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
