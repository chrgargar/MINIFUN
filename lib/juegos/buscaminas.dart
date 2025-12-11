import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tema/audio_settings.dart';
import '../tema/app_colors.dart'; 
import '../services/audio_service.dart';

// --- Clase Cell (Celda) ---
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

// --- Clase BuscaminasGame (Juego) ---
class BuscaminasGame extends StatefulWidget {
  final int rows;
  final int cols;
  final int mineCount;
  final bool isContrareloj; 

  const BuscaminasGame({
    super.key,
    this.rows = 10,       // Por defecto: Fácil
    this.cols = 10,       // Por defecto: Fácil
    this.mineCount = 15,  // Por defecto: Fácil
    this.isContrareloj = false,
  });

  // Configuraciones de Dificultad Estáticas
  static const BuscaminasGame facil = BuscaminasGame(rows: 10, cols: 10, mineCount: 15);
  static const BuscaminasGame medio = BuscaminasGame(rows: 16, cols: 16, mineCount: 40);
  static const BuscaminasGame dificil = BuscaminasGame(rows: 24, cols: 24, mineCount: 99);
  
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

  late List<List<Cell>> board;
  bool gameOver = false;
  bool won = false;
  int flagsPlaced = 0;
  int cellsRevealed = 0;
  int timeElapsed = 0;
  Timer? gameTimer;
  
  bool isFlaggingMode = false;

  @override
  void initState() {
    super.initState();
    rows = widget.rows;
    cols = widget.cols;
    mineCount = widget.mineCount;
    isContrareloj = widget.isContrareloj;
    
    _initializeGame();

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
    AudioService.stopLoop();
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
    isFlaggingMode = false; 
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
    
    // Quitar bandera si se intenta revelar
    if (board[row][col].isFlagged) {
        setState(() {
            board[row][col].isFlagged = false;
            flagsPlaced--;
        });
    }

    if (board[row][col].isRevealed) return;

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
      if (board[row][col].isFlagged) {
          // Quitar bandera
          board[row][col].isFlagged = false;
          flagsPlaced--;
          _playSound('food.mp3');
      } else {
          // Poner bandera solo si no se ha alcanzado el límite
          if (flagsPlaced < mineCount) {
              board[row][col].isFlagged = true;
              flagsPlaced++;
              _playSound('food.mp3');
          } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Límite máximo de minas alcanzado!')),
              );
          }
      }
      _checkWin();
    });
  }

  void _toggleFlaggingMode() {
    setState(() {
      isFlaggingMode = !isFlaggingMode;
      _playSound(isFlaggingMode ? 'powerup.mp3' : 'move.mp3'); 
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
        backgroundColor: ColoresApp.blanco, 
        title: Text(
          "🎉 ¡Victoria!",
          style: TextStyle(color: ColoresApp.negro, fontWeight: FontWeight.bold), 
        ),
        content: Text(
          "Tiempo: ${timeElapsed}s\nDificultad: ${rows}x${cols}\n${isContrareloj ? '¡Modo Contrarreloj completado!' : '¡Encontraste todas las minas!'}",
          style: TextStyle(color: ColoresApp.negro), 
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
            // Área principal del juego (Grid) - Sin cambios
            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  final screenHeight = constraints.maxHeight;
                  final cellSize = min(
                    (screenWidth - 32) / cols,
                    (screenHeight - 150) / rows, 
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
                          mainAxisSpacing: 0,
                          crossAxisSpacing: 0,
                        ),
                        itemCount: rows * cols,
                        itemBuilder: (context, index) {
                          int row = index ~/ cols;
                          int col = index % cols;
                          Cell cell = board[row][col];

                          return GestureDetector(
                            onTap: () {
                              if (isFlaggingMode) {
                                _toggleFlag(row, col);
                              } else {
                                _revealCell(row, col);
                              }
                            },
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
                                          color: ColoresApp.moradoPrincipal, 
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
            
            // --- ORGANIZACIÓN SUPERIOR CORREGIDA ---
            
            // 1. Contador de Banderas y Botón de Modo (Superior Izquierda)
            Positioned(
              top: 16,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Contador de Banderas
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

                      const SizedBox(width: 12),
                      
                      // 🚩 Botón de Modo Bandera Superior (El que pediste)
                      FloatingActionButton(
                        heroTag: 'banderaBtnSup',
                        mini: true,
                        onPressed: _toggleFlaggingMode,
                        tooltip: isFlaggingMode ? 'Modo: Revelar' : 'Modo: Bandera',
                        backgroundColor: isFlaggingMode 
                            ? ColoresApp.moradoPrincipal.withOpacity(0.9)
                            : ColoresApp.gris100.withOpacity(0.9),
                        elevation: 8,
                        child: Icon(
                          isFlaggingMode ? Icons.clear : Icons.flag,
                          color: isFlaggingMode ? ColoresApp.blanco : ColoresApp.moradoPrincipal,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),

                  // Texto de Instrucción (Debajo del contador de Banderas)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: ColoresApp.gris100.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      isFlaggingMode ? 'Modo: ¡Bandera!' : 'Modo: ¡Revelar!',
                      style: TextStyle(
                        fontSize: 12,
                        color: ColoresApp.blanco,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 2. Dificultad y Tiempo (Superior Derecha, Lejos del borde para la X)
            Positioned(
              top: 16,
              right: 60, // Deja espacio para el botón 'X'
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Indicador de Modo/Dificultad
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isContrareloj ? ColoresApp.rojoError.withOpacity(0.9) : ColoresApp.gris100.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isContrareloj ? 'CONTRARRELOJ' : '$rows x $cols',
                      style: TextStyle(
                        color: ColoresApp.blanco,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
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
            
            // 3. Botón de cerrar (X) - Esquina superior derecha extrema
            Positioned(
              top: 8, 
              right: 8, 
              child: IconButton(
                icon: const Icon(Icons.close),
                color: ColoresApp.blanco,
                iconSize: 30,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            
            // ❌ ELIMINADO: BOTÓN DE BANDERA INFERIOR (Se movió arriba)
            
            // 4. Botón de reinicio (Abajo a la derecha)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                heroTag: 'reiniciarBtn',
                onPressed: () {
                  setState(() {
                    _initializeGame();
                  });
                },
                backgroundColor: ColoresApp.moradoPrincipal.withOpacity(0.9),
                elevation: 8,
                child: const Icon(Icons.refresh, color: Colors.white, size: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}