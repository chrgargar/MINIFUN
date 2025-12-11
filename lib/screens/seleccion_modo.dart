import 'package:flutter/material.dart';
import '../widgets/boton_ajustes.dart';
import '../juegos/Snake.dart';
import '../juegos/buscaminas.dart';
import '../juegos/sudoku.dart';
import '../juegos/WaterSort.dart';
import '../widgets/guia_juego_dialog.dart';
import '../data/guias_juegos.dart';

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
                        'Selecciona\nModalidad',
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
                          text: 'Jugar',
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
                            } else if (gameTitle == 'Buscaminas') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const BuscaminasGame()),
                              );
                            }
                          },
                        ),

                        SizedBox(height: spacing),

                        // Dificultades para Buscaminas
                        if (gameTitle == 'Buscaminas') ...[
                          _buildModeButton(
                            height: buttonHeight,
                            icon: '🟩',
                            text: 'Fácil',
                            color: const Color(0xFF7B3FF2),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const BuscaminasGame(rows: 9, cols: 9, mineCount: 10)),
                              );
                            },
                          ),

                          SizedBox(height: spacing),

                          _buildModeButton(
                            height: buttonHeight,
                            icon: '🟨',
                            text: 'Medio',
                            color: const Color(0xFF7B3FF2),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const BuscaminasGame(rows: 16, cols: 16, mineCount: 40)),
                              );
                            },
                          ),

                          SizedBox(height: spacing),

                          _buildModeButton(
                            height: buttonHeight,
                            icon: '🔥',
                            text: 'Difícil',
                            color: const Color(0xFF7B3FF2),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const BuscaminasGame(rows: 16, cols: 30, mineCount: 99)),
                              );
                            },
                          ),

                          SizedBox(height: spacing),
                        ],

                        // Botón Guía
                        _buildModeButton(
                          height: buttonHeight,
                          icon: '📖',
                          text: 'Guía',
                          color: const Color(0xFF7B3FF2),
                          onTap: () {
                            if (gameTitle == 'Snake') {
                              GuiaJuegoDialog.show(
                                context,
                                gameTitle: gameTitle,
                                gameImagePath: gameImagePath,
                                objetivo: GuiasJuegos.snakeObjetivo,
                                instrucciones: GuiasJuegos.snakeInstrucciones,
                                controles: GuiasJuegos.snakeControles,
                              );
                            } else if (gameTitle == 'Sudoku') {
                              GuiaJuegoDialog.show(
                                context,
                                gameTitle: gameTitle,
                                gameImagePath: gameImagePath,
                                objetivo: GuiasJuegos.sudokuObjetivo,
                                instrucciones: GuiasJuegos.sudokuInstrucciones,
                                controles: GuiasJuegos.sudokuControles,
                              );
                            } else if (gameTitle == 'WaterSort') {
                              GuiaJuegoDialog.show(
                                context,
                                gameTitle: gameTitle,
                                gameImagePath: gameImagePath,
                                objetivo: GuiasJuegos.waterSortObjetivo,
                                instrucciones: GuiasJuegos.waterSortInstrucciones,
                                controles: GuiasJuegos.waterSortControles,
                              );
                            } else if (gameTitle == 'Buscaminas') {
                              GuiaJuegoDialog.show(
                                context,
                                gameTitle: gameTitle,
                                gameImagePath: gameImagePath,
                                objetivo: GuiasJuegos.buscaminasObjetivo,
                                instrucciones: GuiasJuegos.buscaminasInstrucciones,
                                controles: GuiasJuegos.buscaminasControles,
                              );
                            }
                          },
                        ),

                        SizedBox(height: spacing),

                        // Botón Supervivencia PRO (Snake) / Extremo PRO (Sudoku) / Difícil PRO (WaterSort)
                        _buildModeButton(
                          height: buttonHeight,
                          icon: gameTitle == 'Snake' ? '💀' : (gameTitle == 'WaterSort' ? '🧪' : '🔥'),
                          text: gameTitle == 'Snake' ? 'Supervivencia\nPRO' : (gameTitle == 'WaterSort' ? 'Difícil\nPRO' : 'Extremo\nPRO'),
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
                                  builder: (context) => const SudokuGame(difficulty: 'dificil'),
                                ),
                              );
                            } else if (gameTitle == 'WaterSort') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WaterSortGame(difficulty: 'dificil'),
                                ),
                              );
                            }
                          },
                        ),

                        SizedBox(height: spacing),

                        // Botón Velocidad (solo Snake)
                        if (gameTitle == 'Snake')
                          _buildModeButton(
                            height: buttonHeight,
                            icon: '🚀',
                            text: 'Velocidad',
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
                          text: 'Contrarreloj',
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
                            }
                          },
                        ),

                        // Botón Modo Perfecto (solo para Sudoku)
                        if (gameTitle == 'Sudoku') ...[
                          SizedBox(height: spacing),
                          _buildModeButton(
                            height: buttonHeight,
                            icon: '💎',
                            text: 'Perfecto',
                            color: const Color(0xFF7B3FF2),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SudokuGame(isPerfectMode: true),
                                ),
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
}
