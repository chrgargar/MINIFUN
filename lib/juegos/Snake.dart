import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../widgets/virtual_joystick.dart';
import '../tema/audio_settings.dart';

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
  static const int rows = 20;
  static const int columns = 20;

  List<Point<int>> snake = [const Point(10, 10)];
  Point<int> food = const Point(5, 5);
  Direction direction = Direction.right;
  Timer? timer;
  int score = 0;

  // Reproductores de audio
  final AudioPlayer musicPlayer = AudioPlayer();
  final AudioPlayer sfxPlayer = AudioPlayer();
  final AudioPlayer movePlayer = AudioPlayer();

  // Variables para modo contrarreloj
  int timeLeft = 30; // Tiempo inicial en segundos
  Timer? gameTimer; // Timer del tiempo de juego
  Timer? foodExpirationTimer; // Timer para expiración de frutas
  bool isGoldenFood = false; // Si la fruta actual es dorada
  int foodTimeLeft = 10; // Tiempo restante de la fruta actual

  // Variables para modo supervivencia PRO
  List<Point<int>> obstacles = []; // Lista de bloques/obstáculos
  Timer? obstacleTimer; // Timer para generar obstáculos
  FoodType currentFoodType = FoodType.apple; // Tipo de comida actual
  int applesEaten = 0; // Contador de manzanas comidas
  double currentSpeed = 200; // Velocidad actual del juego

  @override
  void initState() {
    super.initState();
    _initAudio();
    startGame();

    // Escuchar cambios en la configuración de audio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AudioSettings>(context, listen: false).addListener(_onAudioSettingsChanged);
    });
  }

  void _onAudioSettingsChanged() {
    _updateMusicVolume();
    _updateSfxVolume();
  }

  @override
  void dispose() {
    timer?.cancel();
    gameTimer?.cancel();
    foodExpirationTimer?.cancel();
    obstacleTimer?.cancel();
    musicPlayer.dispose();
    sfxPlayer.dispose();
    movePlayer.dispose();

    // Remover listener de audio settings
    try {
      Provider.of<AudioSettings>(context, listen: false).removeListener(_onAudioSettingsChanged);
    } catch (e) {
      // Ignorar si el context ya no es válido
    }

    super.dispose();
  }

  Future<void> _initAudio() async {
    // Configurar música de fondo en loop
    await musicPlayer.setReleaseMode(ReleaseMode.loop);
    _updateMusicVolume();
    await musicPlayer.play(AssetSource('Sonidos/music.mp3'));
  }

  void _updateMusicVolume() {
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    musicPlayer.setVolume(audioSettings.musicVolume);
  }

  void _updateSfxVolume() {
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    sfxPlayer.setVolume(audioSettings.sfxVolume);
    movePlayer.setVolume(audioSettings.sfxVolume);
  }

  Future<void> _playSound(String sound) async {
    _updateSfxVolume();
    await sfxPlayer.play(AssetSource('Sonidos/$sound'));
  }

  Future<void> _playMoveSound() async {
    _updateSfxVolume();
    await movePlayer.play(AssetSource('Sonidos/move.mp3'));
  }

  void startGame() {
    snake = [const Point(10, 10)];
    direction = Direction.right;
    score = 0;
    timer?.cancel();
    gameTimer?.cancel();
    foodExpirationTimer?.cancel();
    obstacleTimer?.cancel();

    // Inicializar variables del modo contrarreloj
    if (widget.isTimeAttackMode) {
      timeLeft = 30;
      _startGameTimer();
    }

    // Inicializar variables del modo supervivencia
    if (widget.isSurvivalMode) {
      obstacles = [];
      applesEaten = 0;
      currentSpeed = 200;
      _startObstacleTimer();
    }

    spawnFood();

    // Calcular velocidad basada en el multiplicador
    // Velocidad base: 200ms, con multiplicador 1.5 será 133ms (más rápido)
    final baseSpeed = 200;
    final adjustedSpeed = (baseSpeed / widget.speedMultiplier).round();

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
    foodTimeLeft = isGoldenFood ? 5 : 10;

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

      // Si no encuentra posición después de 50 intentos, no generar obstáculo
      if (attempts > 50) return;

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
    musicPlayer.stop();
    _playSound('gameover.mp3');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("¡Tiempo Agotado!"),
        content: Text("Puntuación final: $score"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              musicPlayer.resume();
              startGame();
            },
            child: const Text("Reiniciar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Salir"),
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

    // En modo contrarreloj, determinar si es fruta dorada (15% de probabilidad)
    if (widget.isTimeAttackMode) {
      isGoldenFood = random.nextDouble() < 0.15; // 15% de probabilidad
      _startFoodExpirationTimer();
    }

    // En modo supervivencia, determinar el tipo de comida
    if (widget.isSurvivalMode) {
      final double rand = random.nextDouble();
      if (rand < 0.70) {
        currentFoodType = FoodType.apple; // 70% manzana
      } else if (rand < 0.85) {
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
      musicPlayer.stop(); // Detener música de fondo

      // Reproducir sonido específico según el tipo de colisión
      if (hitObstacle) {
        _playSound('obstaculo.mp3'); // Sonido de obstáculo
      } else {
        _playSound('gameover.mp3'); // Sonido de game over normal
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Game Over"),
          content: Text("Puntuación: $score"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                musicPlayer.resume(); // Reanudar música
                startGame();
              },
              child: const Text("Reiniciar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Salir"),
            ),
          ],
        ),
      );
      return;
    }

    // Reproducir sonido de movimiento
    _playMoveSound();

    if (newHead == food) {
      _playSound('food.mp3'); // Sonido al comer comida

      // En modo contrarreloj, agregar tiempo según el tipo de fruta
      if (widget.isTimeAttackMode) {
        score++;
        snake = [newHead, ...snake]; // Crecer normalmente
        if (isGoldenFood) {
          timeLeft += 7; // Fruta dorada suma 7 segundos
        } else {
          timeLeft += 3; // Fruta normal suma 3 segundos
        }
      }

      // En modo supervivencia, aplicar efectos según tipo de comida
      else if (widget.isSurvivalMode) {
        switch (currentFoodType) {
          case FoodType.apple:
            // Manzana: +1 tamaño, +1 punto
            score++;
            applesEaten++;
            snake = [newHead, ...snake]; // Crecer 1 segmento
            // Aumentar velocidad cada 10 manzanas
            if (applesEaten % 10 == 0) {
              _increaseSpeed();
            }
            break;
          case FoodType.strawberry:
            // Fresa: +3 tamaño, +3 puntos
            score += 3;
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
    if ((direction == Direction.up && newDirection == Direction.down) ||
        (direction == Direction.down && newDirection == Direction.up) ||
        (direction == Direction.left && newDirection == Direction.right) ||
        (direction == Direction.right && newDirection == Direction.left)) {
      return;
    }
    direction = newDirection;
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
    return Scaffold(
      backgroundColor: Colors.black,
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
              top: 16,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B3FF2).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7B3FF2).withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Score: $score',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Mostrar temporizador solo en modo contrarreloj
                  if (widget.isTimeAttackMode) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: timeLeft <= 10
                            ? Colors.red.withOpacity(0.9)
                            : Colors.orange.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (timeLeft <= 10 ? Colors.red : Colors.orange)
                                .withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, color: Colors.white, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            '${timeLeft}s',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
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
            // Botón de cerrar en la parte superior derecha
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.white,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            // Joystick virtual en la esquina inferior derecha
            Positioned(
              bottom: 20,
              right: 20,
              child: VirtualDPad(
                size: 160,
                onUpPressed: () => changeDirection(Direction.up),
                onDownPressed: () => changeDirection(Direction.down),
                onLeftPressed: () => changeDirection(Direction.left),
                onRightPressed: () => changeDirection(Direction.right),
                buttonColor: const Color(0xFF7B3FF2),
                backgroundColor: Colors.black,
              ),
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
    final paintLight = Paint()..color = Colors.green[400]!;
    final paintDark = Paint()..color = Colors.green[700]!;
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
    final wallPaint = Paint()..color = Colors.brown;
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