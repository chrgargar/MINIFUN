import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_logger.dart';
import '../widgets/pause_overlay.dart';
import '../widgets/boton_guia.dart';
import '../constants/guias_juegos.dart';
import '../config/audio_settings.dart';
import '../config/language_provider.dart';
import '../constants/app_strings.dart';
import '../services/audio_service.dart';
import '../constants/ahorcado_constants.dart';
import '../providers/mission_provider.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/hint_button.dart';
import '../widgets/game_header.dart';

class AhorcadoGame extends StatefulWidget {
  final String difficulty; // 'facil', 'medio', 'dificil'
  final String theme; // 'general', 'animales', 'paises', 'comida'
  final bool isSpeedMode; // Modo velocidad (tiempo limitado por letra)
  final bool isSurvivalMode; // Modo supervivencia (palabras seguidas hasta fallar)

  const AhorcadoGame({
    super.key,
    this.difficulty = 'facil',
    this.theme = 'general',
    this.isSpeedMode = false,
    this.isSurvivalMode = false,
  });

  @override
  State<AhorcadoGame> createState() => _AhorcadoGameState();
}

class _AhorcadoGameState extends State<AhorcadoGame> with TickerProviderStateMixin {
  // Palabra actual
  late String currentWord;
  late Set<String> guessedLetters;
  late int errorsCount;

  // Estado del juego
  bool isPaused = false;
  bool isGameOver = false;
  bool isVictory = false;

  // Timer para modo velocidad
  Timer? letterTimer;
  late int letterTimeLeft;

  // Puntuación
  int score = 0;
  int wordsCompleted = 0;

  // Supervivencia
  late int lives;

  // Lista de palabras usadas para no repetir
  List<String> usedWords = [];

  // Sistema de pistas
  late List<String> currentHints;
  late int hintsAvailable;
  int usedHints = 0;
  String? revealedHint;

  // Alfabeto español
  static const List<String> alphabet = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'Ñ', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
  ];

  // Controller para animación de dibujo del ahorcado
  late AnimationController _drawController;

  @override
  void initState() {
    super.initState();

    // Rastrear pantalla actual
    appLogger.setCurrentScreen('AhorcadoGame');

    // Log inicio de partida
    String mode = 'normal';
    if (widget.isSpeedMode) mode = 'speed';
    if (widget.isSurvivalMode) mode = 'survival';
    appLogger.gameEvent('Ahorcado', 'game_start', data: {'difficulty': widget.difficulty, 'theme': widget.theme, 'mode': mode});

    _initializeGame();

    // Inicializar controller de animación de dibujo
    _drawController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Precargar efectos de sonido
    AudioService.preloadSounds([
      'Sonidos/letter_correct.ogg',
      'Sonidos/letter_wrong.ogg',
      'Sonidos/hint.wav',
    ]);

    _startBackgroundMusic();
  }

  void _startBackgroundMusic() {
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    AudioService.playLoop('Sonidos/music_ahorcado.mp3', audioSettings.musicVolume);
  }

  void _initializeGame() {
    guessedLetters = {};
    errorsCount = 0;
    usedWords = [];
    usedHints = 0;
    revealedHint = null;
    hintsAvailable = ConstantesAhorcado.pistasPorDificultad[widget.difficulty] ?? 2;
    lives = widget.isSurvivalMode ? ConstantesAhorcado.vidasSupervivencia : ConstantesAhorcado.maxIntentos;
    letterTimeLeft = widget.isSpeedMode
        ? ConstantesAhorcado.tiempoPorLetraVelocidad
        : ConstantesAhorcado.tiempoPorLetraNormal;
    _selectNewWord();
    if (widget.isSpeedMode) {
      _startLetterTimer();
    }
  }

  void _selectNewWord() {
    List<String> words = List.from(
      ConstantesAhorcado.palabrasPorTematica[widget.theme]?[widget.difficulty] ??
      ConstantesAhorcado.palabrasPorTematica['general']!['facil']!
    );

    // Filtrar palabras ya usadas
    words = words.where((w) => !usedWords.contains(w)).toList();

    // Si ya usamos todas, reiniciar la lista
    if (words.isEmpty) {
      usedWords.clear();
      words = List.from(
        ConstantesAhorcado.palabrasPorTematica[widget.theme]?[widget.difficulty] ??
        ConstantesAhorcado.palabrasPorTematica['general']!['facil']!
      );
    }

    words.shuffle(Random());
    currentWord = words.first;
    usedWords.add(currentWord);
    guessedLetters = {};
    errorsCount = 0;

    // Cargar pistas para la palabra actual
    currentHints = ConstantesAhorcado.pistas[currentWord] ?? ['Sin pista disponible', 'Sin pista disponible', 'Sin pista disponible'];
    usedHints = 0;
    revealedHint = null;
    hintsAvailable = ConstantesAhorcado.pistasPorDificultad[widget.difficulty] ?? 2;

    // Reiniciar timer de letra si está en modo velocidad
    if (widget.isSpeedMode) {
      letterTimeLeft = ConstantesAhorcado.tiempoPorLetraVelocidad;
    }
  }

  void _startLetterTimer() {
    letterTimer?.cancel();
    letterTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused && !isGameOver) {
        setState(() {
          letterTimeLeft--;
          if (letterTimeLeft <= 0) {
            // Se acabó el tiempo para esta letra - cuenta como error
            _handleTimeOut();
          }
        });
      }
    });
  }

  void _handleTimeOut() {
        errorsCount++;

    if (widget.isSurvivalMode) {
      lives--;
      if (lives <= 0) {
        _gameOver(false);
        return;
      }
    }

    if (errorsCount >= ConstantesAhorcado.maxIntentos) {
      if (widget.isSurvivalMode) {
        // En supervivencia, perder una palabra no es game over si quedan vidas
        lives--;
        if (lives <= 0) {
          _gameOver(false);
        } else {
          _selectNewWord();
        }
      } else {
        _gameOver(false);
      }
    } else {
      // Reiniciar tiempo para siguiente letra
      letterTimeLeft = widget.isSpeedMode
          ? ConstantesAhorcado.tiempoPorLetraVelocidad
          : ConstantesAhorcado.tiempoPorLetraNormal;
    }
  }

  void _onLetterTap(String letter) {
    if (isPaused || isGameOver || guessedLetters.contains(letter)) return;

    setState(() {
      guessedLetters.add(letter);

      if (currentWord.contains(letter)) {
        // Letra correcta
        // Reproducir sonido de letra correcta
        final audioSettings = Provider.of<AudioSettings>(context, listen: false);
        AudioService.playSound('Sonidos/letter_correct.ogg', audioSettings.sfxVolume);

        // Contar cuántas veces aparece la letra
        int occurrences = currentWord.split('').where((l) => l == letter).length;
        score += ConstantesAhorcado.puntosPorLetraCorrecta * occurrences;

        // Bonus por tiempo restante en modo velocidad
        if (widget.isSpeedMode && letterTimeLeft > 2) {
          score += ConstantesAhorcado.bonusLetraRapida;
        }

        // Verificar si ganó la palabra
        if (_isWordComplete()) {
          int pointsForWord = widget.isSurvivalMode
              ? ConstantesAhorcado.puntosPorPalabraSupervivencia
              : ConstantesAhorcado.puntosPorPalabraCompleta;
          score += pointsForWord;
          wordsCompleted++;

          if (widget.isSurvivalMode || widget.isSpeedMode) {
            // Continuar con otra palabra
            _selectNewWord();
            if (widget.isSpeedMode) {
              letterTimeLeft = ConstantesAhorcado.tiempoPorLetraVelocidad;
            }
          } else {
            // En modo normal, victoria
            _victory();
          }
        } else {
          // Reiniciar timer si acertó
          if (widget.isSpeedMode) {
            letterTimeLeft = ConstantesAhorcado.tiempoPorLetraVelocidad;
          }
        }
      } else {
        // Letra incorrecta
        // Reproducir sonido de letra incorrecta
        final audioSettings = Provider.of<AudioSettings>(context, listen: false);
        AudioService.playSound('Sonidos/letter_wrong.ogg', audioSettings.sfxVolume);

        errorsCount++;
        score = max(0, score - ConstantesAhorcado.penalizacionPorError);

        // Animar el dibujo del ahorcado
        _drawController.forward(from: 0.0);

        // Verificar si perdió
        if (errorsCount >= ConstantesAhorcado.maxIntentos) {
          if (widget.isSurvivalMode) {
            lives--;
            if (lives <= 0) {
              _gameOver(false);
            } else {
              // Continuar con nueva palabra
              _selectNewWord();
            }
          } else {
            _gameOver(false);
          }
        } else {
          // Reiniciar timer para siguiente intento
          if (widget.isSpeedMode) {
            letterTimeLeft = ConstantesAhorcado.tiempoPorLetraVelocidad;
          }
        }
      }
    });
  }

  bool _isWordComplete() {
    for (var letter in currentWord.split('')) {
      if (!guessedLetters.contains(letter)) {
        return false;
      }
    }
    return true;
  }

  void _victory() {
    // Notificar misiones
    final missionProvider = Provider.of<MissionProvider>(context, listen: false);
    missionProvider.notifyActivity(gameType: 'ahorcado', activityType: MissionType.playGames);
    missionProvider.notifyActivity(gameType: 'ahorcado', activityType: MissionType.completeLevels);

    isVictory = true;
    isGameOver = true;
    letterTimer?.cancel();
    AudioService.stopLoop();
  }

  void _gameOver(bool victory) {
    // Log fin de partida
    appLogger.gameEvent('Ahorcado', 'game_end', data: {'won': victory, 'errors': errorsCount, 'word': currentWord});

    // Notificar misiones
    final missionProvider = Provider.of<MissionProvider>(context, listen: false);
    missionProvider.notifyActivity(gameType: 'ahorcado', activityType: MissionType.playGames);
    if (victory) {
      missionProvider.notifyActivity(gameType: 'ahorcado', activityType: MissionType.completeLevels);
    }

    isVictory = victory;
    isGameOver = true;
    letterTimer?.cancel();
    AudioService.stopLoop();
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  void _showHint() {
    if (usedHints >= hintsAvailable || usedHints >= currentHints.length) {
      // No quedan pistas
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

    setState(() {
      revealedHint = currentHints[usedHints];
      usedHints++;
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
          revealedHint!,
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
  }

  void _restartGame() {
    setState(() {
      score = 0;
      wordsCompleted = 0;
      isGameOver = false;
      isVictory = false;
      isPaused = false;
      letterTimer?.cancel();
      _initializeGame();
      _startBackgroundMusic();
    });
  }

  @override
  void dispose() {
    letterTimer?.cancel();
    _drawController.dispose();
    AudioService.stopLoop();
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
                _buildHeader(isDark),

                // Información del juego
                _buildInfoBar(isDark),

                // Dibujo del ahorcado
                Expanded(
                  flex: 3,
                  child: _buildHangmanDrawing(isDark),
                ),

                // Palabra a adivinar
                Expanded(
                  flex: 1,
                  child: _buildWordDisplay(isDark),
                ),

                // Teclado de letras
                Expanded(
                  flex: 2,
                  child: _buildKeyboard(isDark),
                ),
              ],
            ),

            // Overlay de pausa
            if (isPaused) PauseOverlay(
              onResume: _togglePause,
              onRestart: _restartGame,
              onExit: () {
                letterTimer?.cancel();
                AudioService.stopLoop();
                Navigator.pop(context);
              },
            ),

            // Game Over overlay
            if (isGameOver) _buildGameOverOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final currentLang = Provider.of<LanguageProvider>(context).currentLanguage;
    final sw = MediaQuery.of(context).size.width;
    final btnSize = (sw * 0.09).clamp(28.0, 40.0);

    return GameHeader(
      stats: [],
      isPaused: isPaused,
      onPause: _togglePause,
      onRestart: _restartGame,
      onClose: () {
        letterTimer?.cancel();
        AudioService.stopLoop();
        Navigator.pop(context);
      },
      hintButton: HintButton(
        hintsRemaining: hintsAvailable - usedHints,
        onTap: isGameOver ? null : _showHint,
        size: btnSize,
      ),
      guideButton: BotonGuia(
        gameTitle: 'Ahorcado',
        gameImagePath: 'assets/imagenes/ahorcado.png',
        objetivo: AppStrings.get('hangman_objective', currentLang),
        instrucciones: [
          AppStrings.get('hangman_inst_1', currentLang),
          AppStrings.get('hangman_inst_2', currentLang),
          AppStrings.get('hangman_inst_3', currentLang),
          AppStrings.get('hangman_inst_4', currentLang),
          AppStrings.get('hangman_inst_5', currentLang),
        ],
        controles: GuiasJuegos.getHangmanControles(currentLang),
        size: btnSize,
        onOpen: () { if (!isPaused) _togglePause(); },
        onClose: () { if (isPaused) _togglePause(); },
      ),
    );
  }

  Widget _buildInfoBar(bool isDark) {
    final currentLang = Provider.of<LanguageProvider>(context).currentLanguage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Puntuación
          Text(
            '${AppStrings.get('score', currentLang)}: $score',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),

          // Indicador de pistas
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                '${hintsAvailable - usedHints}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),

          // Palabras completadas (en modos especiales)
          if (widget.isSurvivalMode || widget.isSpeedMode)
            Text(
              '${AppStrings.get('words_completed', currentLang)}: $wordsCompleted',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),

          // Timer por letra (modo velocidad)
          if (widget.isSpeedMode)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: letterTimeLeft <= 2 ? Colors.red : Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${letterTimeLeft}s',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

          // Vidas (modo supervivencia)
          if (widget.isSurvivalMode)
            Row(
              children: List.generate(
                ConstantesAhorcado.vidasSupervivencia,
                (index) => Icon(
                  index < lives ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                  size: 24,
                ),
              ),
            ),

          // Errores (modo normal)
          if (!widget.isSurvivalMode && !widget.isSpeedMode)
            Row(
              children: List.generate(
                ConstantesAhorcado.maxIntentos,
                (index) => Icon(
                  index < errorsCount ? Icons.close : Icons.circle_outlined,
                  color: index < errorsCount ? Colors.red : Colors.grey,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHangmanDrawing(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: AnimatedBuilder(
        animation: _drawController,
        builder: (context, child) {
          return CustomPaint(
            painter: HangmanPainter(
              errorsCount: errorsCount,
              color: isDark ? Colors.white : Colors.black,
              progress: _drawController.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildWordDisplay(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: currentWord.split('').map((letter) {
            bool isGuessed = guessedLetters.contains(letter);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white : Colors.black,
                    width: 2,
                  ),
                ),
              ),
              child: TweenAnimationBuilder<double>(
                key: ValueKey('${letter}_${isGuessed}'),
                tween: Tween<double>(begin: 0.0, end: isGuessed ? 1.0 : 0.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: isGuessed ? value : 1.0,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  isGuessed ? letter : ' ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildKeyboard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
          childAspectRatio: 1.0,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: alphabet.length,
        itemBuilder: (context, index) {
          String letter = alphabet[index];
          bool isGuessed = guessedLetters.contains(letter);
          bool isCorrect = isGuessed && currentWord.contains(letter);
          bool isWrong = isGuessed && !currentWord.contains(letter);

          return GestureDetector(
            onTap: () => _onLetterTap(letter),
            child: Container(
              decoration: BoxDecoration(
                color: isCorrect
                    ? Colors.green
                    : isWrong
                        ? Colors.red
                        : (isDark ? Colors.grey[800] : Colors.grey[300]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isGuessed
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;
    final modeStats = (widget.isSurvivalMode || widget.isSpeedMode)
        ? '\n${AppStrings.get('words_completed', currentLang)}: $wordsCompleted'
        : '';
    final message = isVictory
        ? '${AppStrings.get('score', currentLang)}: $score$modeStats'
        : '${AppStrings.get('the_word_was', currentLang)}: $currentWord\n${AppStrings.get('score', currentLang)}: $score$modeStats';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audioSettings = Provider.of<AudioSettings>(context, listen: false);

      GameOverDialog.show(
        context: context,
        isVictory: isVictory,
        message: message,
        audioSettings: audioSettings,
        onRestart: () {
          Navigator.pop(context);
          _restartGame();
        },
        onExit: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      );
    });

    return Container(
      color: Colors.black54,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

// CustomPainter para dibujar el ahorcado
class HangmanPainter extends CustomPainter {
  final int errorsCount;
  final Color color;
  final double progress; // 0.0 a 1.0 para animación

  HangmanPainter({
    required this.errorsCount,
    required this.color,
    this.progress = 1.0, // Default sin animación
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final baseY = size.height * 0.9;
    final topY = size.height * 0.1;

    // Base (siempre visible)
    canvas.drawLine(
      Offset(centerX - 60, baseY),
      Offset(centerX + 60, baseY),
      paint,
    );

    // Poste vertical (siempre visible)
    canvas.drawLine(
      Offset(centerX - 40, baseY),
      Offset(centerX - 40, topY),
      paint,
    );

    // Poste horizontal (siempre visible)
    canvas.drawLine(
      Offset(centerX - 40, topY),
      Offset(centerX + 20, topY),
      paint,
    );

    // Cuerda (siempre visible)
    canvas.drawLine(
      Offset(centerX + 20, topY),
      Offset(centerX + 20, topY + 30),
      paint,
    );

    // Partes del cuerpo según errores
    final bodyX = centerX + 20;
    final headY = topY + 30;
    final headRadius = 20.0;

    // 1. Cabeza
    if (errorsCount >= 1) {
      final partPaint = paint..color = color.withOpacity(errorsCount == 1 ? progress : 1.0);
      canvas.drawCircle(
        Offset(bodyX, headY + headRadius),
        headRadius,
        partPaint,
      );
    }

    // 2. Cuerpo
    if (errorsCount >= 2) {
      final partPaint = paint..color = color.withOpacity(errorsCount == 2 ? progress : 1.0);
      canvas.drawLine(
        Offset(bodyX, headY + headRadius * 2),
        Offset(bodyX, headY + headRadius * 2 + 60),
        partPaint,
      );
    }

    // 3. Brazo izquierdo
    if (errorsCount >= 3) {
      final partPaint = paint..color = color.withOpacity(errorsCount == 3 ? progress : 1.0);
      canvas.drawLine(
        Offset(bodyX, headY + headRadius * 2 + 15),
        Offset(bodyX - 30, headY + headRadius * 2 + 40),
        partPaint,
      );
    }

    // 4. Brazo derecho
    if (errorsCount >= 4) {
      final partPaint = paint..color = color.withOpacity(errorsCount == 4 ? progress : 1.0);
      canvas.drawLine(
        Offset(bodyX, headY + headRadius * 2 + 15),
        Offset(bodyX + 30, headY + headRadius * 2 + 40),
        partPaint,
      );
    }

    // 5. Pierna izquierda
    if (errorsCount >= 5) {
      final partPaint = paint..color = color.withOpacity(errorsCount == 5 ? progress : 1.0);
      canvas.drawLine(
        Offset(bodyX, headY + headRadius * 2 + 60),
        Offset(bodyX - 25, headY + headRadius * 2 + 100),
        partPaint,
      );
    }

    // 6. Pierna derecha
    if (errorsCount >= 6) {
      final partPaint = paint..color = color.withOpacity(errorsCount == 6 ? progress : 1.0);
      canvas.drawLine(
        Offset(bodyX, headY + headRadius * 2 + 60),
        Offset(bodyX + 25, headY + headRadius * 2 + 100),
        partPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant HangmanPainter oldDelegate) {
    return oldDelegate.errorsCount != errorsCount || oldDelegate.color != color;
  }
}
