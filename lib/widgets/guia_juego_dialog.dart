import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tema/language_provider.dart';
import '../constants/app_strings.dart';

/// Widget reutilizable para mostrar la guía de un juego
/// Muestra un diálogo con instrucciones, objetivos y controles del juego
class GuiaJuegoDialog extends StatelessWidget {
  final String gameTitle;
  final String gameImagePath;
  final String objetivo;
  final List<String> instrucciones;
  final List<ControlItem> controles;

  const GuiaJuegoDialog({
    super.key,
    required this.gameTitle,
    required this.gameImagePath,
    required this.objetivo,
    required this.instrucciones,
    required this.controles,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLang = Provider.of<LanguageProvider>(context).currentLanguage;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Encabezado con título y botón de cerrar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Icono del juego
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          gameImagePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Título
                    Text(
                      '${AppStrings.get('guide_of', currentLang)} $gameTitle',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                // Botón de cerrar
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Contenido desplazable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección: Objetivo
                    _buildSection(
                      title: '🎯 ${AppStrings.get('objective', currentLang)}',
                      content: objetivo,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 16),

                    // Sección: Instrucciones
                    _buildListSection(
                      title: '📋 ${AppStrings.get('instructions', currentLang)}',
                      items: instrucciones,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 16),

                    // Sección: Controles
                    _buildControlsSection(
                      title: '🎮 ${AppStrings.get('controls', currentLang)}',
                      controls: controles,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botón para cerrar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B3FF2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppStrings.get('understood', currentLang),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2D1B3D).withOpacity(0.5)
            : const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection({
    required String title,
    required List<String> items,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2D1B3D).withOpacity(0.5)
            : const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.key + 1}. ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF7B3FF2),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildControlsSection({
    required String title,
    required List<ControlItem> controls,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2D1B3D).withOpacity(0.5)
            : const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ...controls.map((control) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  // Icono o emoji del control
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B3FF2).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      control.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Descripción del control
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          control.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          control.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Método estático para mostrar el diálogo fácilmente
  static void show(
    BuildContext context, {
    required String gameTitle,
    required String gameImagePath,
    required String objetivo,
    required List<String> instrucciones,
    required List<ControlItem> controles,
  }) {
    showDialog(
      context: context,
      builder: (context) => GuiaJuegoDialog(
        gameTitle: gameTitle,
        gameImagePath: gameImagePath,
        objetivo: objetivo,
        instrucciones: instrucciones,
        controles: controles,
      ),
    );
  }
}

/// Clase para representar un control del juego
class ControlItem {
  final String icon; // Emoji o icono
  final String name; // Nombre del control
  final String description; // Descripción de qué hace

  const ControlItem({
    required this.icon,
    required this.name,
    required this.description,
  });
}
