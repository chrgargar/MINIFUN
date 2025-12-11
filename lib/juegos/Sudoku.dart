import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tema/audio_settings.dart';
import '../tema/app_colors.dart';
import '../tema/language_provider.dart';
import '../constants/app_strings.dart';
import '../services/audio_service.dart';
import '../constants/sudoku_constants.dart';

class SudokuGame extends StatefulWidget {
  final String difficulty; // 'facil', 'medio', 'dificil'
  final bool isTimeAttackMode; // Modo contrarreloj
  final bool isPerfectMode; // Modo perfecto (sin errores)

  const SudokuGame({
    super.key,
    this.difficulty = 'facil',
    this.isTimeAttackMode = false,
    this.isPerfectMode = false,
  });

  @override
  State<SudokuGame> createState() => _SudokuGameState();
}

class _SudokuGameState extends State<SudokuGame> {
  // Tablero principal de Sudoku (0 = celda vacía)
  List<List<int>> board = List.generate(ConstantesSudoku.tamanoSudoku, (_) => List.filled(ConstantesSudoku.tamanoSudoku, ConstantesSudoku.valorCeldaVacia));
  List<List<int>> solution = List.generate(ConstantesSudoku.tamanoSudoku, (_) => List.filled(ConstantesSudoku.tamanoSudoku, ConstantesSudoku.valorCeldaVacia));
  List<List<bool>> isFixed = List.generate(ConstantesSudoku.tamanoSudoku, (_) => List.filled(ConstantesSudoku.tamanoSudoku, false));
  List<List<bool>> isError = List.generate(ConstantesSudoku.tamanoSudoku, (_) => List.filled(ConstantesSudoku.tamanoSudoku, false));

  // Celda seleccionada actualmente
  int? selectedRow;
  int? selectedCol;
  int selectedNumber = ConstantesSudoku.valorMinimoCelda;

  // Timer del juego
  Timer? gameTimer;

  // Variables de tiempo
  int elapsedSeconds = 0; // Tiempo transcurrido (modo normal)
  int timeLeft = ConstantesSudoku.duracionContrarreloj;

  // Variables de progreso
  int cellsFilled = 0; // Celdas correctamente rellenadas
  int totalEmptyCells = 0; // Total de celdas vacías al inicio
  int errorsCount = 0; // Contador de errores (modo perfecto)

  // Modo de escritura: true = lápiz (valida), false = notas (no valida)
  bool isPencilMode = true;

  // Notas de borrador para cada celda (modo notas)
  List<List<List<int>>> pencilNotes = List.generate(ConstantesSudoku.tamanoSudoku, (_) => List.generate(ConstantesSudoku.tamanoSudoku, (_) => []));

  @override
  void initState() {
    super.initState();
    _generateSudoku();
    _startTimer();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (widget.isTimeAttackMode) {
          timeLeft--;
          if (timeLeft <= 0) {
            timer.cancel();
            _gameOver(false);
          }
        } else {
          elapsedSeconds++;
        }
      });
    });
  }

  Future<void> _playSound(String sound) async {
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    await AudioService.playSound('Sonidos/$sound', audioSettings.sfxVolume);
  }

  void _generateSudoku() {
    // Generar una solución válida
    _fillBoard(solution);

    // Copiar la solución al tablero
    for (int i = 0; i < ConstantesSudoku.tamanoSudoku; i++) {
      for (int j = 0; j < ConstantesSudoku.tamanoSudoku; j++) {
        board[i][j] = solution[i][j];
        isFixed[i][j] = true;
      }
    }

    // Determinar cuántas celdas quitar según la dificultad
    int cellsToRemove;
    switch (widget.difficulty) {
      case 'facil':
        cellsToRemove = ConstantesSudoku.celdasEliminadasFacil;
        break;
      case 'medio':
        cellsToRemove = ConstantesSudoku.celdasEliminadasMedio;
        break;
      case 'dificil':
        cellsToRemove = ConstantesSudoku.celdasEliminadasDificil;
        break;
      default:
        cellsToRemove = ConstantesSudoku.celdasEliminadasFacil;
    }

    totalEmptyCells = cellsToRemove;

    // Quitar celdas aleatoriamente
    final random = Random();
    int removed = 0;
    while (removed < cellsToRemove) {
      int row = random.nextInt(ConstantesSudoku.tamanoSudoku);
      int col = random.nextInt(ConstantesSudoku.tamanoSudoku);
      if (isFixed[row][col]) {
        board[row][col] = ConstantesSudoku.valorCeldaVacia;
        isFixed[row][col] = false;
        removed++;
      }
    }
  }

  bool _fillBoard(List<List<int>> board) {
    for (int row = 0; row < ConstantesSudoku.tamanoSudoku; row++) {
      for (int col = 0; col < ConstantesSudoku.tamanoSudoku; col++) {
        if (board[row][col] == ConstantesSudoku.valorCeldaVacia) {
          final numbers = List.generate(ConstantesSudoku.tamanoSudoku, (i) => i + ConstantesSudoku.valorMinimoCelda)..shuffle();
          for (int num in numbers) {
            if (_isValidMove(board, row, col, num)) {
              board[row][col] = num;
              if (_fillBoard(board)) {
                return true;
              }
              board[row][col] = ConstantesSudoku.valorCeldaVacia;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool _isValidMove(List<List<int>> board, int row, int col, int num) {
    // Verificar fila
    for (int i = 0; i < ConstantesSudoku.tamanoSudoku; i++) {
      if (board[row][i] == num) return false;
    }

    // Verificar columna
    for (int i = 0; i < ConstantesSudoku.tamanoSudoku; i++) {
      if (board[i][col] == num) return false;
    }

    // Verificar subcuadrícula 3x3
    int boxRow = (row ~/ ConstantesSudoku.tamanoCaja) * ConstantesSudoku.tamanoCaja;
    int boxCol = (col ~/ ConstantesSudoku.tamanoCaja) * ConstantesSudoku.tamanoCaja;
    for (int i = boxRow; i < boxRow + ConstantesSudoku.tamanoCaja; i++) {
      for (int j = boxCol; j < boxCol + ConstantesSudoku.tamanoCaja; j++) {
        if (board[i][j] == num) return false;
      }
    }

    return true;
  }

  void _placeNumber(int number) {
    if (selectedRow == null || selectedCol == null) return;
    if (isFixed[selectedRow!][selectedCol!]) return;

    setState(() {
      if (isPencilMode) {
        // MODO LÁPIZ: Validar y colocar número definitivo
        // Limpiar error anterior
        isError[selectedRow!][selectedCol!] = false;
        // Limpiar notas de borrador
        pencilNotes[selectedRow!][selectedCol!].clear();

        // Si ya había un número, decrementar el contador
        if (board[selectedRow!][selectedCol!] != 0) {
          cellsFilled--;
        }

        board[selectedRow!][selectedCol!] = number;

        // Verificar si es correcto
        if (number == solution[selectedRow!][selectedCol!]) {
          _playSound('food.mp3');
          cellsFilled++;

          // Verificar si ganó
          if (cellsFilled == totalEmptyCells) {
            gameTimer?.cancel();
            _gameOver(true);
          }
        } else {
          // Error
          _playSound('obstaculo.mp3');
          isError[selectedRow!][selectedCol!] = true;
          errorsCount++;

          // En modo perfecto, terminar el juego
          if (widget.isPerfectMode && errorsCount > 0) {
            gameTimer?.cancel();
            _gameOver(false);
          }
        }
      } else {
        // MODO BORRADOR: Agregar/quitar notas sin validar
        // Limpiar número definitivo si existe
        if (board[selectedRow!][selectedCol!] != 0) {
          cellsFilled--;
          board[selectedRow!][selectedCol!] = 0;
        }
        isError[selectedRow!][selectedCol!] = false;

        // Toggle nota: si existe, quitarla; si no existe, agregarla
        if (pencilNotes[selectedRow!][selectedCol!].contains(number)) {
          pencilNotes[selectedRow!][selectedCol!].remove(number);
        } else {
          pencilNotes[selectedRow!][selectedCol!].add(number);
          pencilNotes[selectedRow!][selectedCol!].sort();
        }
        _playSound('move.mp3');
      }
    });
  }

  void _clearCell() {
    if (selectedRow == null || selectedCol == null) return;
    if (isFixed[selectedRow!][selectedCol!]) return;

    setState(() {
      if (board[selectedRow!][selectedCol!] != 0) {
        cellsFilled--;
      }
      board[selectedRow!][selectedCol!] = 0;
      isError[selectedRow!][selectedCol!] = false;
      // También limpiar las notas de borrador
      pencilNotes[selectedRow!][selectedCol!].clear();
    });
  }

  void _showHint() {
    // Buscar una celda vacía y mostrar el número correcto
    for (int i = 0; i < ConstantesSudoku.tamanoSudoku; i++) {
      for (int j = 0; j < ConstantesSudoku.tamanoSudoku; j++) {
        if (!isFixed[i][j] && board[i][j] != solution[i][j]) {
          setState(() {
            board[i][j] = solution[i][j];
            isError[i][j] = false;
            if (board[i][j] != ConstantesSudoku.valorCeldaVacia) {
              cellsFilled++;
            }
            selectedRow = i;
            selectedCol = j;
          });
          _playSound('food.mp3');

          // Verificar si ganó después de usar la pista
          if (cellsFilled == totalEmptyCells) {
            gameTimer?.cancel();
            _gameOver(true);
          }
          return;
        }
      }
    }
  }

  void _gameOver(bool won) {
    final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;

    String title = won
        ? AppStrings.get('congratulations', currentLang)
        : AppStrings.get('game_over', currentLang);
    String message = won
        ? '${AppStrings.get('completed_in', currentLang)} ${_formatTime(elapsedSeconds)}'
        : widget.isPerfectMode
            ? AppStrings.get('made_error', currentLang)
            : widget.isTimeAttackMode
                ? AppStrings.get('time_up', currentLang)
                : AppStrings.get('try_again', currentLang);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              won ? Icons.emoji_events : Icons.close_rounded,
              color: won ? const Color(0xFF7B3FF2) : Colors.red,
              size: 32,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: won ? const Color(0xFF7B3FF2) : Colors.red,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            if (won) ...[
              const SizedBox(height: 16),
              Text(
                AppStrings.get('what_to_do', currentLang),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Volver al menú
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
            ),
            child: Text(AppStrings.get('exit_menu', currentLang)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              setState(() {
                _generateSudoku();
                cellsFilled = 0;
                errorsCount = 0;
                elapsedSeconds = 0;
                timeLeft = ConstantesSudoku.duracionContrarreloj;
                selectedRow = null;
                selectedCol = null;
              });
              _startTimer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColoresApp.moradoPrincipal,
              foregroundColor: ColoresApp.blanco,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(won
                ? AppStrings.get('play_again', currentLang)
                : AppStrings.get('retry', currentLang)),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildPencilNotes(List<int> notes) {
    // Mostrar las notas en una cuadrícula 3x3 pequeña
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 1,
          crossAxisSpacing: 1,
        ),
        itemCount: ConstantesSudoku.tamanoSudoku,
        itemBuilder: (context, index) {
          int num = index + ConstantesSudoku.valorMinimoCelda;
          bool hasNote = notes.contains(num);
          return Center(
            child: Text(
              hasNote ? '$num' : '',
              style: TextStyle(
                fontSize: 8,
                color: ColoresApp.gris600,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLang = Provider.of<LanguageProvider>(context).currentLanguage;

    return Scaffold(
      backgroundColor: isDark ? ColoresApp.gris800 : ColoresApp.gris100,
      body: SafeArea(
        child: Column(
          children: [
            // Header con información
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón de cerrar
                  IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    color: isDark ? ColoresApp.blanco : ColoresApp.negro,
                    onPressed: () => Navigator.pop(context),
                  ),

                  // Tiempo
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.isTimeAttackMode && timeLeft <= 30
                          ? ColoresApp.rojoError
                          : ColoresApp.moradoPrincipal,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.isTimeAttackMode ? Icons.timer : Icons.access_time,
                          color: ColoresApp.blanco,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.isTimeAttackMode
                              ? _formatTime(timeLeft)
                              : _formatTime(elapsedSeconds),
                          style: TextStyle(
                            color: ColoresApp.blanco,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progreso
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B3FF2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$cellsFilled/$totalEmptyCells',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tablero de Sudoku
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ConstantesSudoku.tamanoSudoku,
                      ),
                      itemCount: ConstantesSudoku.tamanoSudoku * ConstantesSudoku.tamanoSudoku,
                      itemBuilder: (context, index) {
                        int row = index ~/ ConstantesSudoku.tamanoSudoku;
                        int col = index % ConstantesSudoku.tamanoSudoku;

                        bool isSelected = selectedRow == row && selectedCol == col;
                        bool isSameRow = selectedRow == row;
                        bool isSameCol = selectedCol == col;
                        bool isSameBox = selectedRow != null &&
                            selectedCol != null &&
                            (selectedRow! ~/ ConstantesSudoku.tamanoCaja) == (row ~/ ConstantesSudoku.tamanoCaja) &&
                            (selectedCol! ~/ ConstantesSudoku.tamanoCaja) == (col ~/ ConstantesSudoku.tamanoCaja);

                        Color backgroundColor = ColoresApp.blanco;
                        if (isError[row][col]) {
                          backgroundColor = ColoresApp.colorCeldaError;
                        } else if (isSelected) {
                          backgroundColor = ColoresApp.colorCeldaSeleccionada;
                        } else if (isSameRow || isSameCol || isSameBox) {
                          backgroundColor = ColoresApp.colorCeldaRelacionada;
                        }

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedRow = row;
                              selectedCol = col;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              border: Border(
                                top: BorderSide(
                                  color: row % 3 == 0 ? Colors.black : Colors.grey[400]!,
                                  width: row % 3 == 0 ? 2 : 0.5,
                                ),
                                left: BorderSide(
                                  color: col % 3 == 0 ? Colors.black : Colors.grey[400]!,
                                  width: col % 3 == 0 ? 2 : 0.5,
                                ),
                                right: BorderSide(
                                  color: col == 8 ? Colors.black : Colors.transparent,
                                  width: col == 8 ? 2 : 0,
                                ),
                                bottom: BorderSide(
                                  color: row == 8 ? Colors.black : Colors.transparent,
                                  width: row == 8 ? 2 : 0,
                                ),
                              ),
                            ),
                            child: Center(
                              child: board[row][col] == 0
                                  ? (pencilNotes[row][col].isEmpty
                                      ? const SizedBox()
                                      : _buildPencilNotes(pencilNotes[row][col]))
                                  : Text(
                                      '${board[row][col]}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isFixed[row][col]
                                            ? Colors.black
                                            : const Color(0xFF7B3FF2),
                                      ),
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Controles de números
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(
                children: [
                  // Botones Lápiz y Borrador
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botón Lápiz
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isPencilMode = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: isPencilMode
                                ? ColoresApp.moradoPrincipal
                                : ColoresApp.gris300,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            border: Border.all(
                              color: isPencilMode
                                  ? ColoresApp.moradoPrincipal
                                  : ColoresApp.gris400,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit,
                                color: isPencilMode ? ColoresApp.blanco : ColoresApp.negro,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppStrings.get('pencil', currentLang),
                                style: TextStyle(
                                  color: isPencilMode ? ColoresApp.blanco : ColoresApp.negro,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Botón Borrador
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isPencilMode = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: !isPencilMode
                                ? ColoresApp.moradoPrincipal
                                : ColoresApp.gris300,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            border: Border.all(
                              color: !isPencilMode
                                  ? ColoresApp.moradoPrincipal
                                  : ColoresApp.gris400,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.border_color,
                                color: !isPencilMode ? ColoresApp.blanco : ColoresApp.negro,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppStrings.get('notes', currentLang),
                                style: TextStyle(
                                  color: !isPencilMode ? ColoresApp.blanco : ColoresApp.negro,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Números 1-9
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(ConstantesSudoku.tamanoSudoku, (index) {
                      int number = index + ConstantesSudoku.valorMinimoCelda;
                      return GestureDetector(
                        onTap: () => _placeNumber(number),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: selectedNumber == number
                                ? ColoresApp.moradoPrincipal
                                : ColoresApp.gris300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '$number',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: selectedNumber == number
                                    ? ColoresApp.blanco
                                    : ColoresApp.negro,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 16),

                  // Botones de acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Botón Borrar
                      ElevatedButton.icon(
                        onPressed: _clearCell,
                        icon: const Icon(Icons.backspace, size: 18),
                        label: Text(AppStrings.get('erase', currentLang)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),

                      // Botón Pista (no disponible en modo perfecto)
                      if (!widget.isPerfectMode)
                        ElevatedButton.icon(
                          onPressed: _showHint,
                          icon: const Icon(Icons.lightbulb, size: 18),
                          label: Text(AppStrings.get('hint', currentLang)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
