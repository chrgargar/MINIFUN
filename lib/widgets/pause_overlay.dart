import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tema/language_provider.dart';
import '../constants/app_strings.dart';
import '../tema/app_colors.dart';

/// Widget de overlay que se muestra cuando el juego está pausado
class PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final currentLang = Provider.of<LanguageProvider>(context).currentLanguage;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2D1B3D) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ColoresApp.moradoPrincipal.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de pausa
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColoresApp.moradoPrincipal.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.pause_rounded,
                  size: 48,
                  color: ColoresApp.moradoPrincipal,
                ),
              ),
              const SizedBox(height: 16),

              // Título
              Text(
                AppStrings.get('paused', currentLang),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),

              // Subtítulo
              Text(
                AppStrings.get('game_paused', currentLang),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 24),

              // Botón Continuar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onResume,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(AppStrings.get('resume', currentLang)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColoresApp.moradoPrincipal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Botón Reiniciar
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(AppStrings.get('restart', currentLang)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColoresApp.moradoPrincipal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: ColoresApp.moradoPrincipal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Botón Salir
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: onExit,
                  icon: Icon(Icons.exit_to_app_rounded, color: ColoresApp.rojoError),
                  label: Text(
                    AppStrings.get('exit', currentLang),
                    style: TextStyle(color: ColoresApp.rojoError),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
