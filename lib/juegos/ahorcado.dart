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
import '../constants/ahorcado_constants.dart';

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

class _AhorcadoGameState extends State<AhorcadoGame> {
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

  // Alfabeto español
  static const List<String> alphabet = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'Ñ', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
  ];

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _startBackgroundMusic();
  }

  void _startBackgroundMusic() {
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    AudioService.playLoop('Sonidos/music.mp3', audioSettings.musicVolume);
  }

  void _initializeGame() {
    guessedLetters = {};
    errorsCount = 0;
    usedWords = [];
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
                errorsCount++;
        score = max(0, score - ConstantesAhorcado.penalizacionPorError);

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
    isVictory = true;
    isGameOver = true;
    letterTimer?.cancel();
    AudioService.stopLoop();
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    AudioService.playSound('Sonidos/food.mp3', audioSettings.musicVolume); // Victory sound
  }

  void _gameOver(bool victory) {
    isVictory = victory;
    isGameOver = true;
    letterTimer?.cancel();
    AudioService.stopLoop();
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    AudioService.playSound('Sonidos/gameover.mp3', audioSettings.musicVolume);
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
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
              onExit: () => Navigator.pop(context),
            ),

            // Game Over overlay
            if (isGameOver) _buildGameOverOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    String title = 'Ahorcado';
    if (widget.isSpeedMode) title = 'Ahorcado - Velocidad';
    if (widget.isSurvivalMode) title = 'Ahorcado - Supervivencia';

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
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
                    onRestartPressed: _restartGame,
                  ),
                  const SizedBox(width: 8),
                  BotonGuia(
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
    );
  }

  Widget _buildInfoBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Puntuación
          Text(
            'Puntos: $score',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),

          // Palabras completadas (en modos especiales)
          if (widget.isSurvivalMode || widget.isSpeedMode)
            Text(
              'Palabras: $wordsCompleted',
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
      child: CustomPaint(
        painter: HangmanPainter(
          errorsCount: errorsCount,
          color: isDark ? Colors.white : Colors.black,
        ),
        size: Size.infinite,
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
              child: Text(
                isGuessed ? letter : ' ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
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
                ? "${AppStrings.get('score', currentLang)}: $score${(widget.isSurvivalMode || widget.isSpeedMode) ? '\n${AppStrings.get('words_completed', currentLang)}: $wordsCompleted' : ''}"
                : "${AppStrings.get('the_word_was', currentLang)}: $currentWord\n${AppStrings.get('score', currentLang)}: $score${(widget.isSurvivalMode || widget.isSpeedMode) ? '\n${AppStrings.get('words_completed', currentLang)}: $wordsCompleted' : ''}",
            style: TextStyle(color: ColoresApp.negro),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _restartGame();
              },
              child: Text(AppStrings.get('play_again', currentLang), style: TextStyle(color: ColoresApp.moradoPrincipal)),
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
}

// CustomPainter para dibujar el ahorcado
class HangmanPainter extends CustomPainter {
  final int errorsCount;
  final Color color;

  HangmanPainter({required this.errorsCount, required this.color});

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
      canvas.drawCircle(
        Offset(bodyX, headY + headRadius),
        headRadius,
        paint,
      );
    }

    // 2. Cuerpo
    if (errorsCount >= 2) {
      canvas.drawLine(
        Offset(bodyX, headY + headRadius * 2),
        Offset(bodyX, headY + headRadius * 2 + 60),
        paint,
      );
    }

    // 3. Brazo izquierdo
    if (errorsCount >= 3) {
      canvas.drawLine(
        Offset(bodyX, headY + headRadius * 2 + 15),
        Offset(bodyX - 30, headY + headRadius * 2 + 40),
        paint,
      );
    }

    // 4. Brazo derecho
    if (errorsCount >= 4) {
      canvas.drawLine(
        Offset(bodyX, headY + headRadius * 2 + 15),
        Offset(bodyX + 30, headY + headRadius * 2 + 40),
        paint,
      );
    }

    // 5. Pierna izquierda
    if (errorsCount >= 5) {
      canvas.drawLine(
        Offset(bodyX, headY + headRadius * 2 + 60),
        Offset(bodyX - 25, headY + headRadius * 2 + 100),
        paint,
      );
    }

    // 6. Pierna derecha
    if (errorsCount >= 6) {
      canvas.drawLine(
        Offset(bodyX, headY + headRadius * 2 + 60),
        Offset(bodyX + 25, headY + headRadius * 2 + 100),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant HangmanPainter oldDelegate) {
    return oldDelegate.errorsCount != errorsCount || oldDelegate.color != color;
  }
}
