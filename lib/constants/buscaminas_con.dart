import 'dart:math';

// Modelo: Celda
class Cell {
  final int row;
  final int col;
  bool isMine;
  bool isRevealed;
  bool isFlagged;
  int adjacentMines;

  Cell({
    required this.row,
    required this.col,
    this.isMine = false,
    this.isRevealed = false,
    this.isFlagged = false,
    this.adjacentMines = 0,
  });
}

// Controlador / Lógica del juego Buscaminas
class BuscaminasController {
  final int rows;
  final int cols;
  final int mineCount;

  late List<List<Cell>> board;
  bool minesPlaced = false;

  BuscaminasController({this.rows = 10, this.cols = 10, this.mineCount = 15}) {
    createBoard();
    minesPlaced = false;
  }

  void createBoard() {
    board = List.generate(rows, (i) => List.generate(cols, (j) => Cell(row: i, col: j)));
  }

  void placeMines({int? safeRow, int? safeCol}) {
    // Build candidate list excluding the safe cell and its adjacent neighbors (3x3)
    final List<List<int>> candidates = [];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        bool forbidden = false;
        if (safeRow != null && safeCol != null) {
          // exclude the 3x3 neighbourhood centered at (safeRow, safeCol)
          if ((r - safeRow).abs() <= 1 && (c - safeCol).abs() <= 1) forbidden = true;
        }
        if (!forbidden) candidates.add([r, c]);
      }
    }

    // If mineCount is too large for available candidates, trim to available size
    final available = candidates.length;
    final toPlace = mineCount.clamp(0, available);

    // Shuffle candidates and pick the first `toPlace` positions
    candidates.shuffle(Random());
    for (int i = 0; i < toPlace; i++) {
      final pos = candidates[i];
      board[pos[0]][pos[1]].isMine = true;
    }

    minesPlaced = true;
  }

  void calculateNumbers() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        if (!board[i][j].isMine) {
          int count = 0;
          for (int di = -1; di <= 1; di++) {
            for (int dj = -1; dj <= 1; dj++) {
              int ni = i + di;
              int nj = j + dj;
              if (ni >= 0 && ni < rows && nj >= 0 && nj < cols) {
                if (board[ni][nj].isMine) count++;
              }
            }
          }
          board[i][j].adjacentMines = count;
        }
      }
    }
  }

  // Devuelve true si se ha pisado una mina
  bool revealCell(int row, int col) {
    if (board[row][col].isFlagged) {
      board[row][col].isFlagged = false;
    }
    if (board[row][col].isRevealed) return false;

    board[row][col].isRevealed = true;
    if (board[row][col].isMine) return true;

    if (board[row][col].adjacentMines == 0) {
      _revealAdjacentCells(row, col);
    }
    return false;
  }

  void _revealAdjacentCells(int row, int col) {
    for (int di = -1; di <= 1; di++) {
      for (int dj = -1; dj <= 1; dj++) {
        int ni = row + di;
        int nj = col + dj;
        if (ni >= 0 && ni < rows && nj >= 0 && nj < cols) {
          if (!board[ni][nj].isRevealed && !board[ni][nj].isFlagged) {
            board[ni][nj].isRevealed = true;
            if (board[ni][nj].adjacentMines == 0) {
              _revealAdjacentCells(ni, nj);
            }
          }
        }
      }
    }
  }

  bool toggleFlag(int row, int col) {
    if (board[row][col].isRevealed) return false;
    if (board[row][col].isFlagged) {
      board[row][col].isFlagged = false;
      return false;
    } else {
      // solo colocar bandera; quien llama puede validar límite
      board[row][col].isFlagged = true;
      return true;
    }
  }

  void revealAllMines() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        if (board[i][j].isMine) board[i][j].isRevealed = true;
      }
    }
  }

  int countRevealed() {
    int count = 0;
    for (var row in board) {
      for (var cell in row) {
        if (cell.isRevealed && !cell.isMine) count++;
      }
    }
    return count;
  }

  int countFlags() {
    int count = 0;
    for (var row in board) {
      for (var cell in row) {
        if (cell.isFlagged) count++;
      }
    }
    return count;
  }

  int totalSafeCells() => rows * cols - mineCount;
}