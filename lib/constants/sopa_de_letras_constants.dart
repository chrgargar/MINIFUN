import 'package:flutter/material.dart';

/// Constantes para el juego Sopa de Letras (Word Search)
class ConstantesSopaLetras {
  // Duración del modo contrarreloj en segundos
  static const int duracionContrarreloj = 180; // 3 minutos

  // Puntuación
  static const int puntosPorPalabra = 10;
  static const int bonusPalabraLarga = 5; // Bonus por palabras de más de 6 letras
  static const int penalizacionHint = 2; // Penalización por usar pista

  // Máximo número de palabras por dificultad
  static const Map<String, int> maxPalabras = {
    'facil': 8,
    'medio': 12,
    'dificil': 15,
  };

  // Direcciones posibles para colocar palabras (8 direcciones: horizontal, vertical, diagonales)
  static const List<List<int>> direcciones = [
    [0, 1],   // Derecha
    [1, 0],   // Abajo
    [0, -1],  // Izquierda
    [-1, 0],  // Arriba
    [1, 1],   // Diagonal abajo-derecha
    [1, -1],  // Diagonal abajo-izquierda
    [-1, 1],  // Diagonal arriba-derecha
    [-1, -1], // Diagonal arriba-izquierda
  ];

  // Palabras por temática y dificultad
  static const Map<String, Map<String, List<String>>> palabrasPorTematica = {
    'general': {
      'facil': [
        'CASA', 'PERRO', 'GATO', 'SOL', 'LUNA', 'AGUA', 'FUEGO', 'TIERRA',
        'AMOR', 'PAZ', 'HOMBRE', 'MUJER', 'NIÑO', 'MADRE', 'PADRE', 'AMIGO'
      ],
      'medio': [
        'COMPUTADORA', 'TELEVISOR', 'TELEFONO', 'BICICLETA', 'AUTOMOVIL',
        'HELADERIA', 'RESTAURANTE', 'SUPERMERCADO', 'BIBLIOTECA', 'ESCUELA',
        'UNIVERSIDAD', 'HOSPITAL', 'FARMACIA', 'PELUCUERIA', 'GIMNASIO'
      ],
      'dificil': [
        'ELECTRICIDAD', 'TECNOLOGIA', 'COMUNICACION', 'TRANSPORTE',
        'ALIMENTACION', 'EDUCACION', 'SALUD', 'DEPORTE', 'ENTRETENIMIENTO',
        'ARQUITECTURA', 'INGENIERIA', 'MEDICINA', 'ABOGACIA', 'ECONOMIA'
      ],
    },
    'peliculas': {
      'facil': [
        'TITANIC', 'AVATAR', 'MATRIX', 'JOKER', 'BATMAN', 'SPIDERMAN',
        'HARRY', 'POTTER', 'STAR', 'WARS', 'INDIANA', 'JONES'
      ],
      'medio': [
        'INTERSTELLAR', 'INCEPTION', 'GLADIATOR', 'BRAVEHEART',
        'PULP', 'FICTION', 'FORREST', 'GUMP', 'THE', 'LION', 'KING',
        'ALADDIN', 'BEAUTY', 'BEAST'
      ],
      'dificil': [
        'SCHINDLERS', 'LIST', 'THE', 'DEPARTED', 'GOODFELLAS',
        'CASABLANCA', 'CITIZEN', 'KANE', 'VERTIGO', 'PSYCHO',
        'NORTH', 'WEST', 'EASY', 'RIDER'
      ],
    },
    'musica': {
      'facil': [
        'ROCK', 'POP', 'JAZZ', 'BLUES', 'REGGAE', 'HIPHOP', 'DISCO',
        'SALSA', 'TANGO', 'FOLK', 'RAP', 'PUNK', 'METAL', 'INDIE'
      ],
      'medio': [
        'GUITARRA', 'PIANO', 'BATERIA', 'BAJO', 'SAXOFON', 'TROMPETA',
        'VIOLIN', 'FLAUTA', 'MICROFONO', 'ALTAVOZ', 'AMPLIFICADOR'
      ],
      'dificil': [
        'ORQUESTA', 'SINFONIA', 'CONCIERTO', 'OPERA', 'BALLET',
        'CORO', 'SOLISTA', 'DIRECTOR', 'COMPOSITOR', 'ARREGLO'
      ],
    },
    'historia': {
      'facil': [
        'ROMA', 'GRECIA', 'EGIPTO', 'CHINA', 'INDIA', 'FRANCIA',
        'INGLATERRA', 'ESPAÑA', 'ITALIA', 'ALEMANIA', 'RUSIA', 'JAPON'
      ],
      'medio': [
        'REVOLUCION', 'GUERRA', 'PAZ', 'TRATADO', 'CONQUISTA',
        'COLONIZACION', 'INDEPENDENCIA', 'DEMOCRACIA', 'MONARQUIA'
      ],
      'dificil': [
        'INDUSTRIALIZACION', 'RENACIMIENTO', 'ILUSTRACION',
        'REVOLUCION', 'FRANCESA', 'GUERRA', 'MUNDIAL', 'COLD', 'WAR',
        'GLOBALIZACION', 'TECNOLOGIA', 'MODERNIZACION'
      ],
    },
  };

  // Colores para el resaltado de palabras encontradas
  static const List<Color> highlightColors = [
    Color(0xFFF44336), // Rojo
    Color(0xFF2196F3), // Azul
    Color(0xFF4CAF50), // Verde
    Color(0xFFFFEB3B), // Amarillo
    Color(0xFF9C27B0), // Púrpura
    Color(0xFFFF9800), // Naranja
    Color(0xFFE91E63), // Rosa
    Color(0xFF00BCD4), // Cian
    Color(0xFF3F51B5), // Índigo
    Color(0xFFFFC107), // Ámbar
  ];
}