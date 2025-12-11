import 'package:flutter/material.dart';

/// Constantes para el juego Water Sort
class ConstantesWaterSort {
  // Capacidad de cada tubo (número de segmentos de agua)
  static const int tubeCapacity = 4;

  // Colores de agua disponibles para el juego
  static const List<Color> waterColors = [
    Color(0xFF2196F3), // Azul
    Color(0xFF4CAF50), // Verde
    Color(0xFFF44336), // Rojo
    Color(0xFFFF9800), // Naranja
    Color(0xFF9C27B0), // Púrpura
    Color(0xFFFFEB3B), // Amarillo
    Color(0xFF00BCD4), // Cian
    Color(0xFFE91E63), // Rosa
    Color(0xFF795548), // Marrón
    Color(0xFF607D8B), // Gris azulado
    Color(0xFF8BC34A), // Verde lima
    Color(0xFF3F51B5), // Índigo
  ];

  // Configuraciones de dificultad
  static const Map<String, Map<String, dynamic>> difficultyConfigs = {
    'facil': {
      'colors': 4,      // Número de colores
      'tubesExtra': 2,  // Tubos vacíos extra
      'timeLimit': 180, // 3 minutos para contrarreloj
    },
    'medio': {
      'colors': 6,
      'tubesExtra': 2,
      'timeLimit': 240, // 4 minutos
    },
    'dificil': {
      'colors': 8,
      'tubesExtra': 2,
      'timeLimit': 300, // 5 minutos
    },
    'extremo': {
      'colors': 10,
      'tubesExtra': 2,
      'timeLimit': 360, // 6 minutos
    },
  };

  // Obtener configuración por dificultad
  static Map<String, dynamic> getDifficultyConfig(String difficulty) {
    return difficultyConfigs[difficulty] ?? difficultyConfigs['facil']!;
  }

  // Puntuación base por completar nivel
  static const int baseScore = 100;

  // Bonus por movimientos mínimos
  static const int minMovesBonus = 50;

  // Bonus por tiempo restante (por cada 10 segundos)
  static const int timeBonus = 10;
}
