import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/language_provider.dart';
import '../constants/app_strings.dart';
import '../config/app_colors.dart';

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
  }) {
    final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;

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
      builder: (_) => AlertDialog(
        backgroundColor: ColoresApp.blanco,
        title: Text(
          title,
          style: TextStyle(color: ColoresApp.negro, fontWeight: FontWeight.bold),
        ),
        content: Text(message, style: TextStyle(color: ColoresApp.negro)),
        actions: [
          if (onNextLevel != null)
            TextButton(
              onPressed: onNextLevel,
              child: Text(
                nextLevelLabel ?? AppStrings.get('next_level', currentLang),
                style: TextStyle(color: ColoresApp.moradoPrincipal),
              ),
            ),
          TextButton(
            onPressed: onRestart,
            child: Text(primaryLabel, style: TextStyle(color: ColoresApp.moradoPrincipal)),
          ),
          TextButton(
            onPressed: onExit,
            child: Text(
              AppStrings.get('exit', currentLang),
              style: TextStyle(color: ColoresApp.rojoError),
            ),
          ),
        ],
      ),
    );
  }
}
