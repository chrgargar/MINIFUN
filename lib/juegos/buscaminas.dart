import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tema/audio_settings.dart';
import '../tema/app_colors.dart';
import '../services/audio_service.dart';

class BuscaminasGame extends StatefulWidget {
  final int rows;
  final int cols;
  final int mineCount;

  const BuscaminasGame({
    super.key,
    this.rows = 10,
    this.cols = 10,
    this.mineCount = 15,
  });

  @override
  State<BuscaminasGame> createState() => _BuscaminasGameState();
}

class _BuscaminasGameState extends State<BuscaminasGame> {
  late int rows;
  late int cols;
  late int mineCount;

  late List<List<Cell>> board;
  bool gameOver = false;
  bool won = false;
  int flagsPlaced = 0;
  int cellsRevealed = 0;
  int timeElapsed = 0;
  Timer? gameTimer;

  @override
  void initState() {
    super.initState();
    // initialize instance fields from widget so difficulties work
    rows = widget.rows;
    cols = widget.cols;
    mineCount = widget.mineCount;
    _initializeGame();

    // Escuchar cambios en la configuración de audio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AudioSettings>(context, listen: false).addListener(_onAudioSettingsChanged);
    });
  }

  void _onAudioSettingsChanged() {
    // El volumen de SFX se actualiza directamente en _playSound
  }

  @override
  void dispose() {
    gameTimer?.cancel();

    // Detener música de fondo
    AudioService.stopLoop();

    // Remover listener de audio settings
    try {
      Provider.of<AudioSettings>(context, listen: false).removeListener(_onAudioSettingsChanged);
    } catch (e) {
      // Ignorar si el context ya no es válido
    }

    super.dispose();
  }

  Future<void> _playSound(String sound) async {
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    await AudioService.playSound('Sonidos/$sound', audioSettings.sfxVolume);
  }

  void _initializeGame() {
    board = List.generate(
      rows,
      (i) => List.generate(cols, (j) => Cell(row: i, col: j)),
    );
    _placeMines();
    _calculateNumbers();
    gameOver = false;
    won = false;
    flagsPlaced = 0;
    cellsRevealed = 0;
    timeElapsed = 0;
    _startTimer();
  }

  void _startTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!gameOver && !won) {
        setState(() {
          timeElapsed++;
        });
      }
    });
  }

  void _placeMines() {
    Random random = Random();
    int minesPlaced = 0;

    while (minesPlaced < mineCount) {
      int row = random.nextInt(rows);
      int col = random.nextInt(cols);

      if (!board[row][col].isMine) {
        board[row][col].isMine = true;
        minesPlaced++;
      }
    }
  }

  void _calculateNumbers() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        if (!board[i][j].isMine) {
          int count = 0;
          for (int di = -1; di <= 1; di++) {
            for (int dj = -1; dj <= 1; dj++) {
              int ni = i + di;
              int nj = j + dj;
              if (ni >= 0 && ni < rows && nj >= 0 && nj < cols) {
                if (board[ni][nj].isMine) count++;
              }
            }
          }
          board[i][j].adjacentMines = count;
        }
      }
    }
  }

  void _revealCell(int row, int col) {
    if (gameOver || won) return;
    if (board[row][col].isRevealed || board[row][col].isFlagged) return;

    setState(() {
      board[row][col].isRevealed = true;
      cellsRevealed++;

      if (board[row][col].isMine) {
        gameOver = true;
        _revealAllMines();
        _playSound('gameover.mp3');
        _showGameOverDialog();
      } else {
        _playSound('move.mp3');
        if (board[row][col].adjacentMines == 0) {
          _revealAdjacentCells(row, col);
        }
        _checkWin();
      }
    });
  }

  void _revealAdjacentCells(int row, int col) {
    for (int di = -1; di <= 1; di++) {
      for (int dj = -1; dj <= 1; dj++) {
        int ni = row + di;
        int nj = col + dj;
        if (ni >= 0 && ni < rows && nj >= 0 && nj < cols) {
          if (!board[ni][nj].isRevealed && !board[ni][nj].isFlagged) {
            board[ni][nj].isRevealed = true;
            cellsRevealed++;
            if (board[ni][nj].adjacentMines == 0) {
              _revealAdjacentCells(ni, nj);
            }
          }
        }
      }
    }
  }

  void _toggleFlag(int row, int col) {
    if (gameOver || won) return;
    if (board[row][col].isRevealed) return;

    setState(() {
      board[row][col].isFlagged = !board[row][col].isFlagged;
      flagsPlaced += board[row][col].isFlagged ? 1 : -1;
      _playSound('food.mp3');
      _checkWin();
    });
  }

  void _revealAllMines() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        if (board[i][j].isMine) {
          board[i][j].isRevealed = true;
        }
      }
    }
  }

  void _checkWin() {
    int totalSafeCells = rows * cols - mineCount;
    if (cellsRevealed == totalSafeCells) {
      won = true;
      gameTimer?.cancel();
      _playSound('food.mp3');
      _showWinDialog();
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: ColoresApp.gris100,
        title: Text(
          "💣 Game Over",
          style: TextStyle(color: ColoresApp.blanco, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Tiempo: ${timeElapsed}s\n¡Tocaste una mina!",
          style: TextStyle(color: ColoresApp.blanco),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _initializeGame();
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
        backgroundColor: ColoresApp.gris100,
        title: Text(
          "🎉 ¡Victoria!",
          style: TextStyle(color: ColoresApp.blanco, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Tiempo: ${timeElapsed}s\n¡Encontraste todas las minas!",
          style: TextStyle(color: ColoresApp.blanco),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _initializeGame();
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

  Color _getNumberColor(int number) {
    switch (number) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.orange;
      case 6:
        return Colors.cyan;
      case 7:
        return Colors.black;
      case 8:
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.negro,
      body: SafeArea(
        child: Stack(
          children: [
            // Área principal del juego
            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  final screenHeight = constraints.maxHeight;
                  final cellSize = min(
                    (screenWidth - 32) / cols,
                    (screenHeight - 200) / rows,
                  );
                  final boardWidth = cols * cellSize;
                  final boardHeight = rows * cellSize;

                  return SizedBox(
                    width: boardWidth,
                    height: boardHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: ColoresApp.moradoPrincipal, width: 3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                        ),
                        itemCount: rows * cols,
                        itemBuilder: (context, index) {
                          int row = index ~/ cols;
                          int col = index % cols;
                          Cell cell = board[row][col];

                          return GestureDetector(
                            onTap: () => _revealCell(row, col),
                            onLongPress: () => _toggleFlag(row, col),
                            child: Container(
                              decoration: BoxDecoration(
                                color: cell.isRevealed
                                    ? (cell.isMine 
                                        ? ColoresApp.rojoError 
                                        : ColoresApp.gris100)
                                    : ColoresApp.gris800,
                                border: Border.all(
                                  color: ColoresApp.negro,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: cell.isFlagged
                                    ? Icon(
                                        Icons.flag,
                                        color: ColoresApp.rojoError,
                                        size: cellSize * 0.6,
                                      )
                                    : cell.isRevealed
                                        ? (cell.isMine
                                            ? Icon(
                                                Icons.close,
                                                color: ColoresApp.blanco,
                                                size: cellSize * 0.6,
                                              )
                                            : (cell.adjacentMines > 0
                                                ? Text(
                                                    '${cell.adjacentMines}',
                                                    style: TextStyle(
                                                      fontSize: cellSize * 0.5,
                                                      fontWeight: FontWeight.bold,
                                                      color: _getNumberColor(cell.adjacentMines),
                                                    ),
                                                  )
                                                : null))
                                        : null,
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
            // Panel superior con información
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Banderas colocadas
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: ColoresApp.moradoPrincipal.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: ColoresApp.moradoPrincipal.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flag, color: ColoresApp.blanco, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '$flagsPlaced/$mineCount',
                          style: TextStyle(
                            color: ColoresApp.blanco,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tiempo transcurrido
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: ColoresApp.naranjaAdvertencia.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: ColoresApp.naranjaAdvertencia.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer, color: ColoresApp.blanco, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${timeElapsed}s',
                          style: TextStyle(
                            color: ColoresApp.blanco,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Botón de cerrar
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: ColoresApp.rojoError.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ColoresApp.rojoError.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.close),
                  color: ColoresApp.blanco,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            // Botón de reinicio
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: ColoresApp.moradoPrincipal.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ColoresApp.moradoPrincipal.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.refresh),
                  color: ColoresApp.blanco,
                  iconSize: 32,
                  onPressed: () {
                    setState(() {
                      _initializeGame();
                    });
                  },
                ),
              ),
            ),
            // Instrucciones en la parte inferior
            Positioned(
              bottom: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ColoresApp.gris100.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'Toca para revelar • Mantén para bandera',
                  style: TextStyle(
                    fontSize: 12,
                    color: ColoresApp.blanco,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Cell {
  final int row;
  final int col;
  bool isMine;
  bool isRevealed;
  bool isFlagged;
  int adjacentMines;

  Cell({
    required this.row,
    required this.col,
    this.isMine = false,
    this.isRevealed = false,
    this.isFlagged = false,
    this.adjacentMines = 0,
  });
}