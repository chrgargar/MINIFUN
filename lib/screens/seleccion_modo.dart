import 'package:flutter/material.dart';
import '../widgets/boton_ajustes.dart';

// Pantalla de selección de modalidad de juego
class SeleccionModo extends StatelessWidget {
  final String gameTitle; // Título del juego seleccionado
  final String gameImagePath; // Ruta de la imagen del juego

  const SeleccionModo({
    super.key,
    required this.gameTitle,
    required this.gameImagePath,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Contenido principal
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Botón de regreso en la esquina superior izquierda
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context); // Regresar a la página anterior
                    },
                    icon: const Icon(Icons.arrow_back_ios, size: 24),
                  ),
                  // Botón de configuración en la esquina superior derecha
                  const BotonAjustes(),
                ],
              ),

              const SizedBox(height: 20),

              // Título Selecciona Modalidad
              Text(
                'Selecciona\nModalidad',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),

              const SizedBox(height: 30),

              // Imagen circular del juego
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: Image.asset(
                    gameImagePath,
                    fit: BoxFit.cover, // Para que la imagen cubra toda la caja
                    width: 120,
                    height: 120,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Botón Jugar
              _buildModeButton(
                icon: '🎮',
                text: 'Jugar',
                color: const Color(0xFF7B3FF2),
                onTap: () {},
              ),

              const SizedBox(height: 16),

              // Botón Guía
              _buildModeButton(
                icon: '📖',
                text: 'Guía',
                color: const Color(0xFF7B3FF2),
                onTap: () {},
              ),

              const SizedBox(height: 16),

              // Botón Supervivencia PRO
              _buildModeButton(
                icon: '💀',
                text: 'Supervivencia\nPRO',
                color: const Color.fromARGB(255, 255, 239, 98),
                textColor: Colors.black,
                onTap: () {},
              ),

              const SizedBox(height: 16),

              // Botón Velocidad
              _buildModeButton(
                icon: '⚡',
                text: 'Velocidad',
                color: const Color(0xFF7B3FF2), 
                onTap: () {},
              ),

              const SizedBox(height: 16),

              // Botón "Contrarreloj"
              _buildModeButton(
                icon: '⏱️',
                text: 'Contrarreloj',
                color: const Color(0xFF7B3FF2),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper para crear los botones de modalidad
  Widget _buildModeButton({
    required String icon,
    required String text,
    required Color color,
    Color textColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
