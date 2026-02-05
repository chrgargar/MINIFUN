import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/boton_guia.dart';
import '../data/guias_juegos.dart';
import '../tema/audio_settings.dart';
import '../tema/app_colors.dart';
import '../tema/language_provider.dart';
import '../constants/app_strings.dart';
import '../services/audio_service.dart';
import '../constants/buscaminas_con.dart';

// --- Clase BuscaminasGame (Juego) ---
class BuscaminasGame extends StatefulWidget {
  final int rows;
  final int cols;
  final int mineCount;
  final bool isContrareloj;
  final bool isSinBanderas;

  const BuscaminasGame({
    super.key,
    this.rows = 10,       // Por defecto: Fácil
    this.cols = 10,       // Por defecto: Fácil
    this.mineCount = 15,  // Por defecto: Fácil
    this.isContrareloj = false,
    this.isSinBanderas = false,
  });

  // Configuraciones de Dificultad Estáticas
  static const BuscaminasGame facil = BuscaminasGame(rows: 10, cols: 10, mineCount: 15);
  static const BuscaminasGame medio = BuscaminasGame(rows: 16, cols: 16, mineCount: 40);
  static const BuscaminasGame dificil = BuscaminasGame(rows: 24, cols: 24, mineCount: 99);
  static const BuscaminasGame extremo = BuscaminasGame(rows: 35, cols: 35, mineCount: 300);
  
  static const BuscaminasGame contrareloj = BuscaminasGame(
    rows: 10, cols: 10, mineCount: 15, isContrareloj: true,
  );

  @override
  State<BuscaminasGame> createState() => _BuscaminasGameState();
}

class _BuscaminasGameState extends State<BuscaminasGame> {
  late int rows;
  late int cols;
  late int mineCount;
  late bool isContrareloj;
  late bool isSinBanderas; 
  late BuscaminasController controller;
  bool gameOver = false;
  bool won = false;
  int flagsPlaced = 0;
  int cellsRevealed = 0;
  int timeElapsed = 0;
  int timeLeft = 0; // used in contrarreloj mode
  int hintsRemaining = 3; // 3 hints per game
  Timer? gameTimer;
  
  bool isFlaggingMode = false;
  bool isPaused = false; // Para pausar el juego al abrir la guía
  final Set<String> _pressedTiles = {}; // tracks briefly-pressed tiles for animation

  void _animateTile(int row, int col) {
    final key = '\$row,\$col';
    setState(() {
      _pressedTiles.add(key);
    });
    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted) {
        setState(() {
          _pressedTiles.remove(key);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    rows = widget.rows;
    cols = widget.cols;
    mineCount = widget.mineCount;
    isContrareloj = widget.isContrareloj;
    isSinBanderas = widget.isSinBanderas;

    controller = BuscaminasController(rows: rows, cols: cols, mineCount: mineCount);
    controller.createBoard();

    _initializeGame();
    _startBackgroundMusic();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AudioSettings>(context, listen: false).addListener(_onAudioSettingsChanged);
    });
  }

  void _onAudioSettingsChanged() {
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    AudioService.setLoopVolume(audioSettings.musicVolume);
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    AudioService.stopLoop();
    try {
      Provider.of<AudioSettings>(context, listen: false).removeListener(_onAudioSettingsChanged);
    } catch (e) {
      // Ignorar si el context ya no es válido
    }
    super.dispose();
  }

  void _startBackgroundMusic() {
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    AudioService.playLoop('Sonidos/music_buscaminas.mp3', audioSettings.musicVolume);
  }

  void _initializeGame() {
    controller = BuscaminasController(rows: rows, cols: cols, mineCount: mineCount);
    controller.createBoard();
    gameOver = false;
    won = false;
    flagsPlaced = 0;
    cellsRevealed = 0;
    timeElapsed = 0;
    // setup timer: Contrareloj counts down (timeLeft), Sin_banderas counts up (timeElapsed)
    if (isContrareloj) {
      final computed = (rows * cols) ~/ 2;
      timeLeft = (computed + 60).clamp(30, 300);
    } else {
      timeLeft = 0;
    }
    _startTimer();
    isFlaggingMode = false;
    hintsRemaining = 3;
  }

  void _startTimer() {
    gameTimer?.cancel();
    if (isContrareloj) {
      gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!gameOver && !won && !isPaused) {
          setState(() {
            timeLeft--;
            if (timeLeft <= 0) {
              timer.cancel();
              gameOver = true;
              controller.revealAllMines();
                            _showGameOverDialog();
            }
          });
        }
      });
    } else if (isSinBanderas) {
      gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!gameOver && !won && !isPaused) {
          setState(() {
            timeElapsed++;
          });
        }
      });
    } else {
      gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!gameOver && !won && !isPaused) {
          setState(() {
            timeElapsed++;
          });
        }
      });
    }
  }

  void _placeMines() {
    // moved to controller
  }

  void _calculateNumbers() {
    // moved to controller
  }

  void _revealCell(int row, int col) {
    if (gameOver || won) return;
    // Ensure mines are placed after the first click, never on the first clicked cell
    if (!controller.minesPlaced) {
      controller.placeMines(safeRow: row, safeCol: col);
      controller.calculateNumbers();
    }

    // Use controller to update board logic; UI handles sounds/dialogs
    bool hitMine = controller.revealCell(row, col);
    setState(() {
      flagsPlaced = controller.countFlags();
      cellsRevealed = controller.countRevealed();
    });

    if (hitMine) {
      setState(() => gameOver = true);
      controller.revealAllMines();
            _showGameOverDialog();
      return;
    }

        _checkWin();
  }

  void _revealAdjacentCells(int row, int col) {
    // moved to controller
  }

  void _toggleFlag(int row, int col) {
    if (gameOver || won) return;
    if (controller.board[row][col].isRevealed) return;

    setState(() {
      // Respect the mine count limit when placing flags
      if (controller.board[row][col].isFlagged) {
        controller.toggleFlag(row, col); // remove
        flagsPlaced = controller.countFlags();
              } else {
        if (controller.countFlags() < mineCount) {
          controller.toggleFlag(row, col); // add
          flagsPlaced = controller.countFlags();
                  } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Límite máximo de banderas alcanzado!')),
          );
        }
      }
    });
    _checkWin();
  }

  void _toggleFlaggingMode() {
    setState(() {
      isFlaggingMode = !isFlaggingMode;
       
    });
  }

  void _revealAllMines() {
    controller.revealAllMines();
  }

  void _useHint() {
    if (hintsRemaining <= 0 || gameOver || won || isPaused) return;

    // Find all candidate cells (safe, unrevealed, not flagged)
    List<Point<int>> candidates = [];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cell = controller.board[r][c];
        if (!cell.isRevealed && !cell.isMine && !cell.isFlagged) {
          candidates.add(Point(r, c));
        }
      }
    }

    if (candidates.isNotEmpty) {
      final random = Random();
      final pick = candidates[random.nextInt(candidates.length)];
      
      setState(() {
        hintsRemaining--;
      });
      
      _revealCell(pick.x, pick.y);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay casillas seguras disponibles para pista')),
      );
    }
  }

  void _checkWin() {
    final totalSafeCells = controller.totalSafeCells();
    cellsRevealed = controller.countRevealed();
    if (cellsRevealed == totalSafeCells) {
      won = true;
      gameTimer?.cancel();
            _showWinDialog();
    }
  }

  // --- Diálogos y _getNumberColor se mantienen sin cambios ---
  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: ColoresApp.blanco, 
        title: Text(
          "💣 Game Over",
          style: TextStyle(color: ColoresApp.negro, fontWeight: FontWeight.bold), 
        ),
        content: Text(
          "Tiempo: ${timeElapsed}s\n¡Tocaste una mina!",
          style: TextStyle(color: ColoresApp.negro), 
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Future.delayed(const Duration(milliseconds: 50), () {
                if (mounted) setState(() => _initializeGame());
              });
            },
            child: Text("Reintentar", style: TextStyle(color: ColoresApp.moradoPrincipal)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("Salir", style: TextStyle(color: ColoresApp.rojoError)),
          ),
        ],
      ),
    );
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: ColoresApp.blanco, 
        title: Text(
          "🎉 ¡Victoria!",
          style: TextStyle(color: ColoresApp.negro, fontWeight: FontWeight.bold), 
        ),
        content: Text(
          "Tiempo: ${timeElapsed}s\nDificultad: ${rows}x$cols\n${isContrareloj ? '¡Modo Contrarreloj completado!' : '¡Encontraste todas las minas!'}",
          style: TextStyle(color: ColoresApp.negro), 
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Future.delayed(const Duration(milliseconds: 50), () {
                if (mounted) {
                  setState(() {
                    if (isContrareloj || isSinBanderas) {
                      mineCount = (mineCount * 1.2).toInt().clamp(1, rows * cols - 1);
                      rows = (rows * 1.15).toInt().clamp(rows, 30);
                      cols = (cols * 1.15).toInt().clamp(cols, 30);
                    }
                    _initializeGame();
                  });
                }
              });
            },
            child: Text("Jugar de nuevo", style: TextStyle(color: ColoresApp.moradoPrincipal)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("Salir", style: TextStyle(color: ColoresApp.rojoError)),
          ),
        ],
      ),
    );
  }

  void _showPauseDialog() {
    setState(() => isPaused = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: ColoresApp.blanco,
        title: Text(
          AppStrings.get('paused', Provider.of<LanguageProvider>(context, listen: false).currentLanguage),
          style: TextStyle(color: ColoresApp.negro, fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppStrings.get('game_paused', Provider.of<LanguageProvider>(context, listen: false).currentLanguage),
          style: TextStyle(color: ColoresApp.negro),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => isPaused = false);
            },
            child: Text(
              AppStrings.get('resume', Provider.of<LanguageProvider>(context, listen: false).currentLanguage),
              style: TextStyle(color: ColoresApp.moradoPrincipal),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              AppStrings.get('exit', Provider.of<LanguageProvider>(context, listen: false).currentLanguage),
              style: TextStyle(color: ColoresApp.rojoError),
            ),
          ),
        ],
      ),
    );
  }

  Color _getNumberColor(int number) {
    switch (number) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.deepPurple;
      default:
        return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.negro,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // LEFT: Time and tile count
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isContrareloj
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: ColoresApp.rojoError.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('${timeLeft}s', style: TextStyle(color: ColoresApp.blanco, fontSize: 22, fontWeight: FontWeight.bold)),
                            )
                          : Text('${timeElapsed}s', style: TextStyle(color: ColoresApp.blanco, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('$rows x $cols', style: TextStyle(color: ColoresApp.blanco, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  // RIGHT: Flags counter, flag button, guide button, and close button
                  Column(
                    children: [
                      Builder(
                        builder: (context) {
                          final currentLang = Provider.of<LanguageProvider>(context).currentLanguage;
                          return Row(
                            children: [
                              if (!isSinBanderas)
                                Row(
                                  children: [
                                    Text('${controller.countFlags()}/$mineCount', style: TextStyle(color: ColoresApp.blanco, fontSize: 20, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 8),
                                    Icon(Icons.flag, color: ColoresApp.moradoPrincipal, size: 24),
                                  ],
                                ),
                              const SizedBox(width: 8),
                              BotonGuia(
                                gameTitle: 'Buscaminas',
                                gameImagePath: 'assets/imagenes/buscaminas.png',
                                objetivo: AppStrings.get('minesweeper_objective', currentLang),
                                instrucciones: [
                                  AppStrings.get('minesweeper_inst_1', currentLang),
                                  AppStrings.get('minesweeper_inst_2', currentLang),
                                  AppStrings.get('minesweeper_inst_3', currentLang),
                                  AppStrings.get('minesweeper_inst_5', currentLang),
                                  AppStrings.get('minesweeper_inst_4', currentLang),
                                ],
                                controles: GuiasJuegos.getBuscaminasControles(currentLang),
                                size: 40,
                                onOpen: () => setState(() => isPaused = true),
                                onClose: () => setState(() => isPaused = false),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.pause),
                                color: ColoresApp.blanco,
                                iconSize: 28,
                                onPressed: _showPauseDialog,
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.close),
                                color: ColoresApp.blanco,
                                iconSize: 28,
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          );
                        },
                      ),
                      if (!isSinBanderas)
                        FloatingActionButton(
                          heroTag: 'flagMode',
                          onPressed: _toggleFlaggingMode,
                          backgroundColor: isFlaggingMode ? ColoresApp.moradoPrincipal : ColoresApp.gris100,
                          child: Icon(isFlaggingMode ? Icons.clear : Icons.flag, color: isFlaggingMode ? ColoresApp.blanco : ColoresApp.moradoPrincipal, size: 28),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final boardSize = min(constraints.maxWidth, constraints.maxHeight - 100);
                  final cellSize = boardSize / cols;
                  return Center(
                    child: SizedBox(
                      width: cellSize * cols,
                      height: cellSize * rows,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          childAspectRatio: 1,
                        ),
                        itemCount: rows * cols,
                        itemBuilder: (context, index) {
                          final r = index ~/ cols;
                          final c = index % cols;
                          final cell = controller.board[r][c];
                          final key = '\$r,\$c';
                          final pressed = _pressedTiles.contains(key);

                          return GestureDetector(
                            onTap: () {
                              _animateTile(r, c);
                              if (isFlaggingMode) {
                                _toggleFlag(r, c);
                              } else {
                                _revealCell(r, c);
                              }
                            },
                            onLongPress: () => _toggleFlag(r, c),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 1.0, end: pressed ? 0.92 : 1.0),
                              duration: const Duration(milliseconds: 120),
                              builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                decoration: BoxDecoration(
                                  color: cell.isRevealed ? (cell.isMine ? ColoresApp.rojoError : ColoresApp.gris100) : ColoresApp.gris800,
                                  border: Border.all(color: ColoresApp.moradoPrincipal, width: 1),
                                ),
                                child: Center(
                                  child: cell.isFlagged
                                      ? Icon(Icons.flag, color: ColoresApp.moradoPrincipal, size: cellSize * 0.6)
                                      : cell.isRevealed
                                          ? (cell.isMine
                                              ? Icon(Icons.close, color: ColoresApp.blanco, size: cellSize * 0.6)
                                              : (cell.adjacentMines > 0
                                                  ? Text('${cell.adjacentMines}', style: TextStyle(fontSize: cellSize * 0.5, fontWeight: FontWeight.bold, color: _getNumberColor(cell.adjacentMines)))
                                                  : null))
                                          : null,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: 'hintBtn',
                    mini: true,
                    onPressed: hintsRemaining > 0 ? _useHint : null,
                    backgroundColor: hintsRemaining > 0 ? ColoresApp.naranjaAdvertencia : Colors.grey,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                         const Icon(Icons.lightbulb, color: Colors.white),
                         if (hintsRemaining > 0)
                           Positioned(
                             right: 0,
                             bottom: 0,
                             child: Container(
                               padding: const EdgeInsets.all(2),
                               decoration: const BoxDecoration(
                                 color: Colors.red,
                                 shape: BoxShape.circle,
                               ),
                               constraints: const BoxConstraints(
                                 minWidth: 12,
                                 minHeight: 12,
                               ),
                               child: Text(
                                 '$hintsRemaining',
                                 style: const TextStyle(
                                   color: Colors.white,
                                   fontSize: 8,
                                   fontWeight: FontWeight.bold,
                                 ),
                                 textAlign: TextAlign.center,
                               ),
                             ),
                           ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  FloatingActionButton(
                    heroTag: 'reiniciarBtn',
                    mini: true,
                    onPressed: _initializeGame,
                    backgroundColor: ColoresApp.moradoPrincipal,
                    child: const Icon(Icons.refresh, color: Colors.white),
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