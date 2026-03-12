import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/app_logger.dart';
import '../widgets/pause_overlay.dart';
import '../widgets/boton_guia.dart';
import '../constants/guias_juegos.dart';
import '../config/audio_settings.dart';
import '../config/app_colors.dart';
import '../config/language_provider.dart';
import '../constants/app_strings.dart';
import '../services/audio_service.dart';
import '../constants/water_sort_constants.dart';
import '../providers/mission_provider.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/game_stat_badge.dart';
import '../widgets/game_header.dart';

/// Juego Water Sort - Ordena los colores en tubos
class WaterSortGame extends StatefulWidget {
  final String difficulty;
  final bool isTimeAttackMode;
  final bool isMinMovesMode;

  const WaterSortGame({
    super.key,
    this.difficulty = 'facil',
    this.isTimeAttackMode = false,
    this.isMinMovesMode = false,
  });

  @override
  State<WaterSortGame> createState() => _WaterSortGameState();
}

class _WaterSortGameState extends State<WaterSortGame> with TickerProviderStateMixin {
  late List<List<Color>> tubes;
  int? selectedTube;
  int moves = 0;
  bool gameWon = false;
  bool gameOver = false;
  int timeLeft = 0;
  int level = 1;

  // Para animaciones
  AnimationController? _pourAnimationController;
  int? pouringFromTube;
  int? pouringToTube;
  bool isPouring = false;

  // Historial para deshacer
  List<List<List<Color>>> history = [];

  // Sistema de pistas
  int hintsAvailable = 3;
  int usedHints = 0;
  int? suggestedFromTube;
  int? suggestedToTube;

  // Estado de pausa
  bool isPaused = false;

  // Control de diálogos
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();

    // Rastrear pantalla actual
    appLogger.setCurrentScreen('WaterSortGame');

    // Log inicio de partida
    String mode = 'normal';
    if (widget.isTimeAttackMode) mode = 'time_attack';
    if (widget.isMinMovesMode) mode = 'min_moves';
    appLogger.gameEvent('WaterSort', 'game_start', data: {'difficulty': widget.difficulty, 'mode': mode});

    _loadSavedLevel();

    // Precargar efectos de sonido
    AudioService.preloadSounds([
      'Sonidos/pour_water.ogg',
      'Sonidos/tube_complete.ogg',
      'Sonidos/tube_shake.ogg',
      'Sonidos/hint.wav',
    ]);

    _startBackgroundMusic();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AudioSettings>(context, listen: false).addListener(_onAudioSettingsChanged);
    });

    _pourAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  Future<void> _loadSavedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLevel = prefs.getInt('watersort_level_${widget.difficulty}') ?? 1;
    setState(() {
      level = savedLevel;
    });
    _initGame();
  }

  Future<void> _saveLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('watersort_level_${widget.difficulty}', level);
  }

  @override
  void dispose() {
    _pourAnimationController?.dispose();
    AudioService.stopLoop();
    try {
      Provider.of<AudioSettings>(context, listen: false).removeListener(_onAudioSettingsChanged);
    } catch (e) {}
    super.dispose();
  }

  void _onAudioSettingsChanged() {
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    AudioService.setLoopVolume(audioSettings.musicVolume);
  }

  void _startBackgroundMusic() {
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    AudioService.playLoop('Sonidos/music_watersort.mp3', audioSettings.musicVolume);
  }

  void _initGame() {
    final config = ConstantesWaterSort.getDifficultyConfig(widget.difficulty);

    // Calcular dificultad progresiva basada en el nivel
    int baseColors = config['colors'] as int;
    int extraTubes = config['tubesExtra'] as int;

    // Cada 3 niveles añadimos un color más (hasta un máximo de 12)
    int additionalColors = (level - 1) ~/ 3;
    int totalColors = (baseColors + additionalColors).clamp(baseColors, 12);

    // Cada 5 niveles reducimos un tubo extra (mínimo 1)
    int reducedTubes = (level - 1) ~/ 5;
    int finalExtraTubes = (extraTubes - reducedTubes).clamp(1, extraTubes);

    tubes = _generatePuzzle(totalColors, finalExtraTubes);

    selectedTube = null;
    moves = 0;
    gameWon = false;
    gameOver = false;
    history.clear();
    usedHints = 0;
    suggestedFromTube = null;
    suggestedToTube = null;
    // Pistas por dificultad: fácil 3, medio 2, difícil 1
    hintsAvailable = widget.difficulty == 'facil' ? 3 : widget.difficulty == 'medio' ? 2 : 1;

    if (widget.isTimeAttackMode) {
      // Reducir tiempo según nivel (mínimo 60 segundos)
      int baseTime = config['timeLimit'] as int;
      int timeReduction = (level - 1) * 5;
      timeLeft = (baseTime - timeReduction).clamp(60, baseTime);
      _startTimer();
    }

    if (widget.isMinMovesMode) {
      // En modo mínimos movimientos se guarda el objetivo
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && widget.isTimeAttackMode && !gameWon && !gameOver && !isPaused) {
        setState(() {
          timeLeft--;
          if (timeLeft <= 0) {
            gameOver = true;
          }
        });
        if (gameOver && !gameWon) {
          _showGameOverDialog();
        } else if (!gameOver && !gameWon) {
          _startTimer();
        }
      } else if (mounted && widget.isTimeAttackMode && isPaused && !gameWon && !gameOver) {
        // Si está pausado, seguir esperando
        _startTimer();
      }
    });
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  List<List<Color>> _generatePuzzle(int numColors, int extraTubes) {
    final random = Random();
    final colors = ConstantesWaterSort.waterColors.take(numColors).toList();

    // Crear lista de todos los segmentos de color (4 de cada uno)
    List<Color> allSegments = [];
    for (var color in colors) {
      for (int i = 0; i < ConstantesWaterSort.tubeCapacity; i++) {
        allSegments.add(color);
      }
    }

    // Mezclar
    allSegments.shuffle(random);

    // Distribuir en tubos
    List<List<Color>> result = [];
    int index = 0;
    for (int i = 0; i < numColors; i++) {
      List<Color> tube = [];
      for (int j = 0; j < ConstantesWaterSort.tubeCapacity; j++) {
        tube.add(allSegments[index++]);
      }
      result.add(tube);
    }

    // Agregar tubos vacíos
    for (int i = 0; i < extraTubes; i++) {
      result.add([]);
    }

    return result;
  }

  void _saveState() {
    history.add(tubes.map((tube) => List<Color>.from(tube)).toList());
    // Limitar historial a 50 movimientos
    if (history.length > 50) {
      history.removeAt(0);
    }
  }

  void _undo() {
    if (history.isNotEmpty) {
      setState(() {
        tubes = history.removeLast();
        moves = moves > 0 ? moves - 1 : 0;
        selectedTube = null;
      });
          }
  }

  // Returns a record (from, to) of the best hint move, or (null, null) if none found.
  (int?, int?) _findHintMove() {
    int? bestFrom;
    int? bestTo;
    int bestScore = -1;

    for (int from = 0; from < tubes.length; from++) {
      if (tubes[from].isEmpty) continue;

      for (int to = 0; to < tubes.length; to++) {
        if (from == to) continue;
        if (!_canPour(from, to)) continue;

        // Calcular puntuación del movimiento
        int score = 0;
        Color topColor = tubes[from].last;

        // Preferir mover a un tubo vacío si el origen tiene un solo color
        if (tubes[to].isEmpty) {
          // Contar cuántos del mismo color hay arriba en el tubo origen
          int sameColorCount = 0;
          for (int i = tubes[from].length - 1; i >= 0; i--) {
            if (tubes[from][i] == topColor) sameColorCount++;
            else break;
          }
          // Si el tubo tiene solo un color, no mover a vacío
          if (tubes[from].toSet().length == 1) {
            score = 1;
          } else {
            score = 5 + sameColorCount;
          }
        } else {
          // Mover a tubo con el mismo color
          int sameColorCount = 0;
          for (int i = tubes[from].length - 1; i >= 0; i--) {
            if (tubes[from][i] == topColor) sameColorCount++;
            else break;
          }
          score = 10 + sameColorCount;

          // Bonus si completaría un tubo
          int targetSpace = ConstantesWaterSort.tubeCapacity - tubes[to].length;
          if (sameColorCount <= targetSpace && tubes[to].toSet().length == 1) {
            score += 20;
          }
        }

        if (score > bestScore) {
          bestScore = score;
          bestFrom = from;
          bestTo = to;
        }
      }
    }

    return (bestFrom, bestTo);
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

    // Reproducir sonido de pista
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    AudioService.playSound('Sonidos/hint.wav', audioSettings.sfxVolume);

    final (bestFrom, bestTo) = _findHintMove();

    if (bestFrom != null && bestTo != null) {
      setState(() {
        usedHints++;
        suggestedFromTube = bestFrom;
        suggestedToTube = bestTo;
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
            AppStrings.get('hint_next_move', currentLang),
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
            suggestedFromTube = null;
            suggestedToTube = null;
          });
        }
      });
    } else {
      final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('no_valid_moves', currentLang)),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _onTubeTap(int index) {
    if (gameWon || gameOver || isPouring || isPaused) return;

    setState(() {
      if (selectedTube == null) {
        // Seleccionar tubo si tiene contenido
        if (tubes[index].isNotEmpty) {
          selectedTube = index;
                  }
      } else if (selectedTube == index) {
        // Deseleccionar
        selectedTube = null;
      } else {
        // Intentar verter
        if (_canPour(selectedTube!, index)) {
          _pourWater(selectedTube!, index);
        } else {
          // No se puede verter - reproducir sonido de bloqueo
          final audioSettings = Provider.of<AudioSettings>(context, listen: false);
          AudioService.playSound('Sonidos/tube_shake.ogg', audioSettings.sfxVolume);

          // Si no se puede verter, seleccionar el nuevo tubo si tiene contenido
          if (tubes[index].isNotEmpty) {
            selectedTube = index;
          } else {
            selectedTube = null;
          }
        }
      }
    });
  }

  bool _canPour(int from, int to) {
    if (tubes[from].isEmpty) return false;
    if (tubes[to].length >= ConstantesWaterSort.tubeCapacity) return false;
    if (tubes[to].isEmpty) return true;
    return tubes[from].last == tubes[to].last;
  }

  void _pourWater(int from, int to) {
    _saveState();

    // Reproducir sonido de vertido
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    AudioService.playSound('Sonidos/pour_water.ogg', audioSettings.sfxVolume);

    setState(() {
      isPouring = true;
      pouringFromTube = from;
      pouringToTube = to;
    });

    // Iniciar animación sin bloquear
    _pourAnimationController!.forward(from: 0.0).then((_) {
      if (!mounted) return;

      setState(() {
        Color colorToMove = tubes[from].last;

        // Mover todos los segmentos del mismo color que estén arriba
        while (tubes[from].isNotEmpty &&
               tubes[from].last == colorToMove &&
               tubes[to].length < ConstantesWaterSort.tubeCapacity) {
          tubes[to].add(tubes[from].removeLast());
        }

        moves++;
        selectedTube = null;
        isPouring = false;
        pouringFromTube = null;
        pouringToTube = null;
      });

      _pourAnimationController!.reset();

      // Verificar si el tubo destino quedó completo
      if (_isTubeComplete(to)) {
        final audioSettings = Provider.of<AudioSettings>(context, listen: false);
        AudioService.playSound('Sonidos/tube_complete.ogg', audioSettings.sfxVolume);
      }

      // Verificar victoria
      if (_checkWin()) {
        setState(() {
          gameWon = true;
        });
        _showWinDialog();
      }
    });
  }

  bool _isTubeComplete(int tubeIndex) {
    final tube = tubes[tubeIndex];
    if (tube.isEmpty) return false;
    if (tube.length != ConstantesWaterSort.tubeCapacity) return false;
    if (tube.toSet().length != 1) return false;
    return true;
  }

  int _calculateStars(int moves, int optimalMoves) {
    if (moves <= optimalMoves) return 3;
    if (moves <= (optimalMoves * 1.5).ceil()) return 2;
    return 1;
  }

  int _getOptimalMoves() {
    // Estimación: número de colores únicos * 2.5
    final uniqueColors = tubes
        .expand((tube) => tube)
        .where((color) => color != Colors.transparent)
        .toSet()
        .length;
    return (uniqueColors * 2.5).ceil();
  }

  Future<void> _saveStars(int stars) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'watersort_stars_${widget.difficulty}_$level';
    final currentStars = prefs.getInt(key) ?? 0;
    if (stars > currentStars) {
      await prefs.setInt(key, stars);
    }
  }

  bool _checkWin() {
    for (var tube in tubes) {
      if (tube.isEmpty) continue;
      if (tube.length != ConstantesWaterSort.tubeCapacity) return false;
      if (tube.toSet().length != 1) return false;
    }
    return true;
  }

  void _showWinDialog() {
    // Calcular estrellas basadas en eficiencia
    final optimalMoves = _getOptimalMoves();
    final stars = _calculateStars(moves, optimalMoves);
    _saveStars(stars);

    // Log fin de partida (victoria)
    appLogger.gameEvent('WaterSort', 'game_end', data: {'won': true, 'level': level, 'moves': moves, 'stars': stars});

    // Notificar misiones
    final missionProvider = Provider.of<MissionProvider>(context, listen: false);
    missionProvider.notifyActivity(gameType: 'watersort', activityType: MissionType.completeLevels);
    missionProvider.notifyActivity(gameType: 'watersort', activityType: MissionType.playGames);

    final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    _isDialogOpen = true;

    // Construir mensaje con estrellas
    final starsDisplay = '⭐' * stars + '☆' * (3 - stars);
    final message = '$starsDisplay\n'
        '${AppStrings.get('level_completed', currentLang)}\n'
        '${AppStrings.get('moves', currentLang)}: $moves (${AppStrings.get('optimal', currentLang)}: $optimalMoves)'
        '${widget.isTimeAttackMode ? '\n${AppStrings.get('time_remaining', currentLang)}: ${_formatTime(timeLeft)}' : ''}';

    GameOverDialog.show(
      context: context,
      isVictory: true,
      message: message,
      audioSettings: audioSettings,
      onRestart: () {
        Navigator.pop(context);
        _isDialogOpen = false;
        setState(() { _initGame(); });
      },
      onExit: () {
        _isDialogOpen = false;
        AudioService.stopLoop();
        Navigator.pop(context);
        Navigator.pop(context);
      },
      onNextLevel: () {
        Navigator.pop(context);
        _isDialogOpen = false;
        setState(() {
          level++;
          _saveLevel();
          _initGame();
        });
      },
    );
  }

  void _showGameOverDialog() {
    // Log fin de partida (derrota)
    appLogger.gameEvent('WaterSort', 'game_end', data: {'won': false, 'level': level, 'moves': moves});

    final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;
    _isDialogOpen = true;

    final audioSettings = Provider.of<AudioSettings>(context, listen: false);

    GameOverDialog.show(
      context: context,
      isVictory: false,
      customTitle: '⏱️ ${AppStrings.get('time_up', currentLang)}',
      message: '${AppStrings.get('level_failed', currentLang)}\n${AppStrings.get('moves_made', currentLang)}: $moves',
      audioSettings: audioSettings,
      onRestart: () {
        Navigator.pop(context);
        _isDialogOpen = false;
        setState(() { _initGame(); });
      },
      onExit: () {
        _isDialogOpen = false;
        AudioService.stopLoop();
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _restart() {
    // Cerrar cualquier diálogo abierto antes de reiniciar
    if (_isDialogOpen) {
      Navigator.of(context).pop();
      _isDialogOpen = false;
    }
    setState(() {
      _initGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? ColoresApp.negro : ColoresApp.blanco,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header con info del juego
                _buildHeader(isDark),

                // Área de juego
                Expanded(
                  child: _buildGameArea(isDark),
                ),

                // Controles
                _buildControls(isDark),
              ],
            ),


            // Overlay de pausa
            if (isPaused)
              PauseOverlay(
                onResume: _togglePause,
                onRestart: _restart,
                onExit: () {
                  AudioService.stopLoop();
                  Navigator.pop(context);
                },
              ),
          ],
        ),
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
          text: '${AppStrings.get('level_label', currentLang)} $level',
          fontSize: fontSize,
          hPad: hPad,
          gap: gap,
        ),
        GameStatBadge(
          text: '$moves',
          icon: Icons.touch_app,
          color: isDark ? ColoresApp.blanco : ColoresApp.negro,
          fontSize: fontSize,
          hPad: hPad,
          gap: gap,
        ),
        if (widget.isTimeAttackMode)
          GameStatBadge(
            text: _formatTime(timeLeft),
            icon: Icons.timer,
            color: ColoresApp.verdeExito,
            isWarning: timeLeft <= 30,
            fontSize: fontSize,
            hPad: hPad,
            gap: gap,
          ),
      ],
      isPaused: isPaused,
      onPause: _togglePause,
      onRestart: _restart,
      onClose: () {
        AudioService.stopLoop();
        Navigator.pop(context);
      },
      guideButton: BotonGuia(
        gameTitle: 'WaterSort',
        gameImagePath: 'assets/imagenes/watersort.png',
        objetivo: AppStrings.get('watersort_objective', currentLang),
        instrucciones: [
          AppStrings.get('watersort_inst_1', currentLang),
          AppStrings.get('watersort_inst_2', currentLang),
          AppStrings.get('watersort_inst_3', currentLang),
          AppStrings.get('watersort_inst_4', currentLang),
          AppStrings.get('watersort_inst_5', currentLang),
          AppStrings.get('watersort_inst_6', currentLang),
          AppStrings.get('watersort_inst_7', currentLang),
        ],
        controles: GuiasJuegos.getWaterSortControles(currentLang),
        size: btnSize,
        onOpen: () { if (!isPaused) _togglePause(); },
        onClose: () { if (isPaused) _togglePause(); },
      ),
    );
  }

  Widget _buildGameArea(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcular dimensiones de tubos
        int tubeCount = tubes.length;
        int tubesPerRow = tubeCount <= 6 ? tubeCount : (tubeCount / 2).ceil();
        int rows = (tubeCount / tubesPerRow).ceil();

        double maxTubeWidth = constraints.maxWidth / (tubesPerRow + 1);
        double tubeWidth = maxTubeWidth.clamp(50.0, 70.0);
        double tubeHeight = tubeWidth * 2.5;
        double spacing = (constraints.maxWidth - (tubeWidth * tubesPerRow)) / (tubesPerRow + 1);

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(rows, (rowIndex) {
              int startIndex = rowIndex * tubesPerRow;
              int endIndex = (startIndex + tubesPerRow).clamp(0, tubeCount);

              return Padding(
                padding: EdgeInsets.symmetric(vertical: spacing / 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(endIndex - startIndex, (i) {
                    int tubeIndex = startIndex + i;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                      child: _buildTube(
                        tubeIndex,
                        tubeWidth,
                        tubeHeight,
                        isDark,
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildTubeSegment(Color? segmentColor, double segmentHeight, double width, bool isTop, bool isBottom) {
    return Container(
      width: width - 12,
      height: segmentHeight,
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        color: segmentColor ?? Colors.transparent,
        borderRadius: BorderRadius.vertical(
          top: isTop ? const Radius.circular(4) : Radius.zero,
          bottom: isBottom ? const Radius.circular(20) : Radius.zero,
        ),
        gradient: segmentColor != null
            ? LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  segmentColor,
                  segmentColor.withOpacity(0.8),
                  segmentColor,
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildTube(int index, double width, double height, bool isDark) {
    bool isSelected = selectedTube == index;
    bool isSuggestedFrom = suggestedFromTube == index;
    bool isSuggestedTo = suggestedToTube == index;
    bool isSuggested = isSuggestedFrom || isSuggestedTo;
    bool isComplete = _isTubeComplete(index);
    List<Color> tube = tubes[index];
    double segmentHeight = (height - 20) / ConstantesWaterSort.tubeCapacity;

    bool isPouring = pouringFromTube == index || pouringToTube == index;

    return GestureDetector(
      onTap: () => _onTubeTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..translate(0.0, isSelected ? -15.0 : 0.0)
          ..scale(isPouring ? 1.05 : 1.0),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: isDark
                ? ColoresApp.gris800.withOpacity(0.5)
                : ColoresApp.gris100,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
            border: Border.all(
              color: isComplete
                  ? Colors.greenAccent
                  : (isSuggested
                      ? Colors.amber
                      : (isSelected
                          ? ColoresApp.moradoPrincipal
                          : (isDark ? ColoresApp.gris600 : ColoresApp.gris300))),
              width: isComplete ? 4 : (isSuggested ? 4 : (isSelected ? 3 : 2)),
            ),
            boxShadow: isComplete
                ? [
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(0.8),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ]
                : (isSuggested
                    ? [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.6),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ]
                    : (isSelected
                        ? [
                            BoxShadow(
                              color: ColoresApp.moradoPrincipal.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ]
                        : null)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: List.generate(ConstantesWaterSort.tubeCapacity, (i) {
                int colorIndex = ConstantesWaterSort.tubeCapacity - 1 - i;
                Color? segmentColor = colorIndex < tube.length ? tube[colorIndex] : null;
                bool isBottom = i == ConstantesWaterSort.tubeCapacity - 1;
                bool isTop = colorIndex == tube.length - 1 && tube.isNotEmpty;
                return _buildTubeSegment(segmentColor, segmentHeight, width, isTop, isBottom);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls(bool isDark) {
    final currentLang = Provider.of<LanguageProvider>(context).currentLanguage;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Botón Deshacer
          _buildControlButton(
            icon: Icons.undo,
            label: AppStrings.get('undo', currentLang),
            onTap: history.isNotEmpty ? _undo : null,
            isDark: isDark,
          ),

          // Botón Pista
          GestureDetector(
            onTap: gameWon || gameOver || isPaused ? null : _showHint,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: usedHints >= hintsAvailable
                    ? (isDark ? ColoresApp.gris800 : ColoresApp.gris300)
                    : Colors.amber,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${AppStrings.get('hint', currentLang)} (${hintsAvailable - usedHints})',
                    style: TextStyle(
                      color: usedHints >= hintsAvailable ? ColoresApp.gris400 : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botón Reiniciar
          _buildControlButton(
            icon: Icons.refresh,
            label: AppStrings.get('restart', currentLang),
            onTap: _restart,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required bool isDark,
  }) {
    bool isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isEnabled
              ? ColoresApp.moradoPrincipal
              : (isDark ? ColoresApp.gris800 : ColoresApp.gris300),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isEnabled ? ColoresApp.blanco : ColoresApp.gris400,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isEnabled ? ColoresApp.blanco : ColoresApp.gris400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
