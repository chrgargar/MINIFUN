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

    if (newHead.x < 0 ||
        newHead.y < 0 ||
        newHead.x >= columns ||
        newHead.y >= rows ||
        snake.contains(newHead)) {
      timer?.cancel();
      showDialog(
        context: context,
        barrierDismissible: false, // 👈 cannot click outside
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
                Navigator.pop(context); // 👈 leave game
              },
              child: const Text("Leave"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // 👇 open config menu (replace with your settings screen)
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
            onPressed: () => Navigator.pop(context), // 👈 exit game
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              width: columns * squareSize.toDouble(),
              height: rows * squareSize.toDouble(),
              child: CustomPaint(
                painter: SnakePainter(snake, food),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Direction buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_upward, color: Colors.white),
                onPressed: () => changeDirection(Direction.up),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => changeDirection(Direction.left),
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                onPressed: () => changeDirection(Direction.right),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_downward, color: Colors.white),
                onPressed: () => changeDirection(Direction.down),
              ),
            ],
          ),
        ],
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
    final paintSnake = Paint()..color = Colors.green;
    final paintFood = Paint()..color = Colors.red;

    for (final point in snake) {
      canvas.drawRect(
        Rect.fromLTWH(
          point.x * _SnakeGameState.squareSize.toDouble(),
          point.y * _SnakeGameState.squareSize.toDouble(),
          _SnakeGameState.squareSize.toDouble(),
          _SnakeGameState.squareSize.toDouble(),
        ),
        paintSnake,
      );
    }

    canvas.drawRect(
      Rect.fromLTWH(
        food.x * _SnakeGameState.squareSize.toDouble(),
        food.y * _SnakeGameState.squareSize.toDouble(),
        _SnakeGameState.squareSize.toDouble(),
        _SnakeGameState.squareSize.toDouble(),
      ),
      paintFood,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
