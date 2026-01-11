import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/boton_ajustes.dart';
import '../juegos/Snake.dart';
import '../juegos/sudoku.dart';
import '../juegos/WaterSort.dart';
import '../juegos/SopadeLetras.dart';
import '../widgets/guia_juego_dialog.dart';
import '../data/guias_juegos.dart';
import '../tema/language_provider.dart';
import '../constants/app_strings.dart';
import '../constants/sopa_de_letras_constants.dart';

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
    final currentLang = Provider.of<LanguageProvider>(context).currentLanguage;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calcular número de botones según el juego
            int buttonCount = 5; // Jugar, Guía + 3 modalidades

            // Distribución porcentual de la altura
            double availableHeight = constraints.maxHeight;
            double headerHeight = availableHeight * 0.08; // 8% para header (botones atrás/config)
            double titleHeight = availableHeight * 0.08; // 8% para título
            double imageHeight = availableHeight * 0.15; // 15% para imagen
            double buttonsAreaHeight = availableHeight * 0.65; // 65% para botones

            // Calcular altura de cada botón y espaciado
            double totalSpacing = buttonsAreaHeight * 0.15; // 15% del área de botones para espacios
            double spacing = totalSpacing / (buttonCount + 1);
            double buttonHeight = (buttonsAreaHeight - totalSpacing) / buttonCount;
            buttonHeight = buttonHeight.clamp(48.0, 65.0);

            // Tamaño de imagen adaptativo
            double imageSize = (imageHeight * 0.85).clamp(70.0, 110.0);

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth * 0.06,
                vertical: availableHeight * 0.015,
              ),
              child: Column(
                children: [
                  // Header: Botón atrás y ajustes
                  SizedBox(
                    height: headerHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios, size: 24),
                        ),
                        const BotonAjustes(),
                      ],
                    ),
                  ),

                  // Título
                  SizedBox(
                    height: titleHeight,
                    child: Center(
                      child: Text(
                        AppStrings.get('select_mode', currentLang),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: (titleHeight * 0.35).clamp(18.0, 26.0),
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),

                  // Imagen del juego
                  SizedBox(
                    height: imageHeight,
                    child: Center(
                      child: Container(
                        width: imageSize,
                        height: imageSize,
                        decoration: const BoxDecoration(
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
                    ),
                  ),

                  SizedBox(height: spacing),

                  // Botones de modalidad
                  Expanded(
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        // Botón Jugar
                        _buildModeButton(
                          height: buttonHeight,
                          icon: '🎮',
                          text: AppStrings.get('play', currentLang),
                          color: const Color(0xFF7B3FF2),
                          onTap: () {
                            if (gameTitle == 'Snake') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SnakeGame()),
                              );
                            } else if (gameTitle == 'Sudoku') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SudokuGame(difficulty: 'medio')),
                              );
                            } else if (gameTitle == 'WaterSort') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const WaterSortGame(difficulty: 'facil')),
                              );
                            } else if (gameTitle == 'Sopa de Letras') {
                              _showThemeSelectionDialog(context, 'facil');
                            }
                          },
                        ),

                        SizedBox(height: spacing),

                        // Botón Guía
                        _buildModeButton(
                          height: buttonHeight,
                          icon: '📖',
                          text: AppStrings.get('guide', currentLang),
                          color: const Color(0xFF7B3FF2),
                          onTap: () {
                            if (gameTitle == 'Snake') {
                              GuiaJuegoDialog.show(
                                context,
                                gameTitle: gameTitle,
                                gameImagePath: gameImagePath,
                                objetivo: AppStrings.get('snake_objective', currentLang),
                                instrucciones: [
                                  AppStrings.get('snake_inst_1', currentLang),
                                  AppStrings.get('snake_inst_2', currentLang),
                                  AppStrings.get('snake_inst_3', currentLang),
                                  AppStrings.get('snake_inst_4', currentLang),
                                  AppStrings.get('snake_inst_5', currentLang),
                                ],
                                controles: GuiasJuegos.getSnakeControles(currentLang),
                              );
                            } else if (gameTitle == 'Sudoku') {
                              GuiaJuegoDialog.show(
                                context,
                                gameTitle: gameTitle,
                                gameImagePath: gameImagePath,
                                objetivo: AppStrings.get('sudoku_objective', currentLang),
                                instrucciones: [
                                  AppStrings.get('sudoku_inst_1', currentLang),
                                  AppStrings.get('sudoku_inst_2', currentLang),
                                  AppStrings.get('sudoku_inst_3', currentLang),
                                  AppStrings.get('sudoku_inst_4', currentLang),
                                  AppStrings.get('sudoku_inst_5', currentLang),
                                  AppStrings.get('sudoku_inst_6', currentLang),
                                  AppStrings.get('sudoku_inst_7', currentLang),
                                  AppStrings.get('sudoku_inst_8', currentLang),
                                  AppStrings.get('sudoku_inst_9', currentLang),
                                ],
                                controles: GuiasJuegos.getSudokuControles(currentLang),
                              );
                            } else if (gameTitle == 'WaterSort') {
                              GuiaJuegoDialog.show(
                                context,
                                gameTitle: gameTitle,
                                gameImagePath: gameImagePath,
                                objetivo: AppStrings.get('watersort_objective', currentLang),
                                instrucciones: [
                                  AppStrings.get('watersort_inst_1', currentLang),
                                  AppStrings.get('watersort_inst_2', currentLang),
                                  AppStrings.get('watersort_inst_3', currentLang),
                                  AppStrings.get('watersort_inst_4', currentLang),
                                  AppStrings.get('watersort_inst_5', currentLang),
                                  AppStrings.get('watersort_inst_6', currentLang),
                                  AppStrings.get('watersort_inst_7', currentLang),
                                ],
                                controles: GuiasJuegos.getWaterSortControles(currentLang),
                              );
                            } else if (gameTitle == 'Sopa de Letras') {
                              GuiaJuegoDialog.show(
                                context,
                                gameTitle: gameTitle,
                                gameImagePath: gameImagePath,
                                objetivo: AppStrings.get('wordsearch_objective', currentLang),
                                instrucciones: [
                                  AppStrings.get('wordsearch_inst_1', currentLang),
                                  AppStrings.get('wordsearch_inst_2', currentLang),
                                  AppStrings.get('wordsearch_inst_3', currentLang),
                                  AppStrings.get('wordsearch_inst_4', currentLang),
                                  AppStrings.get('wordsearch_inst_5', currentLang),
                                ],
                                controles: GuiasJuegos.getWordSearchControles(currentLang),
                              );
                            }
                          },
                        ),

                        SizedBox(height: spacing),

                        // Botón Supervivencia PRO (Snake) / Perfecto PRO (Sudoku) / Difícil PRO (WaterSort)
                        _buildModeButton(
                          height: buttonHeight,
                          icon: gameTitle == 'Snake' ? '💀' : (gameTitle == 'WaterSort' ? '🧪' : '💎'),
                          text: gameTitle == 'Snake'
                              ? AppStrings.get('survival_pro', currentLang)
                              : (gameTitle == 'WaterSort'
                                  ? AppStrings.get('hard_pro', currentLang)
                                  : AppStrings.get('perfect_pro', currentLang)),
                          color: const Color.fromARGB(255, 255, 239, 98),
                          textColor: Colors.black,
                          onTap: () {
                            if (gameTitle == 'Snake') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SnakeGame(isSurvivalMode: true),
                                ),
                              );
                            } else if (gameTitle == 'Sudoku') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SudokuGame(isPerfectMode: true),
                                ),
                              );
                            } else if (gameTitle == 'WaterSort') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WaterSortGame(difficulty: 'dificil'),
                                ),
                              );
                            } else if (gameTitle == 'Sopa de Letras') {
                              _showThemeSelectionDialog(context, 'dificil');
                            }
                          },
                        ),

                        SizedBox(height: spacing),

                        // Botón Velocidad (solo Snake)
                        if (gameTitle == 'Snake')
                          _buildModeButton(
                            height: buttonHeight,
                            icon: '🚀',
                            text: AppStrings.get('speed', currentLang),
                            color: const Color(0xFF7B3FF2),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SnakeGame(speedMultiplier: 1.25),
                                ),
                              );
                            },
                          ),

                        if (gameTitle == 'Snake') SizedBox(height: spacing),

                        // Botón Contrarreloj
                        _buildModeButton(
                          height: buttonHeight,
                          icon: '⏱️',
                          text: AppStrings.get('time_attack', currentLang),
                          color: const Color(0xFF7B3FF2),
                          onTap: () {
                            if (gameTitle == 'Snake') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SnakeGame(isTimeAttackMode: true),
                                ),
                              );
                            } else if (gameTitle == 'Sudoku') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SudokuGame(isTimeAttackMode: true),
                                ),
                              );
                            } else if (gameTitle == 'WaterSort') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WaterSortGame(isTimeAttackMode: true),
                                ),
                              );
                            } else if (gameTitle == 'Sopa de Letras') {
                              _showThemeSelectionDialog(context, 'medio', isTimeAttackMode: true);
                            }
                          },
                        ),

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

  // Widget helper para crear los botones de modalidad
  Widget _buildModeButton({
    required double height,
    required String icon,
    required String text,
    required Color color,
    Color textColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: TextStyle(fontSize: (height * 0.35).clamp(18.0, 24.0)),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: (height * 0.28).clamp(14.0, 18.0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSelectionDialog(BuildContext context, String difficulty, {bool isTimeAttackMode = false, bool isPerfectMode = false}) {
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
                onTap: () {
                  Navigator.of(context).pop(theme);
                },
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
              isTimeAttackMode: isTimeAttackMode,
              isPerfectMode: isPerfectMode,
            ),
          ),
        );
      }
    });
  }
}
