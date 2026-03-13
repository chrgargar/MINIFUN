import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../config/language_provider.dart';
import '../constants/app_strings.dart';
import '../config/app_colors.dart';
import '../config/audio_settings.dart';
import '../services/audio_service.dart';

/// Diálogo reutilizable para fin de juego (victoria o derrota).
/// Usado por todos los juegos de MINIFUN.
/// Usa flutter_animate para animaciones y confetti_widget para celebraciones.
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
    String? soundToPlay, // Sonido a reproducir instantáneamente
  }) {
    final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final title = customTitle ??
        (isVictory
            ? '${AppStrings.get('congratulations', currentLang)}'
            : '${AppStrings.get('game_over', currentLang)}');

    final primaryLabel = restartLabel ??
        (isVictory
            ? AppStrings.get('play_again', currentLang)
            : AppStrings.get('retry', currentLang));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _GameOverDialogContent(
        isVictory: isVictory,
        title: title,
        message: message,
        primaryLabel: primaryLabel,
        onRestart: onRestart,
        onExit: onExit,
        onNextLevel: onNextLevel,
        nextLevelLabel: nextLevelLabel,
        currentLang: currentLang,
        isDark: isDark,
        audioSettings: audioSettings,
        soundToPlay: soundToPlay,
      ),
    );
  }
}

class _GameOverDialogContent extends StatefulWidget {
  final bool isVictory;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onRestart;
  final VoidCallback onExit;
  final VoidCallback? onNextLevel;
  final String? nextLevelLabel;
  final String currentLang;
  final bool isDark;
  final AudioSettings? audioSettings;
  final String? soundToPlay;

  const _GameOverDialogContent({
    required this.isVictory,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onRestart,
    required this.onExit,
    this.onNextLevel,
    this.nextLevelLabel,
    required this.currentLang,
    required this.isDark,
    this.audioSettings,
    this.soundToPlay,
  });

  @override
  State<_GameOverDialogContent> createState() => _GameOverDialogContentState();
}

class _GameOverDialogContentState extends State<_GameOverDialogContent> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    // Reproducir sonido INSTANTÁNEAMENTE al crear el diálogo
    if (widget.soundToPlay != null && widget.audioSettings != null) {
      AudioService.playSound(widget.soundToPlay!, widget.audioSettings!.sfxVolume);
    }

    // Iniciar confetti si es victoria
    if (widget.isVictory) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Confetti en victoria
          if (widget.isVictory)
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.red,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.purple,
                Colors.orange,
                Colors.pink,
              ],
              numberOfParticles: 30,
              gravity: 0.2,
              emissionFrequency: 0.05,
              maxBlastForce: 20,
              minBlastForce: 8,
            ),

          // Diálogo principal con animación
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono animado
                  _buildAnimatedIcon(),
                  const SizedBox(height: 16),

                  // Título con animación
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: widget.isDark ? Colors.white : Colors.black,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: -0.2, end: 0),

                  const SizedBox(height: 12),

                  // Mensaje con animación
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms),

                  const SizedBox(height: 24),

                  // Botones con animación escalonada
                  ..._buildButtons(),
                ],
              ),
            ),
          )
          .animate()
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            duration: 300.ms,
            curve: Curves.easeOutBack,
          )
          .fadeIn(duration: 200.ms),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    final icon = widget.isVictory ? Icons.emoji_events : Icons.sentiment_dissatisfied;
    final color = widget.isVictory ? Colors.amber : ColoresApp.rojoError;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 48,
        color: color,
      ),
    )
    .animate(onPlay: (controller) => controller.repeat(reverse: true))
    .scale(
      begin: const Offset(1, 1),
      end: const Offset(1.1, 1.1),
      duration: 800.ms,
      curve: Curves.easeInOut,
    );
  }

  List<Widget> _buildButtons() {
    final buttons = <Widget>[];
    int delay = 500;

    // Botón siguiente nivel (si existe)
    if (widget.onNextLevel != null) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: widget.onNextLevel,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColoresApp.verdeExito,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              widget.nextLevelLabel ?? AppStrings.get('next_level', widget.currentLang),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 300.ms)
        .slideX(begin: 0.2, end: 0),
      );
      buttons.add(const SizedBox(height: 12));
      delay += 100;
    }

    // Botón reintentar/jugar de nuevo
    buttons.add(
      SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: widget.onRestart,
          style: ElevatedButton.styleFrom(
            backgroundColor: ColoresApp.moradoPrincipal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            widget.primaryLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      )
      .animate()
      .fadeIn(delay: Duration(milliseconds: delay), duration: 300.ms)
      .slideX(begin: 0.2, end: 0),
    );
    buttons.add(const SizedBox(height: 12));
    delay += 100;

    // Botón salir
    buttons.add(
      SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton(
          onPressed: widget.onExit,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: ColoresApp.rojoError),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            AppStrings.get('exit', widget.currentLang),
            style: TextStyle(
              color: ColoresApp.rojoError,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      )
      .animate()
      .fadeIn(delay: Duration(milliseconds: delay), duration: 300.ms)
      .slideX(begin: 0.2, end: 0),
    );

    return buttons;
  }
}
