import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_logger.dart';
import '../widgets/pause_overlay.dart';
import '../widgets/boton_guia.dart';
import '../constants/guias_juegos.dart';
import '../config/audio_settings.dart';
import '../config/app_colors.dart';
import '../config/language_provider.dart';
import '../constants/app_strings.dart';
import '../services/audio_service.dart';
import '../constants/sudoku_constants.dart';
import '../providers/mission_provider.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/game_stat_badge.dart';
import '../widgets/game_header.dart';

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

class _SudokuGameState extends State<SudokuGame> with TickerProviderStateMixin {
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

  // Contador de números colocados (para detectar cuando se completan los 9 de un número)
  Map<int, int> numberCounts = {1:0, 2:0, 3:0, 4:0, 5:0, 6:0, 7:0, 8:0, 9:0};

  // Estado de pausa
  bool isPaused = false;

  // Animaciones
  late AnimationController _shakeController;
  int? _lastModifiedRow;
  int? _lastModifiedCol;
  bool _wasCorrect = false;

  // Sistema Undo
  List<_UndoAction> _undoHistory = [];
  static const int _maxUndoSteps = 30;

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

    // Inicializar controlador de animación shake
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _generateSudoku();
    _countInitialNumbers();
    _startTimer();

    // Precargar efectos de sonido para reproducción instantánea
    AudioService.preloadSounds([
      'Sonidos/number_place.ogg',
      'Sonidos/number_error.ogg',
      'Sonidos/number_complete.ogg',
      'Sonidos/hint.wav',
      // TODO: Añadir sonidos adicionales cuando se implementen:
      // 'Sonidos/victory.ogg',     // Sonido de victoria
      // 'Sonidos/undo.ogg',        // Sonido de deshacer
    ]);

  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _shakeController.dispose();
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

  // Contar números iniciales (fijos) en el tablero
  void _countInitialNumbers() {
    // Reiniciar contadores
    numberCounts = {1:0, 2:0, 3:0, 4:0, 5:0, 6:0, 7:0, 8:0, 9:0};

    // Contar números fijos (los que vienen con el tablero)
    for (int i = 0; i < ConstantesSudoku.tamanoSudoku; i++) {
      for (int j = 0; j < ConstantesSudoku.tamanoSudoku; j++) {
        if (isFixed[i][j] && board[i][j] != 0) {
          numberCounts[board[i][j]] = numberCounts[board[i][j]]! + 1;
        }
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

    // Guardar estado antes de modificar
    _saveUndoState(selectedRow!, selectedCol!);

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

          // Trackear para animación scale-in
          _lastModifiedRow = selectedRow;
          _lastModifiedCol = selectedCol;
          _wasCorrect = true;

          // Reproducir sonido de número colocado correctamente
          final audioSettings = Provider.of<AudioSettings>(context, listen: false);
          AudioService.playSound('Sonidos/number_place.ogg', audioSettings.sfxVolume);

          // Incrementar contador de este número
          numberCounts[number] = numberCounts[number]! + 1;

          // Auto-eliminar notas en fila/columna/caja
          _removeNotesInRowColBox(selectedRow!, selectedCol!, number);

          // Si se completaron los 9 de este número, reproducir sonido especial
          if (numberCounts[number] == 9) {
            AudioService.playSound('Sonidos/number_complete.ogg', audioSettings.sfxVolume);
          }

          // Verificar si ganó
          if (cellsFilled == totalEmptyCells) {
            gameTimer?.cancel();
            _gameOver(true);
          }
        } else {
          // Error
          isError[selectedRow!][selectedCol!] = true;
          errorsCount++;

          // Trackear para animación shake
          _lastModifiedRow = selectedRow;
          _lastModifiedCol = selectedCol;
          _wasCorrect = false;

          // Disparar animación shake
          _shakeController.forward(from: 0.0);

          // Reproducir sonido de error
          final audioSettings = Provider.of<AudioSettings>(context, listen: false);
          AudioService.playSound('Sonidos/number_error.ogg', audioSettings.sfxVolume);

          // En modo perfecto, terminar el juego al primer error
          if (widget.isPerfectMode && errorsCount > 0) {
            gameTimer?.cancel();
            _gameOver(false);
          }

          // Aplicar límite de errores en modo normal
          if (!widget.isPerfectMode && errorsCount >= ConstantesSudoku.maxErroresModoNormal) {
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

    _saveUndoState(selectedRow!, selectedCol!); // Guardar estado antes de borrar

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

  void _saveUndoState(int row, int col) {
    _undoHistory.add(_UndoAction(
      row: row,
      col: col,
      previousValue: board[row][col],
      previousNotes: List<int>.from(pencilNotes[row][col]),
      previousError: isError[row][col],
    ));

    if (_undoHistory.length > _maxUndoSteps) {
      _undoHistory.removeAt(0);
    }
  }

  void _undo() {
    if (_undoHistory.isEmpty) return;

    final action = _undoHistory.removeLast();

    setState(() {
      // Restaurar valor anterior
      final int newValue = action.previousValue;
      final int oldValue = board[action.row][action.col];

      board[action.row][action.col] = newValue;
      pencilNotes[action.row][action.col] = action.previousNotes;
      isError[action.row][action.col] = action.previousError;

      // Actualizar contador de celdas llenas
      if (oldValue != 0 && oldValue == solution[action.row][action.col]) {
        cellsFilled--;
      }
      if (newValue != 0 && newValue == solution[action.row][action.col]) {
        cellsFilled++;
      }

      // Actualizar contador de números
      if (oldValue != 0 && oldValue == solution[action.row][action.col]) {
        numberCounts[oldValue] = (numberCounts[oldValue]! - 1).clamp(0, 9);
      }
      if (newValue != 0 && newValue == solution[action.row][action.col]) {
        numberCounts[newValue] = (numberCounts[newValue]! + 1).clamp(0, 9);
      }
    });

    // Reproducir sonido de undo
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    AudioService.playSound('Sonidos/soft_touch.wav', audioSettings.sfxVolume);
  }

  void _removeNotesInRowColBox(int row, int col, int num) {
    // Eliminar notas en la misma fila
    for (int c = 0; c < ConstantesSudoku.tamanoSudoku; c++) {
      pencilNotes[row][c].remove(num);
    }

    // Eliminar notas en la misma columna
    for (int r = 0; r < ConstantesSudoku.tamanoSudoku; r++) {
      pencilNotes[r][col].remove(num);
    }

    // Eliminar notas en la misma caja 3x3
    int boxRow = (row ~/ ConstantesSudoku.tamanoCaja) * ConstantesSudoku.tamanoCaja;
    int boxCol = (col ~/ ConstantesSudoku.tamanoCaja) * ConstantesSudoku.tamanoCaja;
    for (int r = boxRow; r < boxRow + ConstantesSudoku.tamanoCaja; r++) {
      for (int c = boxCol; c < boxCol + ConstantesSudoku.tamanoCaja; c++) {
        pencilNotes[r][c].remove(num);
      }
    }
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

    // Reproducir sonido de pista
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    AudioService.playSound('Sonidos/hint.wav', audioSettings.sfxVolume);

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

    // Notificar misiones
    final missionProvider = Provider.of<MissionProvider>(context, listen: false);
    missionProvider.notifyActivity(gameType: 'sudoku', activityType: MissionType.playGames);
    if (won) {
      missionProvider.notifyActivity(gameType: 'sudoku', activityType: MissionType.completeLevels);
    }

    final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;

    String message = won
        ? '${AppStrings.get('completed_in', currentLang)} ${_formatTime(elapsedSeconds)}'
        : widget.isPerfectMode
            ? AppStrings.get('made_error', currentLang)
            : widget.isTimeAttackMode
                ? AppStrings.get('time_up', currentLang)
                : AppStrings.get('try_again', currentLang);

    final audioSettings = Provider.of<AudioSettings>(context, listen: false);

    GameOverDialog.show(
      context: context,
      isVictory: won,
      message: message,
      audioSettings: audioSettings,
      onRestart: () {
        Navigator.pop(context);
        _restartGame();
      },
      onExit: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
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

    return GameHeader(
      stats: [
        GameStatBadge(
          text: widget.isTimeAttackMode
              ? _formatTime(timeLeft)
              : _formatTime(elapsedSeconds),
          icon: widget.isTimeAttackMode ? Icons.timer : Icons.access_time,
          isWarning: widget.isTimeAttackMode && timeLeft <= 30,
          fontSize: fontSize,
          hPad: hPad,
          gap: gap,
        ),
        GameStatBadge(
          text: '$cellsFilled/$totalEmptyCells',
          fontSize: fontSize,
          hPad: hPad,
          gap: gap,
        ),
        // Mostrar contador de errores solo en modo normal
        if (!widget.isPerfectMode)
          GameStatBadge(
            text: '$errorsCount/${ConstantesSudoku.maxErroresModoNormal}',
            icon: Icons.close,
            color: ColoresApp.rojoError,
            isWarning: errorsCount >= 2,
            fontSize: fontSize,
            hPad: hPad,
            gap: gap,
          ),
      ],
      isPaused: isPaused,
      onPause: _togglePause,
      onRestart: _restartGame,
      onClose: () {
        gameTimer?.cancel();
        Navigator.pop(context);
      },
      guideButton: BotonGuia(
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
    );
  }

  Widget _buildBoard(BuildContext context) {
    return Expanded(
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
                return _buildCell(row, col);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(int row, int col) {
    bool isSelected = selectedRow == row && selectedCol == col;
    bool isSameRow = selectedRow == row;
    bool isSameCol = selectedCol == col;
    bool isSameBox = selectedRow != null &&
        selectedCol != null &&
        (selectedRow! ~/ ConstantesSudoku.tamanoCaja) == (row ~/ ConstantesSudoku.tamanoCaja) &&
        (selectedCol! ~/ ConstantesSudoku.tamanoCaja) == (col ~/ ConstantesSudoku.tamanoCaja);

    // Detectar si tiene el mismo número que la celda seleccionada
    final selectedNum = selectedRow != null && selectedCol != null
        ? board[selectedRow!][selectedCol!]
        : 0;
    bool isSameNumber = selectedNum != 0 &&
        board[row][col] == selectedNum &&
        board[row][col] != 0;

    Color backgroundColor = ColoresApp.blanco;
    if (isError[row][col]) {
      backgroundColor = ColoresApp.colorCeldaError;
    } else if (isSelected) {
      backgroundColor = ColoresApp.colorCeldaSeleccionada;
    } else if (isSameNumber) {
      backgroundColor = ColoresApp.colorCeldaMismoNumero;
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
          child: _buildCellContent(row, col),
        ),
      ),
    );
  }

  Widget _buildCellContent(int row, int col) {
    // Si la celda está vacía
    if (board[row][col] == 0) {
      return pencilNotes[row][col].isEmpty
          ? const SizedBox()
          : _buildPencilNotes(pencilNotes[row][col]);
    }

    // Determinar si esta celda fue la última modificada
    bool isLastModified = _lastModifiedRow == row && _lastModifiedCol == col;
    bool shouldAnimate = isLastModified && !isFixed[row][col];

    Widget numberWidget = Text(
      '${board[row][col]}',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isFixed[row][col]
            ? Colors.black
            : const Color(0xFF7B3FF2),
      ),
    );

    // Animación scale-in cuando es correcto
    if (shouldAnimate && _wasCorrect) {
      numberWidget = TweenAnimationBuilder<double>(
        key: ValueKey('scale_${row}_${col}_${board[row][col]}'),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: numberWidget,
      );
    }

    // Animación shake cuando es error
    if (shouldAnimate && !_wasCorrect) {
      numberWidget = AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          double offset = 0.0;
          if (_shakeController.isAnimating) {
            // Shake horizontal con función seno
            offset = 10 * sin(_shakeController.value * 3 * 3.14159) * (1 - _shakeController.value);
          }
          return Transform.translate(
            offset: Offset(offset, 0),
            child: child,
          );
        },
        child: numberWidget,
      );
    }

    return numberWidget;
  }

  Widget _buildModeButtons(BuildContext context) {
    final currentLang = Provider.of<LanguageProvider>(context).currentLanguage;
    return Row(
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
    );
  }

  Widget _buildNumberPad(BuildContext context) {
    final currentLang = Provider.of<LanguageProvider>(context).currentLanguage;
    return Column(
      children: [
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

            // Botón Undo
            ElevatedButton.icon(
              onPressed: _undoHistory.isEmpty ? null : _undo,
              icon: const Icon(Icons.undo, size: 18),
              label: Text(AppStrings.get('undo', currentLang)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _undoHistory.isEmpty ? Colors.grey : ColoresApp.moradoPrincipal,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                _buildBoard(context),

                // Controles de números
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Column(
                    children: [
                      // Botones Lápiz y Borrador
                      _buildModeButtons(context),

                      const SizedBox(height: 16),

                      // Números 1-9 + botones de acción
                      _buildNumberPad(context),
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
              onExit: () {
                gameTimer?.cancel();
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}

/// Representa una acción que puede ser deshecha en el sistema Undo
class _UndoAction {
  final int row;
  final int col;
  final int previousValue;
  final List<int> previousNotes;
  final bool previousError;

  _UndoAction({
    required this.row,
    required this.col,
    required this.previousValue,
    required this.previousNotes,
    required this.previousError,
  });
}
