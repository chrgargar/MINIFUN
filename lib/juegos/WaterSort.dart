import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/game_control_buttons.dart';
import '../widgets/pause_overlay.dart';
import '../widgets/boton_guia.dart';
import '../data/guias_juegos.dart';
import '../tema/audio_settings.dart';
import '../tema/app_colors.dart';
import '../tema/language_provider.dart';
import '../constants/app_strings.dart';
import '../services/audio_service.dart';
import '../constants/water_sort_constants.dart';

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
  Animation<double>? _pourAnimation; // ignore: unused_field
  int? pouringFromTube;
  int? pouringToTube;
  bool isPouring = false;

  // Historial para deshacer
  List<List<List<Color>>> history = [];

  // Estado de pausa
  bool isPaused = false;

  // Control de diálogos
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLevel();
    _startBackgroundMusic();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AudioSettings>(context, listen: false).addListener(_onAudioSettingsChanged);
    });

    _pourAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pourAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pourAnimationController!, curve: Curves.easeInOut),
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
        if (!gameOver && !gameWon) {
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

  void _pourWater(int from, int to) async {
    _saveState();

    setState(() {
      isPouring = true;
      pouringFromTube = from;
      pouringToTube = to;
    });

    await _pourAnimationController!.forward();

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
    
    // Verificar victoria
    if (_checkWin()) {
      setState(() {
        gameWon = true;
      });
            _showWinDialog();
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
    final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;
    _isDialogOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: ColoresApp.blanco,
        title: Text(
          '🎉 ${AppStrings.get('congratulations', currentLang)}',
          style: TextStyle(color: ColoresApp.negro, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '${AppStrings.get('level_completed', currentLang)}\n${AppStrings.get('moves', currentLang)}: $moves${widget.isTimeAttackMode ? '\n${AppStrings.get('time_remaining', currentLang)}: ${_formatTime(timeLeft)}' : ''}',
          style: TextStyle(color: ColoresApp.negro),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _isDialogOpen = false;
              setState(() {
                level++;
                _saveLevel();
                _initGame();
              });
            },
            child: Text(AppStrings.get('next_level', currentLang), style: TextStyle(color: ColoresApp.moradoPrincipal)),
          ),
          TextButton(
            onPressed: () {
              _isDialogOpen = false;
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(AppStrings.get('exit', currentLang), style: TextStyle(color: ColoresApp.rojoError)),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog() {
    final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;
    _isDialogOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: ColoresApp.blanco,
        title: Text(
          '⏱️ ${AppStrings.get('time_up', currentLang)}',
          style: TextStyle(color: ColoresApp.negro, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '${AppStrings.get('level_failed', currentLang)}\n${AppStrings.get('moves_made', currentLang)}: $moves',
          style: TextStyle(color: ColoresApp.negro),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _isDialogOpen = false;
              setState(() {
                _initGame();
              });
            },
            child: Text(AppStrings.get('retry', currentLang), style: TextStyle(color: ColoresApp.moradoPrincipal)),
          ),
          TextButton(
            onPressed: () {
              _isDialogOpen = false;
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(AppStrings.get('exit', currentLang), style: TextStyle(color: ColoresApp.rojoError)),
          ),
        ],
      ),
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

            // Botones de control (pausa, reiniciar, guía, cerrar)
            Positioned(
              top: 16,
              right: 16,
              child: Builder(
                builder: (context) {
                  final currentLang = Provider.of<LanguageProvider>(context).currentLanguage;
                  return Row(
                    children: [
                      GamePauseButton(
                        isPaused: isPaused,
                        onPressed: _togglePause,
                        size: 40,
                      ),
                      const SizedBox(width: 8),
                      GameRestartButton(
                        onPressed: _restart,
                        size: 40,
                      ),
                      const SizedBox(width: 8),
                      BotonGuia(
                        gameTitle: 'WaterSort',
                        gameImagePath: 'assets/imagenes/watersort.png',
                        objetivo: AppStrings.get('watersort_objective', currentLang),
                        instrucciones: [
                          AppStrings.get('watersort_inst_1', currentLang),
                          AppStrings.get('watersort_inst_2', currentLang),
                          AppStrings.get('watersort_inst_3', currentLang),
                          AppStrings.get('watersort_inst_4', currentLang),
                        ],
                        controles: GuiasJuegos.getWaterSortControles(currentLang),
                        size: 40,
                        onOpen: () => setState(() => isPaused = true),
                        onClose: () => setState(() => isPaused = false),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: ColoresApp.rojoError,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: ColoresApp.blanco,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Overlay de Game Over
            if (gameOver && !gameWon)
              _buildGameOverOverlay(isDark),

            // Overlay de pausa
            if (isPaused)
              PauseOverlay(
                onResume: _togglePause,
                onRestart: _restart,
                onExit: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nivel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: ColoresApp.moradoPrincipal.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Nivel $level',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ColoresApp.moradoPrincipal,
              ),
            ),
          ),

          // Movimientos
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? ColoresApp.gris800 : ColoresApp.gris100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.touch_app, size: 18, color: isDark ? ColoresApp.blanco : ColoresApp.negro),
                const SizedBox(width: 8),
                Text(
                  '$moves',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? ColoresApp.blanco : ColoresApp.negro,
                  ),
                ),
              ],
            ),
          ),

          // Tiempo (si aplica)
          if (widget.isTimeAttackMode)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: timeLeft <= 30
                    ? ColoresApp.rojoError.withOpacity(0.2)
                    : ColoresApp.verdeExito.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 18,
                    color: timeLeft <= 30 ? ColoresApp.rojoError : ColoresApp.verdeExito,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(timeLeft),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: timeLeft <= 30 ? ColoresApp.rojoError : ColoresApp.verdeExito,
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(width: 50),
        ],
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

  Widget _buildTube(int index, double width, double height, bool isDark) {
    bool isSelected = selectedTube == index;
    List<Color> tube = tubes[index];
    double segmentHeight = (height - 20) / ConstantesWaterSort.tubeCapacity;

    return GestureDetector(
      onTap: () => _onTubeTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, isSelected ? -15 : 0, 0),
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
              color: isSelected
                  ? ColoresApp.moradoPrincipal
                  : (isDark ? ColoresApp.gris600 : ColoresApp.gris300),
              width: isSelected ? 3 : 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: ColoresApp.moradoPrincipal.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
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

  Widget _buildGameOverOverlay(bool isDark) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (gameOver && !gameWon) {
        _showGameOverDialog();
      }
    });

    return Container(
      color: Colors.black54,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
