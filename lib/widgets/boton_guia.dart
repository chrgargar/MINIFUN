import 'package:flutter/material.dart';
import '../tema/app_colors.dart';
import 'guia_juego_dialog.dart';

/// Botón circular reutilizable para mostrar la guía del juego
/// Se usa en la barra superior de cada juego junto al botón de cerrar
class BotonGuia extends StatelessWidget {
  final String gameTitle;
  final String gameImagePath;
  final String objetivo;
  final List<String> instrucciones;
  final List<ControlItem> controles;
  final double size;
  final VoidCallback? onOpen;  // Callback para pausar el juego
  final VoidCallback? onClose; // Callback para reanudar el juego

  const BotonGuia({
    super.key,
    required this.gameTitle,
    required this.gameImagePath,
    required this.objetivo,
    required this.instrucciones,
    required this.controles,
    this.size = 45,
    this.onOpen,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColoresApp.moradoPrincipal.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: ColoresApp.moradoPrincipal.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.help_outline),
        color: ColoresApp.blanco,
        iconSize: size * 0.53,
        onPressed: () async {
          // Pausar el juego al abrir la guía
          onOpen?.call();

          await GuiaJuegoDialog.show(
            context,
            gameTitle: gameTitle,
            gameImagePath: gameImagePath,
            objetivo: objetivo,
            instrucciones: instrucciones,
            controles: controles,
          );

          // Reanudar el juego al cerrar la guía
          onClose?.call();
        },
      ),
    );
  }
}
