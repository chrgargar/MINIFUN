/// Constantes para el juego Sopa de Letras
class ConstantesSopaLetras {
  // Constantes del tablero
  // Nota: El tamaño del grid se calcula dinámicamente según dificultad en el juego

  // Palabras por dificultad
  static const List<String> palabrasFaciles = [
    'GATO',
    'PERRO',
    'CASA',
    'SOL',
    'LUNA',
    'AGUA',
    'FUEGO',
    'TIERRA',
    'AIRE',
    'ARBOL'
  ];

  static const List<String> palabrasMedias = [
    'ELEFANTE',
    'MARIPOSA',
    'COMPUTADORA',
    'TELEFONO',
    'BICICLETA',
    'HELADERIA',
    'ESCUELA',
    'BIBLIOTECA',
    'HOSPITAL',
    'SUPERMERCADO'
  ];

  static const List<String> palabrasDificiles = [
    'ELECTRICIDAD',
    'UNIVERSIDAD',
    'TECNOLOGIA',
    'PROGRAMACION',
    'INFORMACION',
    'COMUNICACION',
    'DESARROLLO',
    'INVESTIGACION',
    'EDUCACION',
    'CIENCIA'
  ];

  // Palabras por temática y dificultad
  static const Map<String, Map<String, List<String>>> palabrasPorTematica = {
    'general': {
      'facil': [
        'GATO', 'PERRO', 'CASA', 'SOL', 'LUNA', 'AGUA', 'FUEGO', 'TIERRA', 'AIRE', 'ARBOL',
        'FLOR', 'RIO', 'MAR', 'ESTRELLA', 'NIEVE', 'VIENTO', 'LLUVIA', 'RAYO', 'TRUENO', 'NIEBLA'
      ],
      'medio': [
        'ELEFANTE', 'MARIPOSA', 'COMPUTADORA', 'TELEFONO', 'BICICLETA', 'HELADERIA', 'ESCUELA', 'BIBLIOTECA',
        'HOSPITAL', 'SUPERMERCADO', 'TELEVISION', 'REFRIGERADOR', 'MICROONDAS', 'LAVADORA', 'ASPIRADORA',
        'TELEVISOR', 'RADIO', 'TELEFONO', 'IMPRESORA', 'ESCANER'
      ],
      'dificil': [
        'ELECTRICIDAD', 'UNIVERSIDAD', 'TECNOLOGIA', 'PROGRAMACION', 'INFORMACION', 'COMUNICACION',
        'DESARROLLO', 'INVESTIGACION', 'EDUCACION', 'CIENCIA', 'MATEMATICAS', 'FISICA', 'QUIMICA',
        'BIOLOGIA', 'HISTORIA', 'GEOGRAFIA', 'LITERATURA', 'FILOSOFIA'
      ]
    },
    'peliculas': {
      'facil': [
        'TITANIC', 'AVATAR', 'JOKER', 'FROZEN', 'MOANA', 'COCO', 'LION', 'UP', 'BRAVE', 'TOY',
        'CARS', 'NEMO', 'SHREK', 'POOH', 'BAMBI', 'DUMBO', 'PINOCCHIO', 'ALADDIN', 'MULAN', 'TARZAN'
      ],
      'medio': [
        'HARRY POTTER', 'STAR WARS', 'AVENGERS', 'SPIDERMAN', 'BATMAN', 'SUPERMAN', 'IRON MAN',
        'CAPTAIN AMERICA', 'THOR', 'HULK', 'WONDER WOMAN', 'FLASH', 'AQUAMAN', 'GREEN LANTERN',
        'JUSTICE LEAGUE', 'X MEN', 'FANTASTIC FOUR', 'GUARDIANS', 'ANT MAN', 'BLACK WIDOW'
      ],
      'dificil': [
        'THE DARK KNIGHT', 'INCEPTION', 'INTERSTELLAR', 'THE MATRIX', 'PULP FICTION', 'FIGHT CLUB',
        'FORREST GUMP', 'THE GODFATHER', 'SCHINDLERS LIST', 'CASABLANCA', 'CITIZEN KANE',
        'THE WIZARD OF OZ', 'GONE WITH THE WIND', 'LAWRENCE OF ARABIA', 'VERTIGO', 'PSYCHO',
        '2001 A SPACE ODYSSEY', 'CLOCKWORK ORANGE', 'TAXI DRIVER', 'JAWS'
      ]
    },
    'musica': {
      'facil': [
        'ROCK', 'POP', 'JAZZ', 'BLUES', 'REGGAE', 'HIPHOP', 'RAP', 'SOUL', 'FUNK', 'DISCO',
        'COUNTRY', 'FOLK', 'CLASSICAL', 'ELECTRONIC', 'METAL', 'PUNK', 'INDIE', 'ALTERNATIVE'
      ],
      'medio': [
        'BEATLES', 'ROLLING STONES', 'QUEEN', 'LED ZEPPELIN', 'PINK FLOYD', 'BOB DYLAN',
        'MICHAEL JACKSON', 'MADONNA', 'PRINCE', 'BRUCE SPRINGSTEEN', 'U2', 'REM', 'NIRVANA',
        'PEARL JAM', 'RADIOHEAD', 'COLDPLAY', 'ADELE', 'TAYLOR SWIFT'
      ],
      'dificil': [
        'SYMPHONY', 'CONCERTO', 'SONATA', 'OPERA', 'ORATORIO', 'CANTATA', 'FUGUE', 'PRELUDE',
        'ETUDE', 'NOCTURNE', 'BALLADE', 'SCHERZO', 'RONDO', 'OVERTURE', 'SUITE', 'SERENADE',
        'DIVERTIMENTO', 'CAPRICCIO', 'TOCCATA', 'FANTASIA'
      ]
    },
    'historia': {
      'facil': [
        'ROMA', 'GRECIA', 'EGIPTO', 'CHINA', 'INDIA', 'MESOPOTAMIA', 'AZTECAS', 'INCAS', 'MAYA',
        'VIKINGOS', 'CELTAS', 'PERSAS', 'CARTHAGO', 'ESPARTA', 'ATENAS', 'TROY', 'BABYLON', 'ASSYRIA'
      ],
      'medio': [
        'REVOLUCION FRANCESA', 'GUERRA MUNDIAL', 'RENACIMIENTO', 'ILUSTRACION', 'INDUSTRIALIZACION',
        'COLONIZACION', 'IMPERIO ROMANO', 'IMPERIO OTOMANO', 'IMPERIO MONGOL', 'CRUZADAS',
        'EXPLORACIONES', 'REFORMA PROTESTANTE', 'CONTRAREFORMA', 'ABSOLUTISMO', 'LIBERALISMO'
      ],
      'dificil': [
        'REVOLUCION INDUSTRIAL', 'GUERRA DE LOS CIEN ANOS', 'GUERRA DE LOS TREINTA ANOS',
        'GUERRA DE SUCESION ESPANOLA', 'GUERRA DE SUCESION AUSTRIA', 'GUERRA DE LOS SIETE ANOS',
        'GUERRA DE INDEPENDENCIA AMERICANA', 'REVOLUCION AMERICANA', 'REVOLUCION HAITIANA',
        'REVOLUCION MEXICANA', 'REVOLUCION RUSA', 'GUERRA CIVIL ESPANOLA', 'SEGUNDA GUERRA MUNDIAL'
      ]
    }
  };

  // Temáticas disponibles
  static const List<String> tematicas = ['general', 'peliculas', 'musica', 'historia'];

  // Número máximo de palabras por dificultad
  static const Map<String, int> maxPalabras = {
    'facil': 8,
    'medio': 10,
    'dificil': 12
  };

  // Constantes de tiempo contrarreloj (en segundos)
  static const int duracionContrarreloj = 300; // 5 minutos

  // Constantes de puntuación
  static const int puntosPorPalabra = 20; // Puntos por palabra encontrada
  static const int penalizacionPista = 30; // Penalización por usar pista

  // Límites de errores
  static const int maxErroresModoPerfecto = 0; // Modo perfecto: sin errores

  // Direcciones posibles (horizontal, vertical, diagonal)
  static const List<List<int>> direcciones = [
    [0, 1],   // derecha
    [1, 0],   // abajo
    [1, 1],   // diagonal abajo-derecha
    [1, -1],  // diagonal abajo-izquierda
    [0, -1],  // izquierda
    [-1, 0],  // arriba
    [-1, -1], // diagonal arriba-izquierda
    [-1, 1],  // diagonal arriba-derecha
  ];
}