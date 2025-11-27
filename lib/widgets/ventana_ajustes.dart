import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tema/selectorTema.dart';

// Widget reutilizable para mostrar el diálogo de ajustes
class VentanaAjustes {
  // Mostrar diálogo de ajustes
  static void show(BuildContext context) {
    final themeProvider = Provider.of<SelectorTema>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título del diálogo
                Text(
                  'Ajustes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(dialogContext).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                const SizedBox(height: 24),

                // Opción: Tema oscuro/claro con switch
                _buildThemeOption(
                  context: dialogContext,
                  themeProvider: themeProvider,
                ),

                const Divider(height: 32),

                // Opción: Racha de días
                _buildStreakOption(
                  context: dialogContext,
                  streakDays: 0, // Placeholder
                ),

                const Divider(height: 32),

                // Opción: Jugar como invitado
                _buildSettingOption(
                  context: dialogContext,
                  icon: Icons.person_outline,
                  title: 'Jugar como invitado',
                  subtitle: 'Continuar sin cuenta',
                  onTap: () {},
                ),

                const Divider(height: 32),

                // Opción: Cambiar de cuenta
                _buildSettingOption(
                  context: dialogContext,
                  icon: Icons.swap_horiz,
                  title: 'Cambiar de cuenta',
                  subtitle: 'Iniciar sesión con otra cuenta',
                  onTap: () {},
                ),

                const SizedBox(height: 24),

                // Botón cerrar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext); // Cerrar el diálogo
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B3FF2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(
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
      },
    );
  }

  // Widget para la opción de tema con switch toggle
  static Widget _buildThemeOption({
    required BuildContext context,
    required SelectorTema themeProvider,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Ícono
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF7B3FF2).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.brightness_6,
              color: Color(0xFF7B3FF2),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tema oscuro',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  themeProvider.isDarkMode ? 'Activado' : 'Desactivado',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Switch toggle
          Switch(
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.cambiarTema();
            },
            activeThumbColor: const Color(0xFF7B3FF2),
            activeTrackColor: const Color(0xFF7B3FF2).withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  // Widget para mostrar la racha de días
  static Widget _buildStreakOption({
    required BuildContext context,
    required int streakDays,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Ícono
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF7B3FF2).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Color(0xFF7B3FF2),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Racha',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Días jugando consecutivos',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Contador de días
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF7B3FF2).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$streakDays días',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B3FF2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper para las opciones de ajustes
  static Widget _buildSettingOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Ícono
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF7B3FF2).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF7B3FF2),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Flecha
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
