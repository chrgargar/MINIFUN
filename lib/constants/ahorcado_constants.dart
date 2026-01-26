/// Constantes para el juego Ahorcado
class ConstantesAhorcado {
  // Intentos máximos antes de perder
  static const int maxIntentos = 6;

  // Constantes de puntuación
  static const int puntosPorLetraCorrecta = 10;
  static const int puntosPorPalabraCompleta = 50;
  static const int penalizacionPorError = 5;
  static const int bonusTiempo = 100; // Bonus por completar rápido

  // Modo Velocidad - tiempo por letra (en segundos)
  static const int tiempoPorLetraNormal = 10; // 10 segundos por letra
  static const int tiempoPorLetraVelocidad = 5; // 5 segundos en modo velocidad
  static const int bonusLetraRapida = 5; // Bonus por adivinar rápido

  // Modo Supervivencia
  static const int vidasSupervivencia = 3; // 3 vidas en total
  static const int puntosPorPalabraSupervivencia = 100; // Más puntos por palabra

  // Palabras por temática y dificultad
  static const Map<String, Map<String, List<String>>> palabrasPorTematica = {
    'general': {
      'facil': [
        'GATO', 'PERRO', 'CASA', 'SOL', 'LUNA', 'AGUA', 'FUEGO', 'ARBOL',
        'FLOR', 'RIO', 'MAR', 'NIEVE', 'VIENTO', 'LLUVIA', 'CIELO', 'TIERRA',
        'MESA', 'SILLA', 'LIBRO', 'LAPIZ', 'PAPEL', 'RELOJ', 'PUERTA', 'CAMA'
      ],
      'medio': [
        'ELEFANTE', 'MARIPOSA', 'TELEFONO', 'BICICLETA', 'ESCUELA', 'VENTANA',
        'COMPUTADORA', 'BIBLIOTECA', 'HOSPITAL', 'MERCADO', 'TELEVISION',
        'REFRIGERADOR', 'LAVADORA', 'IMPRESORA', 'CALENDARIO', 'ESCRITORIO'
      ],
      'dificil': [
        'ELECTRICIDAD', 'UNIVERSIDAD', 'TECNOLOGIA', 'PROGRAMACION',
        'COMUNICACION', 'INVESTIGACION', 'ARQUITECTURA', 'MATEMATICAS',
        'EXTRAORDINARIO', 'ADMINISTRACION', 'RESPONSABILIDAD', 'CONOCIMIENTO'
      ]
    },
    'animales': {
      'facil': [
        'GATO', 'PERRO', 'PATO', 'RANA', 'LEON', 'TIGRE', 'OSO', 'LOBO',
        'RATA', 'PAVO', 'LORO', 'BUHO', 'PUMA', 'ZORRO', 'CIERVO', 'CONEJO'
      ],
      'medio': [
        'ELEFANTE', 'JIRAFA', 'CEBRA', 'COCODRILO', 'HIPOPOTAMO', 'RINOCERONTE',
        'GORILA', 'CHIMPANCE', 'DELFIN', 'BALLENA', 'TIBURON', 'TORTUGA',
        'SERPIENTE', 'LAGARTO', 'CANGREJO', 'PULPO'
      ],
      'dificil': [
        'ORANGUTAN', 'MURCIELAGO', 'ORNITORRINCO', 'SALAMANDRA', 'ARMADILLO',
        'PEREZOSO', 'PUERCOESPIN', 'CAMALEON', 'MANTARRAYA', 'ESCORPION'
      ]
    },
    'paises': {
      'facil': [
        'PERU', 'CUBA', 'CHILE', 'CHINA', 'INDIA', 'JAPON', 'COREA', 'RUSIA',
        'ITALIA', 'FRANCIA', 'ESPANA', 'GRECIA', 'EGIPTO', 'MEXICO', 'BRASIL'
      ],
      'medio': [
        'ALEMANIA', 'PORTUGAL', 'COLOMBIA', 'ARGENTINA', 'VENEZUELA', 'ECUADOR',
        'URUGUAY', 'PARAGUAY', 'BOLIVIA', 'CANADA', 'AUSTRALIA', 'NORUEGA'
      ],
      'dificil': [
        'MADAGASCAR', 'MOZAMBIQUE', 'AZERBAIYAN', 'KAZAJISTAN', 'UZBEKISTAN',
        'TURKMENISTAN', 'BANGLADESH', 'AFGANISTAN', 'LIECHTENSTEIN'
      ]
    },
    'comida': {
      'facil': [
        'PAN', 'QUESO', 'LECHE', 'HUEVO', 'ARROZ', 'PASTA', 'CARNE', 'POLLO',
        'SOPA', 'PIZZA', 'TACO', 'TORTA', 'FRESA', 'MANGO', 'LIMON', 'NARANJA'
      ],
      'medio': [
        'ESPAGUETI', 'HAMBURGUESA', 'ENSALADA', 'CHOCOLATE', 'GALLETA',
        'SANDWICH', 'LASAGNA', 'EMPANADA', 'TORTILLA', 'GUACAMOLE', 'BURRITO'
      ],
      'dificil': [
        'QUESADILLA', 'CHILAQUILES', 'ENCHILADAS', 'RATATOUILLE', 'CROISSANT',
        'CARPACCIO', 'BRUSCHETTA', 'ZANAHORIA', 'BERENJENA', 'CALABACIN'
      ]
    }
  };

  // Temáticas disponibles
  static const List<String> tematicas = ['general', 'animales', 'paises', 'comida'];

  // Partes del ahorcado (orden de dibujo)
  static const List<String> partesAhorcado = [
    'cabeza',    // 1 error
    'cuerpo',    // 2 errores
    'brazoIzq',  // 3 errores
    'brazoDer',  // 4 errores
    'piernaIzq', // 5 errores
    'piernaDer', // 6 errores - GAME OVER
  ];
}
