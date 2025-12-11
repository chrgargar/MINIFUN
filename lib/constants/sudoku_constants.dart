/// Constantes para el juego Sudoku
class ConstantesSudoku {
  // Constantes del tablero
  static const int tamanoSudoku = 9; // Tamaño del tablero Sudoku (9x9)
  static const int tamanoCaja = 3; // Tamaño de cada caja (3x3)

  // Constantes de dificultad (celdas a eliminar)
  static const int celdasEliminadasFacil = 30; // Fácil: 30 celdas eliminadas
  static const int celdasEliminadasMedio = 45; // Medio: 45 celdas eliminadas
  static const int celdasEliminadasDificil = 55; // Difícil: 55 celdas eliminadas

  // Constantes de tiempo contrarreloj (en segundos)
  static const int duracionContrarreloj = 300; // 5 minutos para modo contrarreloj

  // Constantes de puntuación
  static const int puntosCeldaCorrecta = 10; // Puntos por celda correcta
  static const int penalizacionPista = 50; // Penalización por usar pista
  static const int penalizacionError = 10; // Penalización por error

  // Límites de errores
  static const int maxErroresModoPerfecto = 0; // Modo perfecto: sin errores
  static const int maxErroresModoNormal = 3; // Modo normal: máximo 3 errores

  // Constantes de validación
  static const int valorMinimoCelda = 1; // Valor mínimo de una celda
  static const int valorMaximoCelda = 9; // Valor máximo de una celda
  static const int valorCeldaVacia = 0; // Valor de una celda vacía
}
