import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/boton_ajustes.dart';
import '../widgets/guia_juego_dialog.dart';
import '../constants/guias_juegos.dart';
import '../juegos/Snake.dart';
import '../juegos/Sudoku.dart';
import '../juegos/WaterSort.dart';
import '../juegos/buscaminas.dart';
import '../juegos/SopadeLetras.dart';
import '../juegos/ahorcado.dart';
import 'difficulty_selection_screen.dart';
import '../config/language_provider.dart';
import '../constants/app_strings.dart';
import '../constants/sopa_de_letras_constants.dart';
import '../constants/ahorcado_constants.dart';
import '../providers/auth_provider.dart';
import '../services/game_progress_service.dart';

// Pantalla de selección de modalidad de juego
class SeleccionModo extends StatefulWidget {
  final String gameTitle;    // Título localizado (solo para mostrar)
  final String gameKey;      // Clave interna no localizada para enrutamiento
  final String gameImagePath;

  const SeleccionModo({
    super.key,
    required this.gameTitle,
    required this.gameKey,
    required this.gameImagePath,
  });

  @override
  State<SeleccionModo> createState() => _SeleccionModoState();
}

class _SeleccionModoState extends State<SeleccionModo> {
  // Para evitar spam de SnackBar - mantener visible y reiniciar timer
  Timer? _snackBarTimer;
  bool _isSnackBarVisible = false;
  static const _snackBarDuration = Duration(seconds: 3);

  @override
  void dispose() {
    _snackBarTimer?.cancel();
    super.dispose();
  }

  void _showProLockedSnackBar(BuildContext context, String currentLang) {
    // Cancelar el timer anterior si existe
    _snackBarTimer?.cancel();

    // Si no hay SnackBar visible, mostrar uno nuevo
    if (!_isSnackBarVisible) {
      _isSnackBarVisible = true;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('pro_mode_locked', currentLang)),
          backgroundColor: const Color(0xFF7B3FF2),
          duration: const Duration(days: 1), // Duración muy larga, controlada por timer
        ),
      ).closed.then((_) {
        _isSnackBarVisible = false;
        _snackBarTimer?.cancel();
      });
    }

    // Iniciar/reiniciar el timer para cerrar el SnackBar
    _snackBarTimer = Timer(_snackBarDuration, () {
      if (_isSnackBarVisible) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });
  }

  String get gameTitle => widget.gameTitle;
  String get gameKey => widget.gameKey;
  String get gameImagePath => widget.gameImagePath;

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
                  // Header: Botón atrás y ajustes (Guía movida abajo)
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
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // 1. Botón Jugar (Play)
                        _buildModeButton(
                          height: buttonHeight,
                          icon: '🎮',
                          text: AppStrings.get('play', currentLang),
                          color: const Color(0xFF7B3FF2),
                          onTap: () {
                            if (gameKey == 'Snake') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SnakeGame()),
                              );
                            } else if (gameKey == 'Sopa de Letras') {
                              // Sopa de Letras usa sistema de niveles para modo normal
                              _showWordSearchLevelSelector(context);
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DifficultySelectionScreen(
                                    gameTitle: gameTitle,
                                    gameKey: gameKey,
                                    gameImagePath: gameImagePath,
                                  ),
                                ),
                              );
                            }
                          },
                        ),

                        // 2. Botón PRO (Supervivencia PRO / Perfecto PRO / Experto / etc.) - Oculto para invitados
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            // Ocultar para invitados
                            if (authProvider.isGuest) {
                              return const SizedBox.shrink();
                            }
                            final hasAccess = authProvider.isAdmin || authProvider.isPremium;
                            return Column(
                              children: [
                                SizedBox(height: spacing),
                                _buildModeButton(
                                  height: buttonHeight,
                                  icon: gameKey == 'Snake' ? '💀' : (gameKey == 'Buscaminas' ? '💣' : (gameKey == 'WaterSort' ? '🧪' : (gameKey == 'Ahorcado' ? '💀' : '💎'))),
                                  text: gameKey == 'Snake'
                                      ? AppStrings.get('survival_pro', currentLang)
                                      : (gameKey == 'Buscaminas'
                                          ? 'Experto'
                                          : (gameKey == 'WaterSort'
                                              ? AppStrings.get('hard_pro', currentLang)
                                              : (gameKey == 'Ahorcado'
                                                  ? AppStrings.get('hangman_survival', currentLang)
                                                  : AppStrings.get('perfect_pro', currentLang)))),
                                  color: hasAccess
                                      ? const Color.fromARGB(255, 255, 239, 98)
                                      : const Color.fromARGB(255, 180, 175, 130), // Amarillo grisáceo
                                  textColor: hasAccess ? Colors.black : Colors.grey[700]!,
                                  onTap: () {
                                    if (!hasAccess) {
                                      _showProLockedSnackBar(context, currentLang);
                                      return;
                                    }
                                    if (gameKey == 'Snake') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const SnakeGame(isSurvivalMode: true),
                                        ),
                                      );
                                    } else if (gameKey == 'Sudoku') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const SudokuGame(isPerfectMode: true),
                                        ),
                                      );
                                    } else if (gameKey == 'WaterSort') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const WaterSortGame(difficulty: 'dificil'),
                                        ),
                                      );
                                    } else if (gameKey == 'Buscaminas') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BuscaminasGame.dificil,
                                        ),
                                      );
                                    } else if (gameKey == 'Sopa de Letras') {
                                      _showThemeSelectionDialog(context, 'dificil', isPerfectMode: true);
                                    } else if (gameKey == 'Ahorcado') {
                                      _showHangmanThemeDialog(context, 'medio', isSurvivalMode: true);
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        ),

                        SizedBox(height: spacing),

                        // 3. Modalidades (Contrarreloj, Velocidad, Sin Banderas, etc.)
                        if (gameKey == 'Snake') ...[
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
                          SizedBox(height: spacing),
                          _buildModeButton(
                            height: buttonHeight,
                            icon: '⏱️',
                            text: AppStrings.get('time_attack', currentLang),
                            color: const Color(0xFF7B3FF2),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SnakeGame(isTimeAttackMode: true),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: spacing),
                        ],

                        if (gameKey == 'Buscaminas') ...[
                           _buildModeButton(
                            height: buttonHeight,
                            icon: '⏱️',
                            text: 'Contrarreloj',
                            color: const Color(0xFF7B3FF2),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BuscaminasGame.contrareloj,
                                ),
                              );
                            },
                          ),
                          SizedBox(height: spacing),
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              // Ocultar para invitados
                              if (authProvider.isGuest) {
                                return const SizedBox.shrink();
                              }
                              final hasAccess = authProvider.isAdmin || authProvider.isPremium;
                              return Column(
                                children: [
                                  _buildModeButton(
                                    height: buttonHeight,
                                    icon: '🏳️',
                                    text: 'Sin Banderas',
                                    color: hasAccess
                                        ? const Color.fromARGB(255, 255, 239, 98)
                                        : const Color.fromARGB(255, 180, 175, 130),
                                    textColor: hasAccess ? Colors.black : Colors.grey[700]!,
                                    onTap: () {
                                      if (!hasAccess) {
                                        _showProLockedSnackBar(context, currentLang);
                                        return;
                                      }
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const BuscaminasGame(isSinBanderas: true),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: spacing),
                                ],
                              );
                            },
                          ),
                        ],

                        if (gameKey == 'Sudoku') ...[
                          _buildModeButton(
                            height: buttonHeight,
                            icon: '⏱️',
                            text: AppStrings.get('time_attack', currentLang),
                            color: const Color(0xFF7B3FF2),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SudokuGame(isTimeAttackMode: true),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: spacing),
                        ],

                        if (gameKey == 'WaterSort') ...[
                          _buildModeButton(
                            height: buttonHeight,
                            icon: '⏱️',
                            text: AppStrings.get('time_attack', currentLang),
                            color: const Color(0xFF7B3FF2),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WaterSortGame(isTimeAttackMode: true),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: spacing),
                        ],

                        if (gameKey == 'Sopa de Letras') ...[
                          _buildModeButton(
                            height: buttonHeight,
                            icon: '⏱️',
                            text: AppStrings.get('time_attack', currentLang),
                            color: const Color(0xFF7B3FF2),
                            onTap: () {
                              _showThemeSelectionDialog(context, 'medio', isTimeAttackMode: true);
                            },
                          ),
                          SizedBox(height: spacing),
                        ],

                        if (gameKey == 'Ahorcado') ...[
                          _buildModeButton(
                            height: buttonHeight,
                            icon: '🚀',
                            text: AppStrings.get('hangman_speed', currentLang),
                            color: const Color(0xFF7B3FF2),
                            onTap: () {
                              _showHangmanThemeDialog(context, 'medio', isSpeedMode: true);
                            },
                          ),
                          SizedBox(height: spacing),
                        ],

                        // 4. Botón Guía (Guide)
                        _buildModeButton(
                          height: buttonHeight,
                          icon: '📖',
                          text: AppStrings.get('guide', currentLang),
                          color: const Color(0xFF7B3FF2),
                          onTap: () {
                            _openGuia(context, currentLang);
                          },
                        ),
                        SizedBox(height: spacing),
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

  // Método para abrir la guía del juego
  void _openGuia(BuildContext context, String currentLang) {
    String objetivo;
    List<String> instrucciones;
    List<ControlItem> controles;

    switch (gameKey) {
      case 'Snake':
        objetivo = AppStrings.get('snake_objective', currentLang);
        instrucciones = [
          AppStrings.get('snake_inst_1', currentLang),
          AppStrings.get('snake_inst_2', currentLang),
          AppStrings.get('snake_inst_3', currentLang),
          AppStrings.get('snake_inst_4', currentLang),
          AppStrings.get('snake_inst_5', currentLang),
        ];
        controles = GuiasJuegos.getSnakeControles(currentLang);
        break;
      case 'Sudoku':
        objetivo = AppStrings.get('sudoku_objective', currentLang);
        instrucciones = [
          AppStrings.get('sudoku_inst_1', currentLang),
          AppStrings.get('sudoku_inst_2', currentLang),
          AppStrings.get('sudoku_inst_3', currentLang),
          AppStrings.get('sudoku_inst_4', currentLang),
          AppStrings.get('sudoku_inst_5', currentLang),
          AppStrings.get('sudoku_inst_6', currentLang),
          AppStrings.get('sudoku_inst_7', currentLang),
          AppStrings.get('sudoku_inst_8', currentLang),
          AppStrings.get('sudoku_inst_9', currentLang),
        ];
        controles = GuiasJuegos.getSudokuControles(currentLang);
        break;
      case 'WaterSort':
        objetivo = AppStrings.get('watersort_objective', currentLang);
        instrucciones = [
          AppStrings.get('watersort_inst_1', currentLang),
          AppStrings.get('watersort_inst_2', currentLang),
          AppStrings.get('watersort_inst_3', currentLang),
          AppStrings.get('watersort_inst_4', currentLang),
          AppStrings.get('watersort_inst_5', currentLang),
          AppStrings.get('watersort_inst_6', currentLang),
          AppStrings.get('watersort_inst_7', currentLang),
        ];
        controles = GuiasJuegos.getWaterSortControles(currentLang);
        break;
      case 'Buscaminas':
        objetivo = AppStrings.get('minesweeper_objective', currentLang);
        instrucciones = [
          AppStrings.get('minesweeper_inst_1', currentLang),
          AppStrings.get('minesweeper_inst_2', currentLang),
          AppStrings.get('minesweeper_inst_3', currentLang),
          AppStrings.get('minesweeper_inst_4', currentLang),
          AppStrings.get('minesweeper_inst_5', currentLang),
        ];
        controles = GuiasJuegos.getBuscaminasControles(currentLang);
        break;
      case 'Sopa de Letras':
        objetivo = AppStrings.get('wordsearch_objective', currentLang);
        instrucciones = [
          AppStrings.get('wordsearch_inst_1', currentLang),
          AppStrings.get('wordsearch_inst_2', currentLang),
          AppStrings.get('wordsearch_inst_3', currentLang),
          AppStrings.get('wordsearch_inst_4', currentLang),
          AppStrings.get('wordsearch_inst_5', currentLang),
        ];
        controles = GuiasJuegos.getWordSearchControles(currentLang);
        break;
      case 'Ahorcado':
        objetivo = AppStrings.get('hangman_objective', currentLang);
        instrucciones = [
          AppStrings.get('hangman_inst_1', currentLang),
          AppStrings.get('hangman_inst_2', currentLang),
          AppStrings.get('hangman_inst_3', currentLang),
          AppStrings.get('hangman_inst_4', currentLang),
          AppStrings.get('hangman_inst_5', currentLang),
        ];
        controles = GuiasJuegos.getHangmanControles(currentLang);
        break;
      default:
        objetivo = '';
        instrucciones = [];
        controles = [];
    }

    GuiaJuegoDialog.show(
      context,
      gameTitle: gameTitle,
      gameImagePath: gameImagePath,
      objetivo: objetivo,
      instrucciones: instrucciones,
      controles: controles,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.get('select_theme', currentLang),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                ...ConstantesSopaLetras.tematicas.map((theme) {
                  String themeName = AppStrings.get('theme_$theme', currentLang);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(theme),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7B3FF2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          themeName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
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

  void _showHangmanThemeDialog(BuildContext context, String difficulty, {bool isSpeedMode = false, bool isSurvivalMode = false}) {
    final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.get('select_theme', currentLang),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                ...ConstantesAhorcado.tematicas.map((theme) {
                  String themeName = AppStrings.get('theme_$theme', currentLang);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(theme),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7B3FF2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          themeName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
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
              isSpeedMode: isSpeedMode,
              isSurvivalMode: isSurvivalMode,
            ),
          ),
        );
      }
    });
  }

  /// Mostrar selector de nivel y tema para Sopa de Letras modo normal
  void _showWordSearchLevelSelector(BuildContext context) async {
    final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Cargar progreso guardado
    int highestLevel = await GameProgressService.getHighestLevelLocal(ConstantesSopaLetras.gameType);

    if (!context.mounted) return;

    // Primero seleccionar temática
    final selectedTheme = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.get('select_theme', currentLang),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                ...ConstantesSopaLetras.tematicas.map((theme) {
                  String themeName = AppStrings.get('theme_$theme', currentLang);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(theme),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7B3FF2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          themeName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (selectedTheme == null || !context.mounted) return;

    // Luego seleccionar nivel
    final selectedLevel = await showDialog<int>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.get('select_level', currentLang),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  // highestLevel es el siguiente nivel, así que el completado es highestLevel - 1
                  highestLevel > 1
                      ? '${AppStrings.get('highest_level', currentLang)}: ${highestLevel - 1}'
                      : '', // No mostrar si no ha completado ninguno
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                // Mostrar niveles disponibles
                // highestLevel = siguiente nivel a jugar (1 = nunca jugó, 2 = completó nivel 1, etc.)
                SizedBox(
                  height: 250,
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: highestLevel, // Mostrar niveles 1 hasta highestLevel
                    itemBuilder: (context, index) {
                      final level = index + 1;
                      final isCompleted = level < highestLevel; // Niveles ya completados
                      final isNext = level == highestLevel; // Siguiente nivel a jugar
                      final config = ConstantesSopaLetras.getLevelConfig(level);

                      return GestureDetector(
                        onTap: () => Navigator.of(dialogContext).pop(level),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isNext
                                ? const Color(0xFF7B3FF2)
                                : isCompleted
                                    ? const Color(0xFF7B3FF2).withOpacity(0.7)
                                    : Colors.grey[400],
                            borderRadius: BorderRadius.circular(12),
                            border: isNext
                                ? Border.all(color: Colors.amber, width: 3)
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$level',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${config.gridSize}x${config.gridSize}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11,
                                ),
                              ),
                              if (isCompleted)
                                const Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedLevel == null || !context.mounted) return;

    // Navegar al juego con el nivel seleccionado
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WordSearchGame(
          theme: selectedTheme,
          level: selectedLevel,
        ),
      ),
    );
  }
}
