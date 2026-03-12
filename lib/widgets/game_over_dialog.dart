import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/language_provider.dart';
import '../constants/app_strings.dart';
import '../config/app_colors.dart';
import '../config/audio_settings.dart';
import '../services/audio_service.dart';

/// Diálogo reutilizable para fin de juego (victoria o derrota).
/// Usado por todos los juegos de MINIFUN.
class GameOverDialog {
  static void show({
    required BuildContext context,
    required bool isVictory,
    required String message,
    required VoidCallback onRestart,
    required VoidCallback onExit,
    String? customTitle,
    String? restartLabel,
    VoidCallback? onNextLevel,
    String? nextLevelLabel,
    AudioSettings? audioSettings,
  }) {
    final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Reproducir sonido de victoria o derrota
    if (audioSettings != null) {
      final soundFile = isVictory ? 'Sonidos/victory.ogg' : 'Sonidos/defeat.ogg';
      AudioService.playSound(soundFile, audioSettings.sfxVolume);
    }

    final title = customTitle ??
        (isVictory
            ? '🎉 ${AppStrings.get('congratulations', currentLang)}'
            : '💀 ${AppStrings.get('game_over', currentLang)}');

    final primaryLabel = restartLabel ??
        (isVictory
            ? AppStrings.get('play_again', currentLang)
            : AppStrings.get('retry', currentLang));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false, // Bloquear gesto de deslizar para cerrar
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          builder: (context, animValue, child) {
            return Transform.scale(
              scale: 0.3 + (0.7 * animValue),
              child: Opacity(
                opacity: animValue,
                child: Transform.translate(
                  offset: Offset(0, 50 * (1 - animValue)),
                  child: Stack(
                    children: [
                      // Confetti particles si es victoria
                      if (isVictory) ..._buildConfetti(animValue),
                      // Dialog principal
                      child!,
                    ],
                  ),
                ),
              ),
            );
          },
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              // Título
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              // Mensaje
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              // Botón siguiente nivel (si existe)
              if (onNextLevel != null) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onNextLevel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColoresApp.verdeExito,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      nextLevelLabel ?? AppStrings.get('next_level', currentLang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              // Botón reintentar/jugar de nuevo
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: onRestart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColoresApp.moradoPrincipal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    primaryLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Botón salir
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: onExit,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: ColoresApp.rojoError),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppStrings.get('exit', currentLang),
                    style: TextStyle(
                      color: ColoresApp.rojoError,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
        ),
      ),
    );
  }

  static List<Widget> _buildConfetti(double animValue) {
    final confettiColors = [
      Colors.red,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.pink,
    ];

    return List.generate(20, (index) {
      final angle = (index / 20) * 6.28; // 360 grados en radianes
      final distance = 100 + (index % 3) * 30;
      final x = distance * (index % 2 == 0 ? 1 : -1) * (index / 20);
      final y = -50 - (index % 4) * 20 + (animValue * 150);

      return Positioned(
        left: MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first).size.width / 2 + x,
        top: MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first).size.height / 2 + y - 100,
        child: Transform.rotate(
          angle: angle * animValue * 3,
          child: Opacity(
            opacity: (1 - animValue).clamp(0.0, 1.0),
            child: Container(
              width: 8 + (index % 3) * 2,
              height: 8 + (index % 3) * 2,
              decoration: BoxDecoration(
                color: confettiColors[index % confettiColors.length],
                shape: index % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: index % 2 == 0 ? null : BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      );
    });
  }
}
