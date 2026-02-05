import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/game_control_buttons.dart';
import '../widgets/pause_overlay.dart';
import '../widgets/boton_guia.dart';
import '../data/guias_juegos.dart';
import '../tema/audio_settings.dart';
import '../tema/app_colors.dart';
import '../tema/language_provider.dart';
import '../constants/app_strings.dart';
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
  late List<String> bonusWords; // Palabras bonus ocultas
  late Set<String> foundBonusWords; // Palabras bonus encontradas
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

  // Variables para drag
  bool isDragging = false;
  GlobalKey gridKey = GlobalKey();
  double cellSize = 0;

  // Timer
  Timer? gameTimer;
  int elapsedSeconds = 0;
  int timeLeft = ConstantesSopaLetras.duracionContrarreloj;

  // Puntuación
  int score = 0;
  

  // Control de mensaje bonus
  bool showBonusMessage = false;
  late String lastBonusWord;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _startBackgroundMusic();
    if (widget.isTimeAttackMode) {
      _startTimer();
    }
  }

  void _startBackgroundMusic() {
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    AudioService.playLoop('Sonidos/music_sopadeletras.mp3', audioSettings.musicVolume);
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

    // Obtener idioma actual
    final currentLanguage = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;
    
    // Obtener lista de palabras de la temática, idioma y dificultad
    List<String> allWords = List.from(ConstantesSopaLetras.getPalabras(widget.theme, currentLanguage, widget.difficulty));

    // Remover espacios de las palabras y filtrar palabras vacías
    allWords = allWords.map((word) => word.replaceAll(' ', '')).where((word) => word.isNotEmpty).toList();

    // Mezclar todas las palabras disponibles y seleccionar candidatos
    allWords.shuffle(Random());
    int maxWords = ConstantesSopaLetras.maxPalabras[widget.difficulty] ?? 8;

    // Tomar candidatos (hasta maxWords) desde la lista mezclada
    List<String> candidateWords = allWords.take(maxWords).toList();

    // Determinar longitud máxima entre candidatos
    int maxLen = 0;
    if (candidateWords.isNotEmpty) {
      maxLen = candidateWords.map((w) => w.length).reduce(max);
    }

    // Recomendar tamaño mínimo en función del número de palabras: 3 + nPalabras
    int recommendedSize = max(gridSize, maxLen);
    recommendedSize = max(recommendedSize, 3 + candidateWords.length);
    // Evitar grids demasiado grandes
    recommendedSize = min(recommendedSize, 14);

    // Actualizar gridSize con el recomendado
    gridSize = recommendedSize;

    // Filtrar candidatos que quepan en el grid actual
    wordsToFind = candidateWords.where((word) => word.length <= gridSize).toList();

    // Si quedaron muy pocas o ninguna palabra válida, intentar cargar palabras por defecto
    if (wordsToFind.length < 3) {
      List<String> defaultWords = List.from(ConstantesSopaLetras.getPalabras('general', currentLanguage, widget.difficulty));
      defaultWords = defaultWords.map((word) => word.replaceAll(' ', '')).where((word) => word.isNotEmpty).toList();
      defaultWords.shuffle(Random());
      wordsToFind = defaultWords.where((word) => word.length <= gridSize).take(max(5, maxWords)).toList();
    }

    // Ordenar por longitud ascendente para colocar palabras cortas primero
    wordsToFind.sort((a, b) => a.length.compareTo(b.length));

    foundWords = {};
    foundBonusWords = {};
    
    // Agregar palabras bonus (1-2 palabras según dificultad)
    List<String> allBonusWords = List.from(ConstantesSopaLetras.getPalabras(widget.theme, currentLanguage, 'medio'));
    allBonusWords = allBonusWords.map((word) => word.replaceAll(' ', '')).where((word) => word.isNotEmpty && !wordsToFind.contains(word)).toList();
    allBonusWords.shuffle(Random());
    
    int numBonusWords = widget.difficulty == 'facil' ? 1 : (widget.difficulty == 'medio' ? 1 : 2);
    bonusWords = allBonusWords.take(numBonusWords).toList().where((word) => word.length <= gridSize).toList();
    
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
    
    // Colocar palabras bonus en el grid
    List<String> placedBonusWords = [];
    for (String word in bonusWords) {
      if (_placeWord(word)) {
        placedBonusWords.add(word);
      }
    }
    bonusWords = placedBonusWords;

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

  // Obtener la celda basándose en la posición del toque
  List<int>? _getCellFromPosition(Offset globalPosition) {
    final RenderBox? box = gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;

    final Offset localPosition = box.globalToLocal(globalPosition);

    // Calcular tamaño de celda incluyendo espaciado
    final double gridWidth = box.size.width;
    final double gridHeight = box.size.height;
    final double effectiveCellWidth = gridWidth / gridSize;
    final double effectiveCellHeight = gridHeight / gridSize;

    final int col = (localPosition.dx / effectiveCellWidth).floor();
    final int row = (localPosition.dy / effectiveCellHeight).floor();

    // Verificar que está dentro del grid
    if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
      return [row, col];
    }
    return null;
  }

  void _onPanStart(DragStartDetails details) {
    if (isPaused || isGameOver) return;

    final cell = _getCellFromPosition(details.globalPosition);
    if (cell != null) {
      setState(() {
        isDragging = true;
        startRow = cell[0];
        startCol = cell[1];
        selectedCells = [[cell[0], cell[1]]];
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!isDragging || isPaused || isGameOver) return;
    if (startRow == null || startCol == null) return;

    final cell = _getCellFromPosition(details.globalPosition);
    if (cell != null) {
      final int row = cell[0];
      final int col = cell[1];

      // Verificar si es una selección válida (línea recta)
      if (_isValidSelection(row, col)) {
        setState(() {
          selectedCells = _getCellsInLine(startRow!, startCol!, row, col);
        });
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!isDragging || isPaused || isGameOver) return;

    setState(() {
      isDragging = false;
      if (selectedCells.length >= 2) {
        _checkForWord();
      } else {
        // Limpiar si solo hay una celda
        selectedCells.clear();
        startRow = null;
        startCol = null;
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
    bool isBonusWord = false;
    
    // Primero verificar palabras normales
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
    
    // Si no se encontró palabra normal, verificar palabras bonus
    if (!found) {
      for (String word in bonusWords) {
        if (!foundBonusWords.contains(word) && (word == selectedWord || word == reversedWord)) {
          foundBonusWords.add(word);
          score += 50; // Puntos bonus adicionales
          // Marcar celdas como encontradas
          for (var cell in selectedCells) {
            foundCells.add('${cell[0]},${cell[1]}');
          }
          found = true;
          isBonusWord = true;
          lastBonusWord = word;
          
          // Mostrar mensaje de palabra bonus
          setState(() {
            showBonusMessage = true;
          });
          
          // Ocultar mensaje después de 2 segundos
          Future.delayed(Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                showBonusMessage = false;
              });
            }
          });
          break;
        }
      }
    }

    if (found && !isBonusWord) {
      if (foundWords.length == wordsToFind.length) {
        _victory();
      }
    }

    // Limpiar selección
    selectedCells.clear();
    startRow = null;
    startCol = null;
  }

  void _victory() {
    isVictory = true;
    isGameOver = true;
    gameTimer?.cancel();
    AudioService.stopLoop();
  }

  void _gameOver(bool victory) {
    isVictory = victory;
    isGameOver = true;
    gameTimer?.cancel();
    AudioService.stopLoop();
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    AudioService.stopLoop();
    super.dispose();
  }

  Widget _buildGameOverDialog() {
    final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: ColoresApp.blanco,
          title: Text(
            isVictory ? "🎉 ${AppStrings.get('congratulations', currentLang)}" : "💀 ${AppStrings.get('game_over', currentLang)}",
            style: TextStyle(color: ColoresApp.negro, fontWeight: FontWeight.bold),
          ),
          content: Text(
            isVictory
                ? "${AppStrings.get('words_found', currentLang)}: ${foundWords.length}/${wordsToFind.length}\n${AppStrings.get('score', currentLang)}: $score"
                : "${AppStrings.get('time_up', currentLang)}\n${AppStrings.get('words_found', currentLang)}: ${foundWords.length}/${wordsToFind.length}",
            style: TextStyle(color: ColoresApp.negro),
          ),
          actions: [
            if (isVictory)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
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
                child: Text(AppStrings.get('next_level', currentLang), style: TextStyle(color: ColoresApp.moradoPrincipal)),
              ),
            if (!isVictory)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _initializeGame();
                    timeLeft = ConstantesSopaLetras.duracionContrarreloj;
                    score = 0;
                    isGameOver = false;
                    isVictory = false;
                    if (widget.isTimeAttackMode) {
                      _startTimer();
                    }
                  });
                },
                child: Text(AppStrings.get('retry', currentLang), style: TextStyle(color: ColoresApp.moradoPrincipal)),
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(AppStrings.get('exit', currentLang), style: TextStyle(color: ColoresApp.rojoError)),
            ),
          ],
        ),
      );
    });

    return Container(
      color: Colors.black54,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
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
                      Expanded(
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Sopa de Letras',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          final currentLang = Provider.of<LanguageProvider>(context).currentLanguage;
                          return Row(
                            children: [
                              GameControlBar(
                                isPaused: isPaused,
                                onPausePressed: _togglePause,
                                onRestartPressed: () {
                                  setState(() {
                                    _initializeGame();
                                    elapsedSeconds = 0;
                                    timeLeft = ConstantesSopaLetras.duracionContrarreloj;
                                    score = 0;
                                    isGameOver = false;
                                    isVictory = false;
                                    isPaused = false;
                                    if (widget.isTimeAttackMode) {
                                      _startTimer();
                                    }
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              BotonGuia(
                                gameTitle: 'Sopa de Letras',
                                gameImagePath: 'assets/imagenes/sopadeletras.png',
                                objetivo: AppStrings.get('wordsearch_objective', currentLang),
                                instrucciones: [
                                  AppStrings.get('wordsearch_inst_1', currentLang),
                                  AppStrings.get('wordsearch_inst_2', currentLang),
                                  AppStrings.get('wordsearch_inst_3', currentLang),
                                  AppStrings.get('wordsearch_inst_4', currentLang),
                                  AppStrings.get('wordsearch_inst_5', currentLang),
                                ],
                                controles: GuiasJuegos.getWordSearchControles(currentLang),
                                size: 40,
                                onOpen: () => setState(() => isPaused = true),
                                onClose: () => setState(() => isPaused = false),
                              ),
                            ],
                          );
                        },
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
                    child: GestureDetector(
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Calcular el tamaño disponible para el grid cuadrado
                          final double availableSize = min(constraints.maxWidth, constraints.maxHeight);

                          return Center(
                            child: SizedBox(
                              width: availableSize,
                              height: availableSize,
                              child: GridView.builder(
                                key: gridKey,
                                physics: const NeverScrollableScrollPhysics(),
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
                                  bool isFound = foundCells.contains('${row},${col}');

                                  return Container(
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
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
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
                  isGameOver = false;
                  isVictory = false;
                  isPaused = false;
                  if (widget.isTimeAttackMode) {
                    _startTimer();
                  }
                });
              },
              onExit: () => Navigator.pop(context),
            ),

            // Bonus word message overlay
            if (showBonusMessage)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.amber[600],
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppStrings.get('bonus_word_found', Provider.of<LanguageProvider>(context).currentLanguage),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '✨ $lastBonusWord ✨',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.get('bonus_points', Provider.of<LanguageProvider>(context).currentLanguage),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Game Over overlay
            if (isGameOver)
              _buildGameOverDialog(),
          ],
        ),
      ),
    );
  }
}