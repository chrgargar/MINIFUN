import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_logger.dart';
import '../widgets/game_control_buttons.dart';
import '../widgets/pause_overlay.dart';
import '../widgets/boton_guia.dart';
import '../data/guias_juegos.dart';
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

  // Pistas restantes según dificultad
  int hintsRemaining = 3;

  // Estado de pausa
  bool isPaused = false;

  int _hintsForDifficulty() {
    switch (widget.difficulty) {
      case 'facil': return 3;
      case 'medio': return 2;
      case 'dificil': return 1;
      default: return 3;
    }
  }

  @override
  void initState() {
    super.initState();

    // Rastrear pantalla actual
    appLogger.setCurrentScreen('SudokuGame');

    // Log inicio de partida
    String mode = 'normal';
    if (widget.isTimeAttackMode) mode = 'time_attack';
    if (widget.isPerfectMode) mode = 'perfect';
    appLogger.gameEvent('Sudoku', 'game_start', data: {'difficulty': widget.difficulty, 'mode': mode});

    hintsRemaining = _hintsForDifficulty();
    _generateSudoku();
    _startTimer();
    _startBackgroundMusic();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    AudioService.stopLoop();
    super.dispose();
  }

  void _startBackgroundMusic() {
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    AudioService.playLoop('Sonidos/music_sudoku.mp3', audioSettings.musicVolume);
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

        // Si ya había un número correcto, decrementar el contador
        if (board[selectedRow!][selectedCol!] != 0 &&
            board[selectedRow!][selectedCol!] == solution[selectedRow!][selectedCol!]) {
          cellsFilled--;
        }

        board[selectedRow!][selectedCol!] = number;

        // Verificar si es correcto
        if (number == solution[selectedRow!][selectedCol!]) {
                    cellsFilled++;

          // Verificar si ganó
          if (cellsFilled == totalEmptyCells) {
            gameTimer?.cancel();
            _gameOver(true);
          }
        } else {
          // Error
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
    if (hintsRemaining <= 0) {
      final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('no_hints_remaining', currentLang)),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Buscar una celda vacía y mostrar el número correcto
    for (int i = 0; i < ConstantesSudoku.tamanoSudoku; i++) {
      for (int j = 0; j < ConstantesSudoku.tamanoSudoku; j++) {
        if (!isFixed[i][j] && board[i][j] != solution[i][j]) {
          setState(() {
            hintsRemaining--;
            board[i][j] = solution[i][j];
            isError[i][j] = false;
            if (board[i][j] != ConstantesSudoku.valorCeldaVacia) {
              cellsFilled++;
            }
            selectedRow = i;
            selectedCol = j;
          });

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
    // Log fin de partida
    appLogger.gameEvent('Sudoku', 'game_end', data: {'won': won, 'errors': errorsCount, 'time': elapsedSeconds});

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
        backgroundColor: ColoresApp.blanco,
        title: Text(
          won ? "🎉 $title" : "💀 $title",
          style: TextStyle(color: ColoresApp.negro, fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: TextStyle(color: ColoresApp.negro),
        ),
        actions: [
          TextButton(
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
            child: Text(
              won ? AppStrings.get('play_again', currentLang) : AppStrings.get('retry', currentLang),
              style: TextStyle(color: ColoresApp.moradoPrincipal),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Volver al menú
            },
            child: Text(AppStrings.get('exit', currentLang), style: TextStyle(color: ColoresApp.rojoError)),
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

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
      if (isPaused) {
        gameTimer?.cancel();
      } else {
        _startTimer();
      }
    });
  }

  void _restartGame() {
    gameTimer?.cancel();
    setState(() {
      isPaused = false;
      _generateSudoku();
      cellsFilled = 0;
      errorsCount = 0;
      elapsedSeconds = 0;
      timeLeft = ConstantesSudoku.duracionContrarreloj;
      selectedRow = null;
      selectedCol = null;
      hintsRemaining = _hintsForDifficulty();
      isError = List.generate(ConstantesSudoku.tamanoSudoku, (_) => List.filled(ConstantesSudoku.tamanoSudoku, false));
      pencilNotes = List.generate(ConstantesSudoku.tamanoSudoku, (_) => List.generate(ConstantesSudoku.tamanoSudoku, (_) => []));
    });
    _startTimer();
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

  Widget _buildHeader(bool isDark) {
    final currentLang = Provider.of<LanguageProvider>(context).currentLanguage;
    final sw = MediaQuery.of(context).size.width;
    final btnSize = (sw * 0.09).clamp(28.0, 40.0);
    final fontSize = (sw * 0.034).clamp(11.0, 15.0);
    final hPad = (sw * 0.028).clamp(8.0, 14.0);
    final gap = (sw * 0.016).clamp(4.0, 8.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: hPad * 0.6),
      child: Row(
        children: [
          // Tiempo
          Container(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: hPad * 0.4),
            decoration: BoxDecoration(
              color: widget.isTimeAttackMode && timeLeft <= 30
                  ? ColoresApp.rojoError.withOpacity(0.2)
                  : ColoresApp.moradoPrincipal.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  widget.isTimeAttackMode ? Icons.timer : Icons.access_time,
                  size: fontSize,
                  color: widget.isTimeAttackMode && timeLeft <= 30
                      ? ColoresApp.rojoError
                      : ColoresApp.moradoPrincipal,
                ),
                SizedBox(width: gap * 0.6),
                Text(
                  widget.isTimeAttackMode
                      ? _formatTime(timeLeft)
                      : _formatTime(elapsedSeconds),
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: widget.isTimeAttackMode && timeLeft <= 30
                        ? ColoresApp.rojoError
                        : ColoresApp.moradoPrincipal,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: gap),

          // Progreso
          Container(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: hPad * 0.4),
            decoration: BoxDecoration(
              color: ColoresApp.moradoPrincipal.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$cellsFilled/$totalEmptyCells',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: ColoresApp.moradoPrincipal,
              ),
            ),
          ),

          const Spacer(),

          // Botones de control
          GamePauseButton(
            isPaused: isPaused,
            onPressed: _togglePause,
            size: btnSize,
          ),
          SizedBox(width: gap),
          GameRestartButton(
            onPressed: _restartGame,
            size: btnSize,
          ),
          SizedBox(width: gap),
          BotonGuia(
            gameTitle: 'Sudoku',
            gameImagePath: 'assets/imagenes/sudoku.png',
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
            size: btnSize,
            onOpen: () { if (!isPaused) _togglePause(); },
            onClose: () { if (isPaused) _togglePause(); },
          ),
          SizedBox(width: gap),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: btnSize,
              height: btnSize,
              decoration: BoxDecoration(
                color: ColoresApp.rojoError,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: ColoresApp.blanco,
                size: btnSize * 0.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLang = Provider.of<LanguageProvider>(context).currentLanguage;

    return Scaffold(
      backgroundColor: isDark ? ColoresApp.gris800 : ColoresApp.gris100,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header con información
                _buildHeader(isDark),

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
                            onTap: () {
                              setState(() { selectedNumber = number; });
                              _placeNumber(number);
                            },
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
                              onPressed: hintsRemaining > 0 ? _showHint : _showHint,
                              icon: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(Icons.lightbulb, size: 18),
                                  Positioned(
                                    right: -6,
                                    top: -6,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                      child: Text(
                                        '$hintsRemaining',
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              label: Text(AppStrings.get('hint', currentLang)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: hintsRemaining > 0 ? Colors.orange : Colors.grey,
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
          // Overlay de pausa
          if (isPaused)
            PauseOverlay(
              onResume: _togglePause,
              onRestart: _restartGame,
              onExit: () => Navigator.pop(context),
            ),
        ],
      ),
    );
  }
}
