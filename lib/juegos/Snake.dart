import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_logger.dart';
import '../widgets/virtual_joystick.dart';
import '../widgets/game_control_buttons.dart';
import '../widgets/pause_overlay.dart';
import '../widgets/boton_guia.dart';
import '../constants/guias_juegos.dart';
import '../config/audio_settings.dart';
import '../config/app_colors.dart';
import '../config/language_provider.dart';
import '../constants/app_strings.dart';
import '../services/audio_service.dart';
import '../constants/snake_constants.dart';
import '../providers/mission_provider.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/game_close_button.dart';

class SnakeGame extends StatefulWidget {
  final double speedMultiplier; // Multiplicador de velocidad (1.0 = normal, 1.5 = velocidad, etc.)
  final bool isTimeAttackMode; // Modo contrarreloj activado
  final bool isSurvivalMode; // Modo supervivencia PRO activado

  const SnakeGame({
    super.key,
    this.speedMultiplier = 1.0, // Por defecto velocidad normal
    this.isTimeAttackMode = false, // Por defecto modo normal
    this.isSurvivalMode = false, // Por defecto modo normal
  });

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

enum Direction { up, down, left, right }

enum FoodType {
  apple,      // Manzana normal: +1 tamaño, +1 punto
  strawberry, // Fresa: +3 tamaño, +3 puntos
  coin,       // Moneda: +0 tamaño, +5 puntos
}

class _SnakeGameState extends State<SnakeGame> with WidgetsBindingObserver, TickerProviderStateMixin {
  // Constantes del tablero
  static const int rows = ConstantesSnake.filas;
  static const int columns = ConstantesSnake.columnas;

  // Variables principales del juego
  List<Point<int>> snake = [const Point(10, 10), const Point(9, 10), const Point(8, 10)];
  List<Point<int>> previousSnake = [const Point(10, 10), const Point(9, 10), const Point(8, 10)];
  Point<int> food = const Point(5, 5);
  Direction direction = Direction.right;
  Direction visualDirection = Direction.right; // Dirección visual de la cabeza (actualizada al moverse)
  int score = 0;

  // Animación de movimiento suave
  late AnimationController _moveController;

  // Timers
  Timer? timer; // Timer principal del movimiento de la serpiente
  Timer? gameTimer; // Timer del tiempo de juego (modo contrarreloj)
  Timer? foodExpirationTimer; // Timer para expiración de frutas
  Timer? obstacleTimer; // Timer para generar obstáculos (modo supervivencia)

  // Variables para modo contrarreloj
  int timeLeft = ConstantesSnake.tiempoInicialRestante;
  bool isGoldenFood = false; // Si la fruta actual es dorada
  int foodTimeLeft = ConstantesSnake.limiteTiempoComida;

  // Variables para modo supervivencia PRO
  List<Point<int>> obstacles = []; // Lista de bloques/obstáculos
  FoodType currentFoodType = FoodType.apple; // Tipo de comida actual
  int applesEaten = 0; // Contador de manzanas comidas
  double currentSpeed = ConstantesSnake.velocidadBase.toDouble();

  // Estado de pausa
  bool isPaused = false;

  @override
  void initState() {
    super.initState();

    // Observer para detectar cuando la app va al background
    WidgetsBinding.instance.addObserver(this);

    // Inicializar controlador de animación
    _moveController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (ConstantesSnake.velocidadBase / widget.speedMultiplier).round()),
    );

    // Rastrear pantalla actual
    appLogger.setCurrentScreen('SnakeGame');

    // Log inicio de partida
    String mode = 'normal';
    if (widget.isTimeAttackMode) mode = 'time_attack';
    if (widget.isSurvivalMode) mode = 'survival';
    appLogger.gameEvent('Snake', 'game_start', data: {'mode': mode, 'speed': widget.speedMultiplier});

    startGame();

    // Escuchar cambios en la configuración de audio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AudioSettings>(context, listen: false).addListener(_onAudioSettingsChanged);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pausar el juego cuando la app va al background
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (!isPaused) {
        togglePause();
      }
    }
  }

  void _onAudioSettingsChanged() {
    _updateMusicVolume();
  }

  @override
  void dispose() {
    // Remover observer de lifecycle
    WidgetsBinding.instance.removeObserver(this);

    timer?.cancel();
    gameTimer?.cancel();
    foodExpirationTimer?.cancel();
    obstacleTimer?.cancel();
    _moveController.dispose();

    // Detener música de fondo
    AudioService.stopLoop();

    // Remover listener de audio settings
    try {
      Provider.of<AudioSettings>(context, listen: false).removeListener(_onAudioSettingsChanged);
    } catch (e) {
      // Ignorar si el context ya no es válido
    }

    super.dispose();
  }

  void _updateMusicVolume() {
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    AudioService.setLoopVolume(audioSettings.musicVolume);
  }

  void _startBackgroundMusic() {
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    AudioService.playLoop('Sonidos/music_snake.mp3', audioSettings.musicVolume);
  }

  void startGame() {
    snake = [const Point(10, 10), const Point(9, 10), const Point(8, 10)];
    previousSnake = List.from(snake);
    direction = Direction.right;
    visualDirection = Direction.right;
    score = 0;
    timer?.cancel();
    gameTimer?.cancel();
    foodExpirationTimer?.cancel();
    obstacleTimer?.cancel();

    // Iniciar música de fondo
    _startBackgroundMusic();

    // Inicializar variables del modo contrarreloj
    if (widget.isTimeAttackMode) {
      timeLeft = ConstantesSnake.tiempoInicialRestante;
      _startGameTimer();
    }

    // Inicializar variables del modo supervivencia
    if (widget.isSurvivalMode) {
      obstacles = [];
      applesEaten = 0;
      currentSpeed = ConstantesSnake.velocidadBase.toDouble();
      _startObstacleTimer();
    }

    spawnFood();

    // Calcular velocidad basada en el multiplicador
    final adjustedSpeed = (ConstantesSnake.velocidadBase / widget.speedMultiplier).round();

    // Actualizar duración de la animación para que coincida con la velocidad del juego
    _moveController.duration = Duration(milliseconds: adjustedSpeed);

    timer = Timer.periodic(Duration(milliseconds: adjustedSpeed), (timer) {
      setState(moveSnake);
    });
  }

  void _startGameTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft--;
        if (timeLeft <= 0) {
          timer.cancel();
          _gameOver();
        }
      });
    });
  }

  void _startFoodExpirationTimer() {
    foodExpirationTimer?.cancel();
    foodTimeLeft = isGoldenFood ? 5 : ConstantesSnake.limiteTiempoComida;

    foodExpirationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        foodTimeLeft--;
        if (foodTimeLeft <= 0) {
          timer.cancel();
          spawnFood(); // Generar nueva fruta cuando expira
        }
      });
    });
  }

  void _startObstacleTimer() {
    obstacleTimer?.cancel();

    // Calcular tiempo dinámico basado en el tamaño de la serpiente
    // Comienza en 8 segundos y aumenta 2 segundos por cada 5 segmentos
    final int baseTime = 8;
    final int additionalTime = (snake.length ~/ 5) * 2;
    final int spawnTime = baseTime + additionalTime;

    obstacleTimer = Timer.periodic(Duration(seconds: spawnTime), (timer) {
      _spawnObstacle();
      // Reiniciar el timer con el nuevo tiempo
      timer.cancel();
      _startObstacleTimer();
    });
  }

  void _spawnObstacle() {
    final random = Random();
    Point<int> newObstacle;

    // Calcular zona de peligro (3 casillas adelante de la cabeza)
    final head = snake.first;
    final dangerZone = <Point<int>>[];
    for (int i = 1; i <= 3; i++) {
      switch (direction) {
        case Direction.up:
          dangerZone.add(Point(head.x, head.y - i));
          break;
        case Direction.down:
          dangerZone.add(Point(head.x, head.y + i));
          break;
        case Direction.left:
          dangerZone.add(Point(head.x - i, head.y));
          break;
        case Direction.right:
          dangerZone.add(Point(head.x + i, head.y));
          break;
      }
    }

    // Intentar encontrar una posición válida para el obstáculo
    int attempts = 0;
    do {
      newObstacle = Point(random.nextInt(columns), random.nextInt(rows));
      attempts++;

      // Si no encuentra posición después de maxObstacleAttempts intentos, no generar obstáculo
      if (attempts > ConstantesSnake.maxIntentosObstaculo) return;

      // Verificar que el obstáculo no esté:
      // 1. En la serpiente
      // 2. En la comida
      // 3. En otro obstáculo
      // 4. En la zona de peligro
    } while (snake.contains(newObstacle) ||
             newObstacle == food ||
             obstacles.contains(newObstacle) ||
             dangerZone.contains(newObstacle));

    setState(() {
      obstacles.add(newObstacle);
    });
  }

  void _gameOver() {
    timer?.cancel();
    gameTimer?.cancel();
    foodExpirationTimer?.cancel();
    AudioService.stopLoop();

    // Si el widget ya no está montado, no mostrar diálogo
    if (!mounted) return;

    // Log fin de partida
    appLogger.gameEvent('Snake', 'game_end', data: {'score': score, 'length': snake.length});

    // Notificar misiones
    final missionProvider = Provider.of<MissionProvider>(context, listen: false);
    missionProvider.notifyActivity(gameType: 'snake', activityType: MissionType.playGames);
    if (score > 0) {
      missionProvider.notifyActivity(gameType: 'snake', activityType: MissionType.reachScore, value: score);
    }

    final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;

    GameOverDialog.show(
      context: context,
      isVictory: false,
      customTitle: '⏱️ ${AppStrings.get('time_up', currentLang)}',
      message: '${AppStrings.get('final_score', currentLang)}: $score',
      onRestart: () {
        Navigator.pop(context);
        startGame();
      },
      onExit: () {
        timer?.cancel();
        gameTimer?.cancel();
        foodExpirationTimer?.cancel();
        obstacleTimer?.cancel();
        AudioService.stopLoop();
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );
  }

  void spawnFood() {
    final random = Random();
    Point<int> newFood;

    // Generar nueva posición para la comida, asegurándose de que no sea la misma que la anterior
    do {
      newFood = Point(random.nextInt(columns), random.nextInt(rows));
    } while (newFood == food ||
             snake.contains(newFood) ||
             (widget.isSurvivalMode && obstacles.contains(newFood)));

    food = newFood;

    // En modo contrarreloj, determinar si es fruta dorada
    if (widget.isTimeAttackMode) {
      isGoldenFood = random.nextDouble() < ConstantesSnake.probabilidadComidaDorada;
      _startFoodExpirationTimer();
    }

    // En modo supervivencia, determinar el tipo de comida
    if (widget.isSurvivalMode) {
      final double rand = random.nextDouble();
      if (rand < ConstantesSnake.probabilidadManzana) {
        currentFoodType = FoodType.apple; // 70% manzana
      } else if (rand < ConstantesSnake.probabilidadManzana + ConstantesSnake.probabilidadFresa) {
        currentFoodType = FoodType.strawberry; // 15% fresa
      } else {
        currentFoodType = FoodType.coin; // 15% moneda
      }
    }
  }

  bool _checkCollision(Point<int> newHead) {
    final bool hitObstacle = widget.isSurvivalMode && obstacles.contains(newHead);
    return newHead.x < 0 ||
        newHead.y < 0 ||
        newHead.x >= columns ||
        newHead.y >= rows ||
        snake.contains(newHead) ||
        hitObstacle;
  }

  void _handleFoodEaten(Point<int> newHead) {
    // Sonido de comer
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    AudioService.playSound('Sonidos/eat.ogg', audioSettings.musicVolume);

    // En modo contrarreloj, agregar tiempo según el tipo de fruta
    if (widget.isTimeAttackMode) {
      score++;
      snake = [newHead, ...snake]; // Crecer normalmente
      if (isGoldenFood) {
        timeLeft += ConstantesSnake.bonusComidaDorada;
      } else {
        timeLeft += ConstantesSnake.bonusComidaRegular;
      }
    }

    // En modo supervivencia, aplicar efectos según tipo de comida
    else if (widget.isSurvivalMode) {
      switch (currentFoodType) {
        case FoodType.apple:
          // Manzana: +1 tamaño, +ConstantesSnake.puntosManzana puntos
          score += ConstantesSnake.puntosManzana;
          applesEaten++;
          snake = [newHead, ...snake]; // Crecer 1 segmento
          // Aumentar velocidad cada ConstantesSnake.intervaloAumentoVelocidad manzanas
          if (applesEaten % ConstantesSnake.intervaloAumentoVelocidad == 0) {
            _increaseSpeed();
          }
          break;
        case FoodType.strawberry:
          // Fresa: +3 tamaño, +ConstantesSnake.puntosFresa puntos
          score += ConstantesSnake.puntosFresa;
          // Agregar 3 segmentos de golpe
          snake = [newHead, newHead, newHead, ...snake];
          break;
        case FoodType.coin:
          // Moneda: +0 tamaño, +5 puntos
          score += 5;
          // No agregar el nuevo segmento (no crecer)
          break;
      }
    }

    // En modo normal, comportamiento estándar
    else {
      score++;
      snake = [newHead, ...snake]; // Crecer normalmente
    }

    spawnFood();
  }

  void moveSnake() {
    final head = snake.first;
    Point<int> newHead;

    switch (direction) {
      case Direction.up:
        newHead = Point(head.x, head.y - 1);
        break;
      case Direction.down:
        newHead = Point(head.x, head.y + 1);
        break;
      case Direction.left:
        newHead = Point(head.x - 1, head.y);
        break;
      case Direction.right:
        newHead = Point(head.x + 1, head.y);
        break;
    }

    if (_checkCollision(newHead)) {
      // NO actualizar visualDirection al chocar - la cabeza mantiene su dirección
      timer?.cancel();
      gameTimer?.cancel(); // Detener temporizador del modo contrarreloj
      foodExpirationTimer?.cancel(); // Detener temporizador de expiración de frutas
      obstacleTimer?.cancel(); // Detener temporizador de obstáculos

      // Detener música de fondo
      AudioService.stopLoop();

      // Si el widget ya no está montado, no mostrar diálogo
      if (!mounted) return;

      // Sonido de colisión
      final audioSettings = Provider.of<AudioSettings>(context, listen: false);
      AudioService.playSound('Sonidos/hit.ogg', audioSettings.musicVolume);

      // Notificar misiones
      final missionProvider = Provider.of<MissionProvider>(context, listen: false);
      missionProvider.notifyActivity(gameType: 'snake', activityType: MissionType.playGames);
      if (score > 0) {
        missionProvider.notifyActivity(gameType: 'snake', activityType: MissionType.reachScore, value: score);
      }

      final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;

      GameOverDialog.show(
        context: context,
        isVictory: false,
        message: '${AppStrings.get('score', currentLang)}: $score',
        onRestart: () {
          Navigator.pop(context);
          startGame();
        },
        onExit: () {
          timer?.cancel();
          gameTimer?.cancel();
          foodExpirationTimer?.cancel();
          obstacleTimer?.cancel();
          AudioService.stopLoop();
          Navigator.pop(context);
          Navigator.pop(context);
        },
      );
      return;
    }

    // Actualizar dirección visual solo si el movimiento fue exitoso (sin colisión)
    visualDirection = direction;

    // Guardar posiciones anteriores para animación suave
    previousSnake = List.from(snake);

    if (newHead == food) {
      _handleFoodEaten(newHead);
    } else {
      snake = [newHead, ...snake];
      snake.removeLast();
    }

    // Iniciar animación de movimiento
    _moveController.reset();
    _moveController.forward();
  }

  void _increaseSpeed() {
    // Aumentar velocidad en un 5% (reducir el tiempo del timer)
    currentSpeed = currentSpeed * 0.95;

    // Actualizar duración de la animación para que coincida con la nueva velocidad
    _moveController.duration = Duration(milliseconds: currentSpeed.round());

    // Reiniciar el timer con la nueva velocidad
    timer?.cancel();
    timer = Timer.periodic(Duration(milliseconds: currentSpeed.round()), (timer) {
      setState(moveSnake);
    });
  }

  void changeDirection(Direction newDirection) {
    if (isPaused) return; // No cambiar dirección si está pausado
    if ((direction == Direction.up && newDirection == Direction.down) ||
        (direction == Direction.down && newDirection == Direction.up) ||
        (direction == Direction.left && newDirection == Direction.right) ||
        (direction == Direction.right && newDirection == Direction.left)) {
      return;
    }
    if (direction != newDirection) {
      // Sonido de cambio de dirección
      final audioSettings = Provider.of<AudioSettings>(context, listen: false);
      AudioService.playSound('Sonidos/move.ogg', audioSettings.musicVolume);
    }
    direction = newDirection;
  }

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
      if (isPaused) {
        timer?.cancel();
        gameTimer?.cancel();
        foodExpirationTimer?.cancel();
        obstacleTimer?.cancel();
      } else {
        // Reanudar timers
        final adjustedSpeed = widget.isSurvivalMode
            ? currentSpeed.round()
            : (ConstantesSnake.velocidadBase / widget.speedMultiplier).round();
        timer = Timer.periodic(Duration(milliseconds: adjustedSpeed), (timer) {
          setState(moveSnake);
        });
        if (widget.isTimeAttackMode) {
          _startGameTimer();
          _startFoodExpirationTimer();
        }
        if (widget.isSurvivalMode) {
          _startObstacleTimer();
        }
      }
    });
  }

  String _getFoodImage() {
    // Modo contrarreloj: manzana normal o dorada
    if (widget.isTimeAttackMode) {
      return isGoldenFood
          ? 'assets/imagenes/goldenapple.png'
          : 'assets/imagenes/apple.png';
    }

    // Modo supervivencia: diferentes tipos de comida
    if (widget.isSurvivalMode) {
      switch (currentFoodType) {
        case FoodType.apple:
          return 'assets/imagenes/apple.png';
        case FoodType.strawberry:
          return 'assets/imagenes/fresa.png';
        case FoodType.coin:
          return 'assets/imagenes/moneda.png';
      }
    }

    // Modo normal: solo manzana
    return 'assets/imagenes/apple.png';
  }

  // Obtener la imagen correcta para cada segmento de la serpiente
  String _getSnakeSegmentImage(int index) {
    final current = snake[index];

    // Cabeza (primer segmento) - usa la dirección visual (actualizada al moverse)
    if (index == 0) {
      switch (visualDirection) {
        case Direction.right: return 'assets/imagenes/snake/head_right.png';
        case Direction.left: return 'assets/imagenes/snake/head_left.png';
        case Direction.down: return 'assets/imagenes/snake/head_down.png';
        case Direction.up: return 'assets/imagenes/snake/head_up.png';
      }
    }

    // Si solo hay un segmento, no hay cola ni cuerpo
    if (snake.length < 2) return 'assets/imagenes/snake/head_right.png';

    // Cola (último segmento) - apunta en dirección opuesta al segmento anterior
    if (index == snake.length - 1) {
      final prev = snake[index - 1];
      // La cola apunta HACIA donde está el cuerpo (prev)
      if (prev.x > current.x) return 'assets/imagenes/snake/tail_left.png';
      if (prev.x < current.x) return 'assets/imagenes/snake/tail_right.png';
      if (prev.y > current.y) return 'assets/imagenes/snake/tail_up.png';
      return 'assets/imagenes/snake/tail_down.png';
    }

    // Cuerpo (segmentos intermedios)
    final prev = snake[index - 1];
    final next = snake[index + 1];

    // Horizontal
    if (prev.y == next.y) return 'assets/imagenes/snake/body_horizontal.png';
    // Vertical
    if (prev.x == next.x) return 'assets/imagenes/snake/body_vertical.png';

    // Esquinas
    final fromLeft = prev.x < current.x || next.x < current.x;
    final fromRight = prev.x > current.x || next.x > current.x;
    final fromTop = prev.y < current.y || next.y < current.y;
    final fromBottom = prev.y > current.y || next.y > current.y;

    if (fromTop && fromRight) return 'assets/imagenes/snake/body_topright.png';
    if (fromTop && fromLeft) return 'assets/imagenes/snake/body_topleft.png';
    if (fromBottom && fromRight) return 'assets/imagenes/snake/body_bottomright.png';
    if (fromBottom && fromLeft) return 'assets/imagenes/snake/body_bottomleft.png';

    return 'assets/imagenes/snake/body_horizontal.png';
  }

  Widget _buildGameBoard(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          // Calcular el tamaño óptimo para el tablero (usar todo el espacio)
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          final cellSize = min(screenWidth / columns, screenHeight / rows);
          final boardWidth = columns * cellSize;
          final boardHeight = rows * cellSize;

          return Stack(
            children: [
              // Tablero centrado
              Center(
                child: SizedBox(
                  width: boardWidth,
                  height: boardHeight,
                  child: Stack(
                    children: [
                      // Solo el tablero (fondo)
                      CustomPaint(
                        size: Size(boardWidth, boardHeight),
                        painter: BoardPainter(cellSize),
                      ),
                      // Serpiente con imágenes (movimiento discreto - sin animación)
                      ...List.generate(snake.length, (index) {
                        final segment = snake[index];
                        return Positioned(
                          left: segment.x * cellSize,
                          top: segment.y * cellSize,
                          child: Image.asset(
                            _getSnakeSegmentImage(index),
                            width: cellSize,
                            height: cellSize,
                            fit: BoxFit.cover,
                          ),
                        );
                      }),
                      // Obstáculos (lava)
                      if (widget.isSurvivalMode)
                        ...obstacles.map((obstacle) => Positioned(
                          left: obstacle.x * cellSize,
                          top: obstacle.y * cellSize,
                          child: Image.asset(
                            'assets/imagenes/lava.png',
                            width: cellSize,
                            height: cellSize,
                            fit: BoxFit.cover,
                          ),
                        )),
                      // Imagen de la comida
                      Positioned(
                        left: food.x * cellSize,
                        top: food.y * cellSize,
                        child: Image.asset(
                          _getFoodImage(),
                          width: cellSize,
                          height: cellSize,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
  }

  Widget _buildControls(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final btnSize = (sw * 0.09).clamp(28.0, 42.0);
    final scoreFontSize = (sw * 0.042).clamp(13.0, 20.0);
    final hPad = (sw * 0.028).clamp(8.0, 14.0);
    final gap = (sw * 0.024).clamp(6.0, 12.0);
    final currentLang = Provider.of<LanguageProvider>(context).currentLanguage;

    return Stack(
      children: [
        // Score en la parte superior izquierda
        Positioned(
          top: hPad,
          left: hPad,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: hPad * 0.5),
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
                child: Text(
                  'Score: $score',
                  style: TextStyle(
                    color: ColoresApp.blanco,
                    fontSize: scoreFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.isTimeAttackMode) ...[
                SizedBox(height: gap * 0.6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: hPad * 0.5),
                  decoration: BoxDecoration(
                    color: timeLeft <= ConstantesSnake.limiteTiempoComida
                        ? ColoresApp.rojoError.withOpacity(0.9)
                        : ColoresApp.naranjaAdvertencia.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (timeLeft <= ConstantesSnake.limiteTiempoComida ? ColoresApp.rojoError : ColoresApp.naranjaAdvertencia)
                            .withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer, color: ColoresApp.blanco, size: scoreFontSize),
                      SizedBox(width: gap * 0.5),
                      Text(
                        '${timeLeft}s',
                        style: TextStyle(
                          color: ColoresApp.blanco,
                          fontSize: scoreFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        // Botones de control en la parte superior derecha
        Positioned(
          top: hPad,
          right: hPad,
          child: Row(
            children: [
              GamePauseButton(
                isPaused: isPaused,
                onPressed: togglePause,
                size: btnSize,
              ),
              SizedBox(width: gap),
              GameRestartButton(
                onPressed: () {
                  if (isPaused) isPaused = false;
                  startGame();
                },
                size: btnSize,
              ),
              SizedBox(width: gap),
              BotonGuia(
                gameTitle: 'Snake',
                gameImagePath: 'assets/imagenes/sssnake.png',
                objetivo: AppStrings.get('snake_objective', currentLang),
                instrucciones: [
                  AppStrings.get('snake_inst_1', currentLang),
                  AppStrings.get('snake_inst_2', currentLang),
                  AppStrings.get('snake_inst_3', currentLang),
                  AppStrings.get('snake_inst_4', currentLang),
                  AppStrings.get('snake_inst_5', currentLang),
                ],
                controles: GuiasJuegos.getSnakeControles(currentLang),
                size: btnSize,
                onOpen: () { if (!isPaused) togglePause(); },
                onClose: () { if (isPaused) togglePause(); },
              ),
              SizedBox(width: gap),
              GameCloseButton(
                onTap: () {
                  // Cancelar todos los timers antes de salir
                  timer?.cancel();
                  gameTimer?.cancel();
                  foodExpirationTimer?.cancel();
                  obstacleTimer?.cancel();
                  AudioService.stopLoop();
                  Navigator.pop(context);
                },
                size: btnSize,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.negro,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque, // Detectar gestos en toda la pantalla incluyendo áreas vacías
        // Controles por gestos en toda la pantalla
        onVerticalDragUpdate: (details) {
          if (details.delta.dy < -5) changeDirection(Direction.up);
          if (details.delta.dy > 5) changeDirection(Direction.down);
        },
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx < -5) changeDirection(Direction.left);
          if (details.delta.dx > 5) changeDirection(Direction.right);
        },
        child: SafeArea(
          bottom: false, // Sin padding inferior para tablero más grande
          child: Stack(
            children: [
              // Área de juego - Ocupa toda la pantalla
              _buildGameBoard(context),

              // Score y botones de control
              _buildControls(context),

              // Overlay de pausa
              if (isPaused)
                PauseOverlay(
                  onResume: togglePause,
                  onRestart: () {
                    isPaused = false;
                    startGame();
                  },
                  onExit: () {
                    // Asegurar que todo está cancelado antes de salir
                    timer?.cancel();
                    gameTimer?.cancel();
                    foodExpirationTimer?.cancel();
                    obstacleTimer?.cancel();
                    AudioService.stopLoop();
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Painter solo para el fondo del tablero
class BoardPainter extends CustomPainter {
  final double cellSize;

  BoardPainter(this.cellSize);

  @override
  void paint(Canvas canvas, Size size) {
    // 🎨 Fondo estilo tablero de ajedrez verde
    final paintLight = Paint()..color = ColoresApp.colorCuerpoSerpiente;
    final paintDark = Paint()..color = ColoresApp.colorCabezaSerpiente;
    for (int y = 0; y < _SnakeGameState.rows; y++) {
      for (int x = 0; x < _SnakeGameState.columns; x++) {
        final paint = (x + y) % 2 == 0 ? paintLight : paintDark;
        canvas.drawRect(
          Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize),
          paint,
        );
      }
    }

    // 🎨 Paredes visibles (borde alrededor)
    final wallPaint = Paint()..color = ColoresApp.colorObstaculo;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      wallPaint..style = PaintingStyle.stroke..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}