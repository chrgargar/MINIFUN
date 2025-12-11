import 'package:flutter/material.dart';
import 'ventana_ajustes.dart';

// Botón de ajustes reutilizable
class BotonAjustes extends StatelessWidget {
  const BotonAjustes({super.key});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click, // Cursor de mano al pasar el ratón
      child: GestureDetector(
        onTap: () {
          VentanaAjustes.show(context); // Mostrar diálogo de ajustes
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF7B3FF2), // Morado
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.settings,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
