import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

enum Direction { up, down, left, right }

class _SnakeGameState extends State<SnakeGame> {
  static const int rows = 20;
  static const int columns = 20;
  static const int squareSize = 20;

  List<Point<int>> snake = [const Point(10, 10)];
  Point<int> food = const Point(5, 5);
  Direction direction = Direction.right;
  Timer? timer;
  int score = 0;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    snake = [const Point(10, 10)];
    direction = Direction.right;
    score = 0;
    spawnFood();
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(moveSnake);
    });
  }

  void spawnFood() {
    final random = Random();
    food = Point(random.nextInt(columns), random.nextInt(rows));
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

    // Colisión con paredes o consigo mismo
    if (newHead.x < 0 ||
        newHead.y < 0 ||
        newHead.x >= columns ||
        newHead.y >= rows ||
        snake.contains(newHead)) {
      timer?.cancel();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Game Over"),
          content: Text("Score: $score"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                startGame();
              },
              child: const Text("Restart"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Leave"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/config');
              },
              child: const Text("Config"),
            ),
          ],
        ),
      );
      return;
    }

    snake = [newHead, ...snake];

    if (newHead == food) {
      score++;
      spawnFood();
    } else {
      snake.removeLast();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Snake - Score: $score"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy < 0) changeDirection(Direction.up);
          if (details.delta.dy > 0) changeDirection(Direction.down);
        },
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx < 0) changeDirection(Direction.left);
          if (details.delta.dx > 0) changeDirection(Direction.right);
        },
        child: Center(
          child: SizedBox(
            width: columns * squareSize.toDouble(),
            height: rows * squareSize.toDouble(),
            child: CustomPaint(
              painter: SnakePainter(snake, food),
            ),
          ),
        ),
      ),
    );
  }
}

class SnakePainter extends CustomPainter {
  final List<Point<int>> snake;
  final Point<int> food;

  SnakePainter(this.snake, this.food);

  @override
  void paint(Canvas canvas, Size size) {
    final double cellSize = _SnakeGameState.squareSize.toDouble();

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
        colors: [Colors.greenAccent, Colors.green],
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

    // 🍎 Manzana mejorada (círculo rojo con borde)
    final applePaint = Paint()..color = Colors.red;
    final appleBorder = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(
      Offset(food.x * cellSize + cellSize / 2,
          food.y * cellSize + cellSize / 2),
      cellSize / 2.2,
      applePaint,
    );
    canvas.drawCircle(
      Offset(food.x * cellSize + cellSize / 2,
          food.y * cellSize + cellSize / 2),
      cellSize / 2.2,
      appleBorder,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
