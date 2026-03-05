import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/virtual_joystick.dart';
import '../widgets/game_control_buttons.dart';
import '../widgets/pause_overlay.dart';
import '../widgets/boton_guia.dart';
import '../data/guias_juegos.dart';
import '../tema/audio_settings.dart';
import '../tema/app_colors.dart';
import '../tema/language_provider.dart';
import '../constants/app_strings.dart';
import '../services/audio_service.dart';
import '../constants/snake_constants.dart';

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

class _SnakeGameState extends State<SnakeGame> {
  // Constantes del tablero
  static const int rows = ConstantesSnake.filas;
  static const int columns = ConstantesSnake.columnas;

  // Variables principales del juego
  List<Point<int>> snake = [const Point(10, 10)];
  Point<int> food = const Point(5, 5);
  Direction direction = Direction.right;
  int score = 0;

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
    startGame();

    // Escuchar cambios en la configuración de audio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AudioSettings>(context, listen: false).addListener(_onAudioSettingsChanged);
    });
  }

  void _onAudioSettingsChanged() {
    _updateMusicVolume();
  }

  @override
  void dispose() {
    timer?.cancel();
    gameTimer?.cancel();
    foodExpirationTimer?.cancel();
    obstacleTimer?.cancel();

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
    snake = [const Point(10, 10)];
    direction = Direction.right;
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

    final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: ColoresApp.blanco,
        title: Text(
          "⏱️ ${AppStrings.get('time_up', currentLang)}",
          style: TextStyle(color: ColoresApp.negro, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "${AppStrings.get('final_score', currentLang)}: $score",
          style: TextStyle(color: ColoresApp.negro),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              startGame();
            },
            child: Text(AppStrings.get('restart', currentLang), style: TextStyle(color: ColoresApp.moradoPrincipal)),
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

    // Verificar colisión con obstáculos primero (para sonido específico)
    final bool hitObstacle = widget.isSurvivalMode && obstacles.contains(newHead);

    // Colisión con paredes, consigo mismo u obstáculos
    if (newHead.x < 0 ||
        newHead.y < 0 ||
        newHead.x >= columns ||
        newHead.y >= rows ||
        snake.contains(newHead) ||
        hitObstacle) {
      timer?.cancel();
      gameTimer?.cancel(); // Detener temporizador del modo contrarreloj
      foodExpirationTimer?.cancel(); // Detener temporizador de expiración de frutas
      obstacleTimer?.cancel(); // Detener temporizador de obstáculos

      // Detener música de fondo
      AudioService.stopLoop();

      final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: ColoresApp.blanco,
          title: Text(
            "💀 ${AppStrings.get('game_over', currentLang)}",
            style: TextStyle(color: ColoresApp.negro, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "${AppStrings.get('score', currentLang)}: $score",
            style: TextStyle(color: ColoresApp.negro),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                startGame();
              },
              child: Text(AppStrings.get('restart', currentLang), style: TextStyle(color: ColoresApp.moradoPrincipal)),
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
      return;
    }

    if (newHead == food) {
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
    } else {
      snake = [newHead, ...snake];
      snake.removeLast();
    }
  }

  void _increaseSpeed() {
    // Aumentar velocidad en un 5% (reducir el tiempo del timer)
    currentSpeed = currentSpeed * 0.95;

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

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final btnSize = (sw * 0.09).clamp(28.0, 42.0);
    final scoreFontSize = (sw * 0.042).clamp(13.0, 20.0);
    final hPad = (sw * 0.028).clamp(8.0, 14.0);
    final gap = (sw * 0.024).clamp(6.0, 12.0);

    return Scaffold(
      backgroundColor: ColoresApp.negro,
      body: SafeArea(
        child: Stack(
          children: [
            // Área de juego con controles por gestos (swipe) - Ocupa toda la pantalla
            GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy < 0) changeDirection(Direction.up);
                if (details.delta.dy > 0) changeDirection(Direction.down);
              },
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx < 0) changeDirection(Direction.left);
                if (details.delta.dx > 0) changeDirection(Direction.right);
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calcular el tamaño óptimo para el tablero
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
                              // Tablero y serpiente
                              CustomPaint(
                                size: Size(boardWidth, boardHeight),
                                painter: SnakePainter(
                                  snake,
                                  food,
                                  cellSize,
                                ),
                              ),
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
              ),
            ),
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
              child: Builder(
                builder: (context) {
                  final currentLang = Provider.of<LanguageProvider>(context).currentLanguage;
                  return Row(
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
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: btnSize,
                          height: btnSize,
                          decoration: BoxDecoration(
                            color: ColoresApp.rojoError.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: ColoresApp.rojoError.withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(Icons.close, color: ColoresApp.blanco, size: btnSize * 0.55),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Joystick virtual centrado en la parte inferior
            Positioned(
              bottom: 15,
              left: 0,
              right: 0,
              child: Center(
                child: VirtualJoystick(
                  size: 150,
                  onUpPressed: () => changeDirection(Direction.up),
                  onDownPressed: () => changeDirection(Direction.down),
                  onLeftPressed: () => changeDirection(Direction.left),
                  onRightPressed: () => changeDirection(Direction.right),
                  buttonColor: ColoresApp.moradoPrincipal,
                  backgroundColor: ColoresApp.negro,
                ),
              ),
            ),
            // Overlay de pausa
            if (isPaused)
              PauseOverlay(
                onResume: togglePause,
                onRestart: () {
                  isPaused = false;
                  startGame();
                },
                onExit: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    );
  }
}

class SnakePainter extends CustomPainter {
  final List<Point<int>> snake;
  final Point<int> food;
  final double cellSize;

  SnakePainter(this.snake, this.food, this.cellSize);

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

    // 🐍 Serpiente mejorada
    final snakePaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color.fromARGB(255, 208, 83, 233), Colors.purple],
      ).createShader(Rect.fromLTWH(0, 0, cellSize, cellSize));
    for (final point in snake) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            point.x * cellSize,
            point.y * cellSize,
            cellSize,
            cellSize,
          ),
          const Radius.circular(6),
        ),
        snakePaint,
      );
    }

    // 🍎 La comida y los obstáculos ahora se renderizan como imágenes en el Stack, no aquí
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}