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
import '../constants/sopa_de_letras_constants.dart';
import '../providers/mission_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/hint_button.dart';
import '../widgets/game_stat_badge.dart';
import '../widgets/game_header.dart';
import '../services/game_progress_service.dart';

class WordSearchGame extends StatefulWidget {
  final String difficulty; // 'facil', 'medio', 'dificil' (usado para modos especiales)
  final String theme; // 'general', 'peliculas', 'musica', 'historia'
  final bool isTimeAttackMode; // Modo contrarreloj
  final bool isPerfectMode; // Modo perfecto (sin errores)
  final int? level; // Nivel actual (modo normal con niveles)

  const WordSearchGame({
    super.key,
    this.difficulty = 'facil',
    this.theme = 'general',
    this.isTimeAttackMode = false,
    this.isPerfectMode = false,
    this.level, // Si es null, usa dificultad clásica
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

  // Sistema de pistas
  late int hintsAvailable;
  int usedHints = 0;
  List<int>? highlightedCell; // Celda resaltada por pista
  Set<String> _hintedWords = {}; // Palabras que ya se mostraron como pistas

  // Control de mensaje bonus
  bool showBonusMessage = false;
  late String lastBonusWord;

  // Sistema de niveles
  late int currentLevel;
  LevelConfig? levelConfig;

  @override
  void initState() {
    super.initState();

    // Rastrear pantalla actual
    appLogger.setCurrentScreen('SopaDeLetrasGame');

    // Inicializar nivel
    currentLevel = widget.level ?? 1;

    // Log inicio de partida
    String mode = 'normal';
    if (widget.isTimeAttackMode) mode = 'time_attack';
    if (widget.isPerfectMode) mode = 'perfect';
    if (widget.level != null) mode = 'levels';
    appLogger.gameEvent('SopaDeLetras', 'game_start', data: {'difficulty': widget.difficulty, 'theme': widget.theme, 'mode': mode, 'level': currentLevel});

    // Precargar efectos de sonido para reproducción instantánea
    AudioService.preloadSounds([
      'Sonidos/soft_touch.wav',
      'Sonidos/word_ok.wav',
      'Sonidos/hint.wav',
      // TODO: Añadir sonidos adicionales cuando se implementen:
      // 'Sonidos/victory.ogg',     // Sonido de victoria
      // 'Sonidos/word_error.ogg',  // Sonido de palabra incorrecta
    ]);

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
    // Obtener idioma actual
    final currentLanguage = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;

    // Variables locales para configuración
    int maxWords;
    String difficultyCategory;

    // Reiniciar lista de palabras mostradas como pistas
    _hintedWords = {};

    // Si es modo con niveles (widget.level != null), usar configuración de nivel
    if (widget.level != null) {
      levelConfig = ConstantesSopaLetras.getLevelConfig(currentLevel);
      gridSize = levelConfig!.gridSize;
      maxWords = levelConfig!.wordCount;
      hintsAvailable = levelConfig!.hints;
      difficultyCategory = levelConfig!.difficultyCategory;
    } else {
      // Modo clásico con dificultad
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
      maxWords = ConstantesSopaLetras.maxPalabras[widget.difficulty] ?? 8;
      hintsAvailable = widget.difficulty == 'facil' ? 3 : widget.difficulty == 'medio' ? 2 : 1;
      difficultyCategory = widget.difficulty;
    }

    // Obtener lista de palabras de la temática, idioma y dificultad
    List<String> allWords = List.from(ConstantesSopaLetras.getPalabras(widget.theme, currentLanguage, difficultyCategory));

    // Remover espacios de las palabras y filtrar palabras vacías
    allWords = allWords.map((word) => word.replaceAll(' ', '')).where((word) => word.isNotEmpty).toList();

    // Si es modo con niveles, filtrar por longitud de palabra
    if (widget.level != null && levelConfig != null) {
      allWords = allWords.where((word) =>
        word.length >= levelConfig!.minWordLength &&
        word.length <= levelConfig!.maxWordLength
      ).toList();
    }

    // Mezclar todas las palabras disponibles y seleccionar candidatos
    allWords.shuffle(Random());

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
      List<String> defaultWords = List.from(ConstantesSopaLetras.getPalabras('general', currentLanguage, difficultyCategory));
      defaultWords = defaultWords.map((word) => word.replaceAll(' ', '')).where((word) => word.isNotEmpty).toList();
      defaultWords.shuffle(Random());
      wordsToFind = defaultWords.where((word) => word.length <= gridSize).take(max(5, maxWords)).toList();
    }

    // Ordenar por longitud ascendente para colocar palabras cortas primero
    wordsToFind.sort((a, b) => a.length.compareTo(b.length));

    foundWords = {};
    foundBonusWords = {};
    usedHints = 0;
    highlightedCell = null;

    // Agregar palabras bonus (1-2 palabras según dificultad)
    List<String> allBonusWords = List.from(ConstantesSopaLetras.getPalabras(widget.theme, currentLanguage, 'medio'));
    allBonusWords = allBonusWords.map((word) => word.replaceAll(' ', '')).where((word) => word.isNotEmpty && !wordsToFind.contains(word)).toList();
    allBonusWords.shuffle(Random());

    int numBonusWords = difficultyCategory == 'facil' ? 1 : (difficultyCategory == 'medio' ? 1 : 2);
    bonusWords = allBonusWords.take(numBonusWords).toList().where((word) => word.length <= gridSize).toList();

    wordPositions = {};
    foundCells = {};
    _generateGrid();
  }

  void _generateWordPlacements() {
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
  }

  void _generateGrid() {
    grid = List.generate(
      gridSize,
      (_) => List.filled(gridSize, ''),
    );

    _generateWordPlacements();

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
      // Reproducir sonido de toque
      final audioSettings = Provider.of<AudioSettings>(context, listen: false);
      AudioService.playSound('Sonidos/soft_touch.wav', audioSettings.sfxVolume);

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
        final newCells = _getCellsInLine(startRow!, startCol!, row, col);

        // Solo reproducir sonido si cambió la cantidad de celdas seleccionadas
        if (newCells.length != selectedCells.length) {
          final audioSettings = Provider.of<AudioSettings>(context, listen: false);
          AudioService.playSound('Sonidos/soft_touch.wav', audioSettings.sfxVolume);
        }

        setState(() {
          selectedCells = newCells;
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

  void _handleBonusWord(String word) {
    foundBonusWords.add(word);
    score += 50; // Puntos bonus adicionales
    // Marcar celdas como encontradas
    for (var cell in selectedCells) {
      foundCells.add('${cell[0]},${cell[1]}');
    }
    lastBonusWord = word;

    // Reproducir sonido de palabra correcta
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    AudioService.playSound('Sonidos/word_ok.wav', audioSettings.sfxVolume);

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

        // Reproducir sonido de palabra correcta
        final audioSettings = Provider.of<AudioSettings>(context, listen: false);
        AudioService.playSound('Sonidos/word_ok.wav', audioSettings.sfxVolume);

        // Notificar misión de palabra encontrada
        final missionProvider = Provider.of<MissionProvider>(context, listen: false);
        missionProvider.notifyActivity(gameType: 'sopadeletras', activityType: MissionType.findWords);

        break;
      }
    }

    // Si no se encontró palabra normal, verificar palabras bonus
    if (!found) {
      for (String word in bonusWords) {
        if (!foundBonusWords.contains(word) && (word == selectedWord || word == reversedWord)) {
          _handleBonusWord(word);
          found = true;
          isBonusWord = true;
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

  void _victory() async {
    // Notificar misiones
    final missionProvider = Provider.of<MissionProvider>(context, listen: false);
    missionProvider.notifyActivity(gameType: 'sopadeletras', activityType: MissionType.playGames);
    missionProvider.notifyActivity(gameType: 'sopadeletras', activityType: MissionType.completeLevels);

    isVictory = true;
    isGameOver = true;
    gameTimer?.cancel();
    AudioService.stopLoop();

    // Si es modo con niveles, guardar progreso
    if (widget.level != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.getToken();
      await GameProgressService.saveProgress(
        gameType: ConstantesSopaLetras.gameType,
        completedLevel: currentLevel,
        isGuest: authProvider.isGuest,
        token: token,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showGameResult(true);
    });
  }

  void _gameOver(bool victory) {
    // Log fin de partida
    appLogger.gameEvent('SopaDeLetras', 'game_end', data: {'won': victory, 'wordsFound': foundWords.length});

    // Notificar misiones
    final missionProvider = Provider.of<MissionProvider>(context, listen: false);
    missionProvider.notifyActivity(gameType: 'sopadeletras', activityType: MissionType.playGames);
    if (victory) {
      missionProvider.notifyActivity(gameType: 'sopadeletras', activityType: MissionType.completeLevels);
    }

    isVictory = victory;
    isGameOver = true;
    gameTimer?.cancel();
    AudioService.stopLoop();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showGameResult(victory);
    });
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  void _showHint() {
    if (usedHints >= hintsAvailable) {
      final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('no_hints_left', currentLang)),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Buscar una palabra no encontrada que NO haya sido mostrada como pista antes
    String? wordToReveal;
    for (String word in wordsToFind) {
      if (!foundWords.contains(word) && !_hintedWords.contains(word)) {
        wordToReveal = word;
        break;
      }
    }

    // Si todas las palabras ya fueron mostradas como pista, buscar cualquier no encontrada
    if (wordToReveal == null) {
      for (String word in wordsToFind) {
        if (!foundWords.contains(word)) {
          wordToReveal = word;
          break;
        }
      }
    }

    if (wordToReveal == null) return;

    // Obtener posición inicial de la palabra
    List<List<int>>? positions = wordPositions[wordToReveal];
    if (positions == null || positions.isEmpty) return;

    // Agregar palabra a la lista de pistas usadas
    _hintedWords.add(wordToReveal);

    // Reproducir sonido de pista DESPUÉS de validar que hay pista disponible
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    AudioService.playSound('Sonidos/hint.wav', audioSettings.sfxVolume);

    setState(() {
      usedHints++;
      score = max(0, score - ConstantesSopaLetras.penalizacionPista);
      highlightedCell = positions[0]; // Primera celda de la palabra
    });

    final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.lightbulb, color: Colors.amber),
            const SizedBox(width: 8),
            Text(AppStrings.get('hint', currentLang)),
          ],
        ),
        content: Text(
          '${AppStrings.get('hint_word_starts', currentLang)}: $wordToReveal',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.get('understood', currentLang)),
          ),
        ],
      ),
    );

    // Quitar resaltado después de 5 segundos
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          highlightedCell = null;
        });
      }
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    AudioService.stopLoop();
    super.dispose();
  }

  void _showGameResult(bool victory) {
    final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;

    String message;
    if (widget.level != null && victory) {
      // Modo con niveles
      message = "${AppStrings.get('level', currentLang)} $currentLevel ${AppStrings.get('completed', currentLang)}!\n${AppStrings.get('words_found', currentLang)}: ${foundWords.length}/${wordsToFind.length}";
    } else if (victory) {
      message = "${AppStrings.get('words_found', currentLang)}: ${foundWords.length}/${wordsToFind.length}";
    } else {
      message = "${AppStrings.get('time_up', currentLang)}\n${AppStrings.get('words_found', currentLang)}: ${foundWords.length}/${wordsToFind.length}";
    }

    final audioSettings = Provider.of<AudioSettings>(context, listen: false);

    GameOverDialog.show(
      context: context,
      isVictory: victory,
      message: message,
      audioSettings: audioSettings,
      onRestart: () {
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
      onExit: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
      onNextLevel: victory ? () {
        Navigator.pop(context);

        if (widget.level != null) {
          // Modo con niveles: ir al siguiente nivel
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WordSearchGame(
                theme: widget.theme,
                level: currentLevel + 1,
              ),
            ),
          );
        } else {
          // Modo clásico: siguiente dificultad
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
        }
      } : null,
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
        if (widget.level != null)
          GameStatBadge(
            text: '${AppStrings.get('level', currentLang)} $currentLevel',
            icon: Icons.emoji_events,
            color: ColoresApp.moradoPrincipal,
            fontSize: fontSize,
            hPad: hPad,
            gap: gap,
          ),
        if (widget.isTimeAttackMode)
          GameStatBadge(
            text: '${timeLeft ~/ 60}:${(timeLeft % 60).toString().padLeft(2, '0')}',
            icon: Icons.timer,
            color: ColoresApp.verdeExito,
            isWarning: timeLeft < 60,
            fontSize: fontSize,
            hPad: hPad,
            gap: gap,
          ),
      ],
      isPaused: isPaused,
      onPause: _togglePause,
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
      onClose: () {
        gameTimer?.cancel();
        AudioService.stopLoop();
        Navigator.pop(context);
      },
      hintButton: HintButton(
        hintsRemaining: hintsAvailable - usedHints,
        onTap: isGameOver ? null : _showHint,
        size: btnSize,
      ),
      guideButton: BotonGuia(
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
        size: btnSize,
        onOpen: () { if (!isPaused) _togglePause(); },
        onClose: () { if (isPaused) _togglePause(); },
      ),
    );
  }

  Widget _buildWordList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(minHeight: 60, maxHeight: 120),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: wordsToFind.map((word) {
            bool isFound = foundWords.contains(word);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isFound ? Colors.green : (isDark ? Colors.grey[800] : Colors.grey[200]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                word,
                style: TextStyle(
                  fontSize: 13,
                  color: isFound ? Colors.white : (isDark ? Colors.white : Colors.black),
                  decoration: isFound ? TextDecoration.lineThrough : null,
                  fontWeight: isFound ? FontWeight.normal : FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildWordGrid(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
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
                      bool isFound = foundCells.contains('$row,$col');
                      bool isHinted = highlightedCell != null && highlightedCell![0] == row && highlightedCell![1] == col;

                      return Container(
                        decoration: BoxDecoration(
                          color: isHinted ? Colors.amber : (isFound ? Colors.green : (isSelected ? Colors.blue : (isDark ? Colors.grey[800] : Colors.white))),
                          border: Border.all(color: isHinted ? Colors.amber[800]! : Colors.grey, width: isHinted ? 3 : 1),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLang = Provider.of<LanguageProvider>(context).currentLanguage;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header con controles
                _buildHeader(isDark),

                // Lista de palabras
                _buildWordList(context),

                // Grid del juego
                _buildWordGrid(context),
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
              onExit: () {
                gameTimer?.cancel();
                AudioService.stopLoop();
                Navigator.pop(context);
              },
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
                            AppStrings.get('bonus_word_found', currentLang),
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
                            AppStrings.get('bonus_points', currentLang),
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

          ],
        ),
      ),
    );
  }
}