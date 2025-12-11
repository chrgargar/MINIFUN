/// Constantes para el juego Snake
class ConstantesSnake {
  // Constantes del tablero
  static const int filas = 20;
  static const int columnas = 20;

  // Constantes de probabilidades
  static const double probabilidadComidaDorada = 0.15; // 15% de probabilidad de comida dorada
  static const double probabilidadManzana = 0.70; // 70% de probabilidad de manzana
  static const double probabilidadFresa = 0.15; // 15% de probabilidad de fresa

  // Constantes de tiempo (en milisegundos)
  static const int velocidadBase = 200; // Velocidad base del juego
  static const int velocidadRapida = 150; // Velocidad rápida
  static const int velocidadLenta = 300; // Velocidad lenta

  // Constantes de tiempo contrarreloj
  static const int tiempoInicialRestante = 30; // Tiempo inicial en segundos
  static const int limiteTiempoComida = 10; // Tiempo límite para comer una fruta
  static const int bonusComidaDorada = 10; // Bonus de tiempo por comida dorada
  static const int bonusComidaRegular = 3; // Bonus de tiempo por comida regular

  // Constantes de supervivencia PRO
  static const int intervaloGeneracionObstaculos = 2000; // Intervalo de generación de obstáculos (ms)
  static const int maxIntentosObstaculo = 50; // Intentos máximos para colocar un obstáculo
  static const int intervaloAumentoVelocidad = 5; // Cada cuántas manzanas aumentar velocidad
  static const double cantidadAumentoVelocidad = 10.0; // Reducción de ms por aumento de velocidad
  static const double velocidadMinima = 80.0; // Velocidad máxima (menor ms = más rápido)

  // Constantes de puntuación
  static const int puntosManzana = 10; // Puntos por manzana
  static const int puntosFresa = 20; // Puntos por fresa
  static const int puntosManzanaDorada = 30; // Puntos por manzana dorada
}
