import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tema/audio_settings.dart';
import '../tema/app_colors.dart';
import '../tema/language_provider.dart';
import '../constants/app_strings.dart';
import '../services/audio_service.dart';
import '../constants/sopa_de_letras_constants.dart';

class SopaDeLetrasGame extends StatefulWidget {
  final String difficulty; // 'facil', 'medio', 'dificil'
  final bool isTimeAttackMode; // Modo contrarreloj

  const SopaDeLetrasGame({
    super.key,
    this.difficulty = 'facil',
    this.isTimeAttackMode = false,
  });

  @override
  State<SopaDeLetrasGame> createState() => _SopaDeLetrasGameState();
}

class _SopaDeLetrasGameState extends State<SopaDeLetrasGame> {
  // Tablero de letras
  late List<List<String>> grid;
  late int gridSize;

  // Lista de palabras a encontrar
  List<String> wordsToFind = [];
  List<String> foundWords = [];

  // Posiciones de las palabras en el tablero
  Map<String, List<List<int>>> wordPositions = {};

  // Estado de selecciÃ³n
  List<List<int>> selectedPositions = [];
  bool isSelecting = false;

  // Timer del juego
  Timer? gameTimer;

  // Variables de tiempo
  int elapsedSeconds = 0;
  int timeLeft = ConstantesSopaDeLetras.duracionContrarreloj;

  // Variables de progreso
  int wordsFound = 0;
  int totalWords = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
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

  void _initializeGame() {
    // Determinar tamaÃ±o del tablero segÃºn dificultad
    switch (widget.difficulty) {
      case 'facil':
        gridSize = ConstantesSopaDeLetras.tamanoTableroFacil;
        wordsToFind = _getRandomWords(ConstantesSopaDeLetras.numPalabrasFacil, ConstantesSopaDeLetras.palabrasFacil);
        break;
      case 'medio':
        gridSize = ConstantesSopaDeLetras.tamanoTableroMedio;
        wordsToFind = _getRandomWords(ConstantesSopaDeLetras.numPalabrasMedio, ConstantesSopaDeLetras.palabrasMedio);
        break;
      case 'dificil':
        gridSize = ConstantesSopaDeLetras.tamanoTableroDificil;
        wordsToFind = _getRandomWords(ConstantesSopaDeLetras.numPalabrasDificil, ConstantesSopaDeLetras.palabrasDificil);
        break;
      default:
        gridSize = ConstantesSopaDeLetras.tamanoTableroFacil;
        wordsToFind = _getRandomWords(ConstantesSopaDeLetras.numPalabrasFacil, ConstantesSopaDeLetras.palabrasFacil);
    }

    totalWords = wordsToFind.length;
    grid = List.generate(gridSize, (_) => List.filled(gridSize, ''));
    _generateGrid();
  }

  List<String> _getRandomWords(int count, List<String> sourceList) {
    final random = Random();
    final shuffled = List<String>.from(sourceList)..shuffle(random);
    return shuffled.take(count).toList();
  }

  void _generateGrid() {
    // Inicializar grid con letras aleatorias
    final random = Random();
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        grid[i][j] = ConstantesSopaDeLetras.letrasValidas[random.nextInt(ConstantesSopaDeLetras.letrasValidas.length)];
      }
    }

    // Colocar palabras en el grid
    wordPositions.clear();
    for (String word in wordsToFind) {
      _placeWord(word);
    }
  }

  bool _placeWord(String word) {
    final random = Random();
    final directions = ConstantesSopaDeLetras.direcciones;

    // Intentar colocar la palabra hasta 100 veces
    for (int attempt = 0; attempt < 100; attempt++) {
      int startRow = random.nextInt(gridSize);
      int startCol = random.nextInt(gridSize);
      List<int> direction = directions[random.nextInt(directions.length)];

      if (_canPlaceWord(word, startRow, startCol, direction)) {
        List<List<int>> positions = [];
        for (int i = 0; i < word.length; i++) {
          int row = startRow + i * direction[0];
          int col = startCol + i * direction[1];
          grid[row][col] = word[i];
          positions.add([row, col]);
        }
        wordPositions[word] = positions;
        return true;
      }
    }
    return false; // No se pudo colocar
  }

  bool _canPlaceWord(String word, int startRow, int startCol, List<int> direction) {
    for (int i = 0; i < word.length; i++) {
      int row = startRow + i * direction[0];
      int col = startCol + i * direction[1];

      if (row < 0 || row >= gridSize || col < 0 || col >= gridSize) {
        return false; // Fuera de lÃ­mites
      }

      if (grid[row][col] != word[i] && grid[row][col] != '') {
        // La celda ya tiene una letra diferente
        continue; // Permitir sobreescribir si es la misma letra
      }
    }
    return true;
  }

  void _onPanStart(DragStartDetails details, int row, int col) {
    setState(() {
      isSelecting = true;
      selectedPositions = [[row, col]];
    });
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (!isSelecting) return;

    final cellSize = constraints.maxWidth / gridSize;
    final localPosition = details.localPosition;

    int row = (localPosition.dy / cellSize).floor();
    int col = (localPosition.dx / cellSize).floor();

    if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
      final newPos = [row, col];
      if (!selectedPositions.any((pos) => pos[0] == row && pos[1] == col)) {
        setState(() {
          selectedPositions.add(newPos);
        });
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!isSelecting) return;

    setState(() {
      isSelecting = false;
    });

    _checkSelection();
  }

  void _checkSelection() {
    if (selectedPositions.length < 2) {
      selectedPositions.clear();
      return;
    }

    // Ordenar las posiciones seleccionadas por fila y luego por columna
    selectedPositions.sort((a, b) {
      if (a[0] != b[0]) return a[0].compareTo(b[0]);
      return a[1].compareTo(b[1]);
    });

    String selectedWord = '';
    for (var pos in selectedPositions) {
      selectedWord += grid[pos[0]][pos[1]];
    }

    // Verificar si la palabra seleccionada estÃ¡ en la lista
    String? foundWord;
    for (String word in wordsToFind) {
      if (!foundWords.contains(word) && (selectedWord == word || selectedWord == word.split('').reversed.join(''))) {
        foundWord = word;
        break;
      }
    }

    if (foundWord != null) {
      setState(() {
        foundWords.add(foundWord!);
        wordsFound++;
        _playSound('food.mp3');
      });

      if (wordsFound == totalWords) {
        gameTimer?.cancel();
        _gameOver(true);
      }
    } else {
      _playSound('obstaculo.mp3');
    }

    selectedPositions.clear();
  }

  void _showHint() {
    // Mostrar una pista: resaltar una palabra no encontrada
    for (String word in wordsToFind) {
      if (!foundWords.contains(word) && wordPositions.containsKey(word)) {
        setState(() {
          // AquÃ­ podrÃ­amos resaltar temporalmente la palabra
          // Por simplicidad, solo reproducir sonido
        });
        _playSound('move.mp3');
        return;
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
              Navigator.pop(context); // Cerrar diÃ¡logo
              Navigator.pop(context); // Volver al menÃº
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
            ),
            child: Text(AppStrings.get('exit_menu', currentLang)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diÃ¡logo
              setState(() {
                _initializeGame();
                foundWords.clear();
                wordsFound = 0;
                elapsedSeconds = 0;
                timeLeft = ConstantesSopaDeLetras.duracionContrarreloj;
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLang = Provider.of<LanguageProvider>(context).currentLanguage;

    return Scaffold(
      backgroundColor: isDark ? ColoresApp.gris800 : ColoresApp.gris100,
      body: SafeArea(
        child: Column(
          children: [
            // Header con informaciÃ³n
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // BotÃ³n de cerrar
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
                      '$wordsFound/$totalWords',
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

            // Contenido principal
            Expanded(
              child: Row(
                children: [
                  // Tablero de letras
                  Expanded(
                    flex: 3,
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
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final cellSize = constraints.maxWidth / gridSize;
                              return GestureDetector(
                                onPanStart: (details) {
                                  final cellSize = constraints.maxWidth / gridSize;
                                  int row = (details.localPosition.dy / cellSize).floor();
                                  int col = (details.localPosition.dx / cellSize).floor();
                                  if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
                                    _onPanStart(details, row, col);
                                  }
                                },
                                onPanUpdate: (details) => _onPanUpdate(details, constraints),
                                onPanEnd: _onPanEnd,
                                child: GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: gridSize,
                                  ),
                                  itemCount: gridSize * gridSize,
                                  itemBuilder: (context, index) {
                                    int row = index ~/ gridSize;
                                    int col = index % gridSize;

                                    bool isSelected = selectedPositions.any((pos) => pos[0] == row && pos[1] == col);
                                    bool isFound = wordPositions.entries.any((entry) =>
                                        foundWords.contains(entry.key) &&
                                        entry.value.any((pos) => pos[0] == row && pos[1] == col));

                                    Color backgroundColor = ColoresApp.blanco;
                                    if (isFound) {
                                      backgroundColor = ColoresApp.verdeExito;
                                    } else if (isSelected) {
                                      backgroundColor = ColoresApp.colorCeldaRelacionada;
                                    }

                                    return Container(
                                      decoration: BoxDecoration(
                                        color: backgroundColor,
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          grid[row][col],
                                          style: TextStyle(
                                            fontSize: cellSize * 0.4,
                                            fontWeight: FontWeight.bold,
                                            color: isFound ? ColoresApp.blanco : ColoresApp.negro,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Lista de palabras
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.get('control_found_words', currentLang),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7B3FF2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              itemCount: wordsToFind.length,
                              itemBuilder: (context, index) {
                                String word = wordsToFind[index];
                                bool isFound = foundWords.contains(word);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    word,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isFound ? Colors.grey : ColoresApp.negro,
                                      decoration: isFound ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Controles
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // BotÃ³n Pista
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
            ),
          ],
        ),
      ),
    );
  }
  }
