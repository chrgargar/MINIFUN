import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/game_control_buttons.dart';
import '../widgets/pause_overlay.dart';
import '../tema/audio_settings.dart';
import '../services/audio_service.dart';
import '../constants/sopa_de_letras_constants.dart';

class WordSearchGame extends StatefulWidget {
  final String difficulty; // 'facil', 'medio', 'dificil'
  final String theme; // 'general', 'peliculas', 'musica', 'historia'
  final bool isTimeAttackMode; // Modo contrarreloj
  final bool isPerfectMode; // Modo perfecto (sin errores)

  const WordSearchGame({
    super.key,
    this.difficulty = 'facil',
    this.theme = 'general',
    this.isTimeAttackMode = false,
    this.isPerfectMode = false,
  });

  @override
  State<WordSearchGame> createState() => _WordSearchGameState();
}

class _WordSearchGameState extends State<WordSearchGame> {
  // Grid de letras
  late List<List<String>> grid;
  late List<String> wordsToFind;
  late Set<String> foundWords;
  late Map<String, List<List<int>>> wordPositions;
  late Set<String> foundCells; // Celdas encontradas, como "row,col"
  late int gridSize; // Tamaño del grid según dificultad

  // Estado del juego
  bool isPaused = false;
  bool isGameOver = false;
  bool isVictory = false;

  // Selección
  List<List<int>> selectedCells = [];
  int? startRow, startCol;

  // Timer
  Timer? gameTimer;
  int elapsedSeconds = 0;
  int timeLeft = ConstantesSopaLetras.duracionContrarreloj;

  // Puntuación
  int score = 0;
  int hintsUsed = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    if (widget.isTimeAttackMode) {
      _startTimer();
    }
  }

  void _startBackgroundMusic() {
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    AudioService.playLoop('Sonidos/music.mp3', audioSettings.musicVolume);
  }

  void _initializeGame() {
    // Determinar tamaño del grid según dificultad
    switch (widget.difficulty) {
      case 'facil':
        gridSize = 6;
        break;
      case 'medio':
        gridSize = 8;
        break;
      case 'dificil':
        gridSize = 10;
        break;
      default:
        gridSize = 6;
    }

    // Obtener lista de palabras de la temática y dificultad
    List<String> allWords = List.from(ConstantesSopaLetras.palabrasPorTematica[widget.theme]?[widget.difficulty] ?? []);
    
    // Mezclar y seleccionar máximo número de palabras
    allWords.shuffle(Random());
    int maxWords = ConstantesSopaLetras.maxPalabras[widget.difficulty] ?? 8;
    wordsToFind = allWords.take(maxWords).toList();

    // Filtrar palabras que no caben en el grid (más largas que el tamaño)
    wordsToFind = wordsToFind.where((word) => word.length <= gridSize).toList();

    // Si no hay palabras válidas, usar palabras de general
    if (wordsToFind.isEmpty) {
      List<String> defaultWords = ConstantesSopaLetras.palabrasPorTematica['general']?[widget.difficulty] ?? [];
      defaultWords = defaultWords.where((word) => word.length <= gridSize).toList();
      defaultWords.shuffle(Random());
      wordsToFind = defaultWords.take(5).toList(); // Al menos 5 palabras por defecto
    }

    // Ordenar por longitud ascendente para colocar palabras cortas primero
    wordsToFind.sort((a, b) => a.length.compareTo(b.length));

    foundWords = {};
    wordPositions = {};
    foundCells = {};
    _generateGrid();
  }

  void _generateGrid() {
    grid = List.generate(
      gridSize,
      (_) => List.filled(gridSize, ''),
    );

    // Colocar palabras en el grid (intentar colocar tantas como sea posible)
    List<String> placedWords = [];
    for (String word in wordsToFind) {
      if (_placeWord(word)) {
        placedWords.add(word);
      }
    }
    // Actualizar wordsToFind con solo las colocadas
    wordsToFind = placedWords;

    // Llenar espacios vacíos con letras aleatorias
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j].isEmpty) {
          grid[i][j] = String.fromCharCode(65 + Random().nextInt(26)); // A-Z
        }
      }
    }
  }

  bool _placeWord(String word) {
    bool placed = false;
    int attempts = 0;

    while (!placed && attempts < 500) {
      int row = Random().nextInt(gridSize);
      int col = Random().nextInt(gridSize);
      List<int> direction = ConstantesSopaLetras.direcciones[Random().nextInt(ConstantesSopaLetras.direcciones.length)];

      if (_canPlaceWord(word, row, col, direction)) {
        List<List<int>> positions = [];
        for (int k = 0; k < word.length; k++) {
          int newRow = row + k * direction[0];
          int newCol = col + k * direction[1];
          grid[newRow][newCol] = word[k];
          positions.add([newRow, newCol]);
        }
        wordPositions[word] = positions;
        placed = true;
      }
      attempts++;
    }
    return placed;
  }

  bool _canPlaceWord(String word, int row, int col, List<int> direction) {
    for (int k = 0; k < word.length; k++) {
      int newRow = row + k * direction[0];
      int newCol = col + k * direction[1];

      if (newRow < 0 || newRow >= gridSize ||
          newCol < 0 || newCol >= gridSize) {
        return false;
      }

      if (grid[newRow][newCol].isNotEmpty && grid[newRow][newCol] != word[k]) {
        return false;
      }
    }
    return true;
  }

  void _startTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused && !isGameOver) {
        setState(() {
          timeLeft--;
          if (timeLeft <= 0) {
            _gameOver(false);
          }
        });
      }
    });
  }

  void _onCellTap(int row, int col) {
    if (isPaused || isGameOver) return;

    setState(() {
      if (startRow == null) {
        // Primera selección
        startRow = row;
        startCol = col;
        selectedCells = [[row, col]];
      } else {
        // Segunda selección - verificar si forma una línea recta
        if (_isValidSelection(row, col)) {
          // Llenar todas las celdas en la línea recta
          selectedCells = _getCellsInLine(startRow!, startCol!, row, col);
          _checkForWord();
        } else {
          // Reiniciar selección
          startRow = row;
          startCol = col;
          selectedCells = [[row, col]];
        }
      }
    });
  }

  bool _isValidSelection(int row, int col) {
    if (startRow == null || startCol == null) return false;

    int dRow = (row - startRow!).abs();
    int dCol = (col - startCol!).abs();

    // Debe ser línea recta (horizontal, vertical o diagonal)
    return (dRow == 0 || dCol == 0 || dRow == dCol);
  }

  List<List<int>> _getCellsInLine(int r1, int c1, int r2, int c2) {
    List<List<int>> cells = [];
    int dRow = (r2 - r1).sign;
    int dCol = (c2 - c1).sign;
    int steps = max((r2 - r1).abs(), (c2 - c1).abs());

    for (int i = 0; i <= steps; i++) {
      int r = r1 + i * dRow;
      int c = c1 + i * dCol;
      cells.add([r, c]);
    }
    return cells;
  }

  void _checkForWord() {
    if (selectedCells.length < 2) return;

    String selectedWord = '';
    for (var cell in selectedCells) {
      selectedWord += grid[cell[0]][cell[1]];
    }

    String reversedWord = selectedWord.split('').reversed.join('');

    bool found = false;
    for (String word in wordsToFind) {
      if (!foundWords.contains(word) && (word == selectedWord || word == reversedWord)) {
        foundWords.add(word);
        score += ConstantesSopaLetras.puntosPorPalabra;
        // Marcar celdas como encontradas
        for (var cell in selectedCells) {
          foundCells.add('${cell[0]},${cell[1]}');
        }
        found = true;
        break;
      }
    }

    if (found) {
      final audioSettings = Provider.of<AudioSettings>(context, listen: false);
      AudioService.playSound('Sonidos/move.mp3', audioSettings.musicVolume);
      
      if (foundWords.length == wordsToFind.length) {
        _victory();
      }
    } else {
      _playSound('error');
    }

    // Limpiar selección
    selectedCells.clear();
    startRow = null;
    startCol = null;
  }

  void _markSelection() {
    if (selectedCells.length < 2) return;

    // Marcar celdas como encontradas
    for (var cell in selectedCells) {
      foundCells.add('${cell[0]},${cell[1]}');
    }
    // Limpiar selección
    selectedCells.clear();
    startRow = null;
    startCol = null;
    setState(() {});
  }

  void _victory() {
    isVictory = true;
    isGameOver = true;
    gameTimer?.cancel();
    AudioService.stopLoop();
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    AudioService.playSound('Sonidos/food.mp3', audioSettings.musicVolume);
  }

  void _gameOver(bool victory) {
    isVictory = victory;
    isGameOver = true;
    gameTimer?.cancel();
    _playSound(victory ? 'victory' : 'game_over');
  }

  void _playSound(String soundType) {
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    if (audioSettings.sfxVolume > 0 && !audioSettings.isMuted) {
      AudioService.playSound('sonidos/$soundType.mp3', audioSettings.sfxVolume);
    }
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header con controles
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Text(
                        'Sopa de Letras',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      GameControlBar(
                        isPaused: isPaused,
                        onPausePressed: _togglePause,
                        onRestartPressed: () {
                          setState(() {
                            _initializeGame();
                            elapsedSeconds = 0;
                            timeLeft = ConstantesSopaLetras.duracionContrarreloj;
                            score = 0;
                            hintsUsed = 0;
                            isGameOver = false;
                            isVictory = false;
                            if (widget.isTimeAttackMode) {
                              _startTimer();
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _markSelection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: const Text('Marcar', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),

                // Información del juego
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Puntuación: $score',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      if (widget.isTimeAttackMode)
                        Text(
                          'Tiempo: ${timeLeft ~/ 60}:${(timeLeft % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 16,
                            color: timeLeft < 60 ? Colors.red : (isDark ? Colors.white : Colors.black),
                          ),
                        ),
                    ],
                  ),
                ),

                // Lista de palabras
                Container(
                  height: 80,
                  padding: const EdgeInsets.all(8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: wordsToFind.length,
                    itemBuilder: (context, index) {
                      String word = wordsToFind[index];
                      bool isFound = foundWords.contains(word);
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isFound ? Colors.green : (isDark ? Colors.grey[800] : Colors.grey[200]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          word,
                          style: TextStyle(
                            fontSize: 14,
                            color: isFound ? Colors.white : (isDark ? Colors.white : Colors.black),
                            decoration: isFound ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Grid del juego
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridSize,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemCount: gridSize * gridSize,
                      itemBuilder: (context, index) {
                        int row = index ~/ gridSize;
                        int col = index % gridSize;
                        bool isSelected = selectedCells.any((cell) => cell[0] == row && cell[1] == col);
                        bool isFound = foundCells.contains('$row,$col');

                        return GestureDetector(
                          onTap: () => _onCellTap(row, col),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isFound ? Colors.green : (isSelected ? Colors.blue : (isDark ? Colors.grey[800] : Colors.white)),
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                grid[row][col],
                                style: TextStyle(
                                  fontSize: gridSize <= 6 ? 18 : gridSize <= 8 ? 16 : 14,
                                  fontWeight: FontWeight.bold,
                                  color: (isSelected || isFound) ? Colors.white : (isDark ? Colors.white : Colors.black),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            // Overlay de pausa
            if (isPaused) PauseOverlay(
              onResume: _togglePause,
              onRestart: () {
                setState(() {
                  _initializeGame();
                  elapsedSeconds = 0;
                  timeLeft = ConstantesSopaLetras.duracionContrarreloj;
                  score = 0;
                  hintsUsed = 0;
                  isGameOver = false;
                  isVictory = false;
                  if (widget.isTimeAttackMode) {
                    _startTimer();
                  }
                });
              },
              onExit: () => Navigator.pop(context),
            ),

            // Game Over overlay
            if (isGameOver)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isVictory ? '¡Victoria!' : 'Game Over',
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (isVictory) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                String nextDifficulty = widget.difficulty == 'facil' ? 'medio' : widget.difficulty == 'medio' ? 'dificil' : 'facil';
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WordSearchGame(
                                      difficulty: nextDifficulty,
                                      theme: widget.theme,
                                      isTimeAttackMode: widget.isTimeAttackMode,
                                      isPerfectMode: widget.isPerfectMode,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Siguiente Nivel'),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Elegir Temática'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                        child: const Text('Volver al menú'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}