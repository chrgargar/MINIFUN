import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  Animation<double>? _pourAnimation;
  int? pouringFromTube;
  int? pouringToTube;
  bool isPouring = false;

  // Historial para deshacer
  List<List<List<Color>>> history = [];

  @override
  void initState() {
    super.initState();
    _initGame();

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

  @override
  void dispose() {
    _pourAnimationController?.dispose();
    try {
      Provider.of<AudioSettings>(context, listen: false).removeListener(_onAudioSettingsChanged);
    } catch (e) {}
    super.dispose();
  }

  void _onAudioSettingsChanged() {}

  Future<void> _playSound(String sound) async {
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    await AudioService.playSound('Sonidos/$sound', audioSettings.sfxVolume);
  }

  void _initGame() {
    final config = ConstantesWaterSort.getDifficultyConfig(widget.difficulty);

    tubes = _generatePuzzle(
      config['colors'] as int,
      config['tubesExtra'] as int,
    );

    selectedTube = null;
    moves = 0;
    gameWon = false;
    gameOver = false;
    history.clear();

    if (widget.isTimeAttackMode) {
      timeLeft = config['timeLimit'] as int;
      _startTimer();
    }

    if (widget.isMinMovesMode) {
      // En modo mínimos movimientos se guarda el objetivo
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && widget.isTimeAttackMode && !gameWon && !gameOver) {
        setState(() {
          timeLeft--;
          if (timeLeft <= 0) {
            gameOver = true;
            _playSound('gameover.mp3');
          }
        });
        if (!gameOver && !gameWon) {
          _startTimer();
        }
      }
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
      _playSound('click.mp3');
    }
  }

  void _onTubeTap(int index) {
    if (gameWon || gameOver || isPouring) return;

    setState(() {
      if (selectedTube == null) {
        // Seleccionar tubo si tiene contenido
        if (tubes[index].isNotEmpty) {
          selectedTube = index;
          _playSound('click.mp3');
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
            _playSound('click.mp3');
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
    _playSound('pour.mp3');

    // Verificar victoria
    if (_checkWin()) {
      setState(() {
        gameWon = true;
      });
      _playSound('win.mp3');
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2D1B3D)
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '🎉 ${AppStrings.get('congratulations', currentLang)}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.get('level_completed', currentLang),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              '${AppStrings.get('moves', currentLang)}: $moves',
              style: TextStyle(fontSize: 16, color: ColoresApp.moradoPrincipal),
            ),
            if (widget.isTimeAttackMode)
              Text(
                '${AppStrings.get('time_remaining', currentLang)}: ${_formatTime(timeLeft)}',
                style: TextStyle(fontSize: 16, color: ColoresApp.verdeExito),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                level++;
                _initGame();
              });
            },
            child: Text(AppStrings.get('next_level', currentLang)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(AppStrings.get('exit', currentLang)),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog() {
    final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2D1B3D)
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '⏱️ ${AppStrings.get('time_up', currentLang)}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.get('level_failed', currentLang),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              '${AppStrings.get('moves_made', currentLang)}: $moves',
              style: TextStyle(fontSize: 16, color: ColoresApp.moradoPrincipal),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _initGame();
              });
            },
            child: Text(AppStrings.get('retry', currentLang)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(AppStrings.get('exit', currentLang)),
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

            // Botón cerrar
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: ColoresApp.rojoError.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close),
                  color: ColoresApp.blanco,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // Overlay de Game Over
            if (gameOver && !gameWon)
              _buildGameOverOverlay(isDark),
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
