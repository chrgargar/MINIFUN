import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/language_provider.dart';
import '../constants/app_strings.dart';
import '../config/app_colors.dart';
import '../widgets/boton_ajustes.dart';
import '../juegos/Sudoku.dart';
import '../juegos/WaterSort.dart';
import '../juegos/SopadeLetras.dart';
import '../juegos/ahorcado.dart';
import '../juegos/buscaminas.dart';
import '../constants/sopa_de_letras_constants.dart';
import '../constants/ahorcado_constants.dart';
import '../providers/auth_provider.dart';

class DifficultySelectionScreen extends StatelessWidget {
  final String gameTitle;    // Título localizado (solo para mostrar)
  final String gameKey;      // Clave interna no localizada para enrutamiento
  final String gameImagePath;

  const DifficultySelectionScreen({
    super.key,
    required this.gameTitle,
    required this.gameKey,
    required this.gameImagePath,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLang = Provider.of<LanguageProvider>(context).currentLanguage;

    return Scaffold(
      backgroundColor: isDark ? ColoresApp.negro : ColoresApp.blanco,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double availableHeight = constraints.maxHeight;
            double headerHeight = availableHeight * 0.08;
            double titleHeight = availableHeight * 0.12;
            double buttonsAreaHeight = availableHeight * 0.75;

            double totalSpacing = buttonsAreaHeight * 0.15;
            double spacing = totalSpacing / 4;
            double buttonHeight = (buttonsAreaHeight - totalSpacing) / 4;
            buttonHeight = buttonHeight.clamp(60.0, 90.0);

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth * 0.06,
                vertical: availableHeight * 0.015,
              ),
              child: Column(
                children: [
                  // Header
                  SizedBox(
                    height: headerHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back_ios, size: 24, color: isDark ? Colors.white : Colors.black),
                        ),
                        const BotonAjustes(),
                      ],
                    ),
                  ),

                  // Title
                  SizedBox(
                    height: titleHeight,
                    child: Center(
                      child: Text(
                        AppStrings.get('select_difficulty', currentLang),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: (titleHeight * 0.35).clamp(20.0, 28.0),
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: spacing),

                  // Difficulty Buttons
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildDifficultyButton(
                          context: context,
                          height: buttonHeight,
                          difficulty: 'facil',
                          text: AppStrings.get('easy', currentLang),
                          description: _getDifficultyDescription(context, 'facil'),
                          color: const Color(0xFF7B3FF2),
                        ),
                        SizedBox(height: spacing),
                        _buildDifficultyButton(
                          context: context,
                          height: buttonHeight,
                          difficulty: 'medio',
                          text: AppStrings.get('medium', currentLang),
                          description: _getDifficultyDescription(context, 'medio'),
                          color: const Color(0xFF7B3FF2),
                        ),
                        SizedBox(height: spacing),
                        _buildDifficultyButton(
                          context: context,
                          height: buttonHeight,
                          difficulty: 'dificil',
                          text: AppStrings.get('hard', currentLang),
                          description: _getDifficultyDescription(context, 'dificil'),
                          color: const Color(0xFF7B3FF2),
                        ),
                        
                        // Botón Extra (PRO / Experto) si aplica
                        if (gameKey == 'Buscaminas') ...[
                          SizedBox(height: spacing),
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              final hasAccess = authProvider.isAdmin || authProvider.isPremium;
                              return _buildDifficultyButton(
                                context: context,
                                height: buttonHeight * 0.9,
                                difficulty: 'extremo',
                                text: 'Extremo PRO',
                                description: '35x35 - 300 minas',
                                color: hasAccess
                                    ? const Color(0xFF7B3FF2)
                                    : const Color.fromARGB(255, 140, 130, 180), // Morado grisáceo
                                isLocked: !hasAccess,
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _getDifficultyDescription(BuildContext context, String difficulty) {
    final lang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;
    final suffix = difficulty == 'facil' ? 'easy' : difficulty == 'medio' ? 'medium' : 'hard';

    switch (gameKey) {
      case 'Buscaminas':
        return AppStrings.get('diff_minesweeper_$suffix', lang);
      case 'Sudoku':
        return AppStrings.get('diff_sudoku_$suffix', lang);
      case 'WaterSort':
        return AppStrings.get('diff_watersort_$suffix', lang);
      case 'Sopa de Letras':
        return AppStrings.get('diff_wordsearch_$suffix', lang);
      case 'Ahorcado':
        return AppStrings.get('diff_hangman_$suffix', lang);
      default:
        return '';
    }
  }

  Widget _buildDifficultyButton({
    required BuildContext context,
    required double height,
    required String difficulty,
    required String text,
    required String description,
    required Color color,
    bool isLocked = false,
  }) {
    final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;

    return GestureDetector(
      onTap: () {
        if (isLocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.get('pro_mode_locked', currentLang)),
              backgroundColor: const Color(0xFF7B3FF2),
            ),
          );
          return;
        }
        _onDifficultySelected(context, difficulty);
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: height * 0.28,
                        fontWeight: FontWeight.bold,
                        color: isLocked ? Colors.grey[300] : Colors.white,
                      ),
                    ),
                    if (description.isNotEmpty)
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: height * 0.18,
                          color: isLocked
                              ? Colors.grey[400]!.withOpacity(0.9)
                              : Colors.white.withOpacity(0.9),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                isLocked ? Icons.lock : Icons.arrow_forward_ios,
                color: isLocked ? Colors.grey[300] : Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onDifficultySelected(BuildContext context, String difficulty) {
    if (gameKey == 'Sudoku') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SudokuGame(difficulty: difficulty)),
      );
    } else if (gameKey == 'WaterSort') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WaterSortGame(difficulty: difficulty)),
      );
    } else if (gameKey == 'Buscaminas') {
      if (difficulty == 'facil') {
        Navigator.push(context, MaterialPageRoute(builder: (context) => BuscaminasGame.facil));
      } else if (difficulty == 'medio') {
        Navigator.push(context, MaterialPageRoute(builder: (context) => BuscaminasGame.medio));
      } else if (difficulty == 'dificil') {
        Navigator.push(context, MaterialPageRoute(builder: (context) => BuscaminasGame.dificil));
      } else if (difficulty == 'extremo') {
        Navigator.push(context, MaterialPageRoute(builder: (context) => BuscaminasGame.extremo));
      }
    } else if (gameKey == 'Sopa de Letras') {
      _showThemeSelectionDialog(context, difficulty);
    } else if (gameKey == 'Ahorcado') {
      _showHangmanThemeDialog(context, difficulty);
    }
  }

  void _showThemeSelectionDialog(BuildContext context, String difficulty) {
    final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;

    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppStrings.get('select_theme', currentLang)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ConstantesSopaLetras.tematicas.map((theme) {
              String themeName = AppStrings.get('theme_$theme', currentLang);
              return ListTile(
                title: Text(themeName),
                onTap: () => Navigator.of(context).pop(theme),
              );
            }).toList(),
          ),
        );
      },
    ).then((selectedTheme) {
      if (selectedTheme != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WordSearchGame(
              difficulty: difficulty,
              theme: selectedTheme,
            ),
          ),
        );
      }
    });
  }

  void _showHangmanThemeDialog(BuildContext context, String difficulty) {
    final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;

    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppStrings.get('select_theme', currentLang)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ConstantesAhorcado.tematicas.map((theme) {
              String themeName = AppStrings.get('theme_$theme', currentLang);
              return ListTile(
                title: Text(themeName),
                onTap: () => Navigator.of(context).pop(theme),
              );
            }).toList(),
          ),
        );
      },
    ).then((selectedTheme) {
      if (selectedTheme != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AhorcadoGame(
              difficulty: difficulty,
              theme: selectedTheme,
            ),
          ),
        );
      }
    });
  }
}
