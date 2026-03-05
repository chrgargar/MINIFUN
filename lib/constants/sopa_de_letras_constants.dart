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

  // Palabras por temática, idioma y dificultad
  static const Map<String, Map<String, Map<String, List<String>>>> palabrasPorTematicaIdioma = {
    'general': {
      'es': {
        'facil': ['GATO', 'PERRO', 'CASA', 'SOL', 'LUNA', 'AGUA', 'FUEGO', 'TIERRA', 'AIRE', 'ARBOL', 'FLOR', 'RIO', 'MAR', 'ESTRELLA', 'NIEVE', 'VIENTO'],
        'medio': ['ELEFANTE', 'MARIPOSA', 'COMPUTADORA', 'TELEFONO', 'BICICLETA', 'HELADERIA', 'ESCUELA', 'BIBLIOTECA', 'HOSPITAL', 'SUPERMERCADO'],
        'dificil': ['ELECTRICIDAD', 'UNIVERSIDAD', 'TECNOLOGIA', 'PROGRAMACION', 'INFORMACION', 'COMUNICACION', 'DESARROLLO', 'INVESTIGACION', 'EDUCACION', 'CIENCIA']
      },
      'en': {
        'facil': ['CAT', 'DOG', 'HOUSE', 'SUN', 'MOON', 'WATER', 'FIRE', 'EARTH', 'AIR', 'TREE', 'FLOWER', 'RIVER', 'SEA', 'STAR', 'SNOW', 'WIND'],
        'medio': ['ELEPHANT', 'BUTTERFLY', 'COMPUTER', 'TELEPHONE', 'BICYCLE', 'SCHOOL', 'LIBRARY', 'HOSPITAL', 'SUPERMARKET', 'TELEVISION'],
        'dificil': ['ELECTRICITY', 'UNIVERSITY', 'TECHNOLOGY', 'PROGRAMMING', 'INFORMATION', 'COMMUNICATION', 'DEVELOPMENT', 'INVESTIGATION', 'EDUCATION', 'SCIENCE']
      },
      'ca': {
        'facil': ['GAT', 'GOS', 'CASA', 'SOL', 'LLUNA', 'AIGUA', 'FOC', 'TERRA', 'AIRE', 'ARBRE', 'FLOR', 'RIU', 'MAR', 'ESTRELLA', 'NEU', 'VENT'],
        'medio': ['ELEFANT', 'PAPALLONA', 'ORDINADOR', 'TELEFON', 'BICICLETA', 'ESCOLA', 'BIBLIOTECA', 'HOSPITAL', 'SUPERMERCAT', 'TELEVISIO'],
        'dificil': ['ELECTRICITAT', 'UNIVERSITAT', 'TECNOLOGIA', 'PROGRAMACIO', 'INFORMACIO', 'COMUNICACIO', 'DESENVOLUPAMENT', 'INVESTIGACIO', 'EDUCACIO', 'CIENCIA']
      }
    },
    'peliculas': {
      'es': {
        'facil': ['TITANIC', 'AVATAR', 'JOKER', 'FROZEN', 'MOANA', 'COCO', 'LEON', 'UP', 'VALIENTE', 'TOY', 'CARS', 'BUSCANDO', 'SHREK', 'PINOCHO', 'BAMBI', 'DUMBO'],
        'medio': ['HARRYPOTTER', 'STARWARS', 'AVENGERS', 'SPIDERMAN', 'BATMAN', 'SUPERMAN', 'IRONMAN', 'CAPITAN', 'THOR', 'HULK', 'MUJERMARAVILLA', 'FLASH'],
        'dificil': ['CABALLEROOSCURO', 'ORIGEN', 'INTERESTELAR', 'MATRIX', 'PULPFICTION', 'CLUBDELUCHA', 'FORRESTGUMP', 'PADRINO', 'LALISTASCHINDLER', 'CASABLANCA']
      },
      'en': {
        'facil': ['TITANIC', 'AVATAR', 'JOKER', 'FROZEN', 'MOANA', 'COCO', 'LION', 'UP', 'BRAVE', 'TOY', 'CARS', 'FINDING', 'SHREK', 'PINOCCHIO', 'BAMBI', 'DUMBO'],
        'medio': ['HARRYPOTTER', 'STARWARS', 'AVENGERS', 'SPIDERMAN', 'BATMAN', 'SUPERMAN', 'IRONMAN', 'CAPTAIN', 'THOR', 'HULK', 'WONDERWOMAN', 'FLASH'],
        'dificil': ['DARKKNIGHT', 'INCEPTION', 'INTERSTELLAR', 'MATRIX', 'PULPFICTION', 'FIGHTCLUB', 'FORRESTGUMP', 'GODFATHER', 'SCHINDLER', 'CASABLANCA']
      },
      'ca': {
        'facil': ['TITANIC', 'AVATAR', 'JOKER', 'CONGELADA', 'MOANA', 'COCO', 'LLEO', 'UP', 'VALENTA', 'TOY', 'CARS', 'TROBANT', 'SHREK', 'PINOTXO', 'BAMBI', 'DUMBO'],
        'medio': ['HARRYPOTTER', 'GUERRAESTRELLES', 'VENDJADORS', 'HOMEARANYA', 'BATMAN', 'SUPERMAN', 'HOMEFERRO', 'CAPITAN', 'THOR', 'HULK', 'DONADELMERAVELLA', 'FLASH'],
        'dificil': ['CAVALLERNEGRE', 'ORIGEN', 'INTERESTEL', 'MATRIX', 'PULPFICTION', 'CLUBLUITA', 'FORRESTGUMP', 'PADRINO', 'LISTALISTA', 'CASABLANCA']
      }
    },
    'musica': {
      'es': {
        'facil': ['ROCK', 'POP', 'JAZZ', 'BLUES', 'REGGAE', 'HIPHOP', 'RAP', 'SOUL', 'FUNK', 'DISCO', 'COUNTRY', 'FOLK', 'CLASICA', 'ELECTRONICA', 'METAL', 'PUNK'],
        'medio': ['BEATLES', 'ROLLINGSTONES', 'QUEEN', 'LEDZEPPELIN', 'PINKFLOYD', 'BOBDYLAN', 'MICHAELJACKSON', 'MADONNA', 'PRINCE', 'BRUCESPRINGSTEEN', 'U2', 'REM'],
        'dificil': ['SINFONIA', 'CONCIERTO', 'SONATA', 'OPERA', 'ORATORIO', 'CANTATA', 'FUGA', 'PRELUDIO', 'ESTUDIO', 'NOCTURNO', 'BALADA', 'SCHERZO']
      },
      'en': {
        'facil': ['ROCK', 'POP', 'JAZZ', 'BLUES', 'REGGAE', 'HIPHOP', 'RAP', 'SOUL', 'FUNK', 'DISCO', 'COUNTRY', 'FOLK', 'CLASSICAL', 'ELECTRONIC', 'METAL', 'PUNK'],
        'medio': ['BEATLES', 'ROLLINGSTONES', 'QUEEN', 'LEDZEPPELIN', 'PINKFLOYD', 'BOBDYLAN', 'MICHAELJACKSON', 'MADONNA', 'PRINCE', 'BRUCESPRINGSTEEN', 'U2', 'REM'],
        'dificil': ['SYMPHONY', 'CONCERTO', 'SONATA', 'OPERA', 'ORATORIO', 'CANTATA', 'FUGUE', 'PRELUDE', 'ETUDE', 'NOCTURNE', 'BALLADE', 'SCHERZO']
      },
      'ca': {
        'facil': ['ROCK', 'POP', 'JAZZ', 'BLUES', 'REGGAE', 'HIPHOP', 'RAP', 'SOUL', 'FUNK', 'DISCO', 'COUNTRY', 'FOLK', 'CLASSICA', 'ELECTRONICA', 'METAL', 'PUNK'],
        'medio': ['BEATLES', 'ROLLINGSTONES', 'QUEEN', 'LEDZEPPELIN', 'PINKFLOYD', 'BOBDYLAN', 'MICHAELJACKSON', 'MADONNA', 'PRINCE', 'BRUCESPRINGSTEEN', 'U2', 'REM'],
        'dificil': ['SINFONIA', 'CONCERTINO', 'SONATA', 'OPERA', 'ORATORI', 'CANTATA', 'FUGA', 'PRELUDI', 'ESTUDI', 'NOTURN', 'BALADA', 'SCHERZO']
      }
    },
    'historia': {
      'es': {
        'facil': ['ROMA', 'GRECIA', 'EGIPTO', 'CHINA', 'INDIA', 'MESOPOTAMIA', 'AZTECAS', 'INCAS', 'MAYA', 'VIKINGOS', 'CELTAS', 'PERSAS', 'CARTAGO', 'ESPARTA', 'ATENAS', 'TROYA'],
        'medio': ['REVOLUCIONFRANCESA', 'GUERRAMUNDIAL', 'RENACIMIENTO', 'ILUSTRACION', 'INDUSTRIALIZACION', 'COLONIZACION', 'IMPERIOROMANO', 'IMPERIOOTOMANO', 'IMPERIOMONGOL', 'CRUZADAS'],
        'dificil': ['REVOLUCIONINDUSTRIAL', 'GUERRACIENANOS', 'GUERRATRENTANOS', 'GUERRASUCESIONESPANOLA', 'GUERRASUCESIONAUSTRIA', 'GUERRASIETANOS', 'GUERRAINDEPENDENCIAAMERICANA', 'REVOLUCIONAMERICANA', 'REVOLUCIONHAITIANA', 'REVOLUCIONMEXICANA']
      },
      'en': {
        'facil': ['ROME', 'GREECE', 'EGYPT', 'CHINA', 'INDIA', 'MESOPOTAMIA', 'AZTECS', 'INCAS', 'MAYA', 'VIKINGS', 'CELTS', 'PERSIANS', 'CARTHAGE', 'SPARTA', 'ATHENS', 'TROY'],
        'medio': ['FRENCHREVOLUTION', 'WORLDWAR', 'RENAISSANCE', 'ENLIGHTENMENT', 'INDUSTRIALIZATION', 'COLONIZATION', 'ROMANEMPIRE', 'OTTOMANEMPIRE', 'MONGOLEMPIRE', 'CRUSADES'],
        'dificil': ['INDUSTRIALREVOLUTION', 'HUNDREDYEARSWAR', 'THIRTYYEARSWAR', 'SPANISHSUCCESSIO', 'AUSTRIANSUCCESSIO', 'SEVENYEARSWAR', 'AMERICANINDEPENDENCE', 'AMERICANREVOLUTION', 'HAITIANREVOLUTION', 'MEXICANREVOLUTION']
      },
      'ca': {
        'facil': ['ROMA', 'GRECIA', 'EGIPTE', 'XINA', 'INDIA', 'MESOPOTAMIA', 'AZTECAS', 'INCAS', 'MAYA', 'VIKINGS', 'CELTES', 'PERSAS', 'CARTAGO', 'ESPARTA', 'ATENES', 'TROIA'],
        'medio': ['REVOLUCIOFRANCESA', 'GUERRAMUNDIAL', 'RENAIXENCA', 'ILUSTRACIO', 'INDUSTRIALIZACIO', 'COLONITZACIO', 'IMPERIROMA', 'IMPERIOOTOMA', 'IMPERIOMONGOL', 'CROADES'],
        'dificil': ['REVOLUCIOINDUSTRIAL', 'GUERRCENTANOS', 'GUERRATRENTANOS', 'GUERRASUCCESIOESPANYOLA', 'GUERRASUCCESIOAUSTRIA', 'GUERRASIETANOS', 'GUERRAINDEPENDENCIAAMERICANA', 'REVOLUCIOAMERICANA', 'REVOLUCIOHEITIANA', 'REVOLUCIOMEXICANA']
      }
    }
  };

  // Método para obtener palabras según temática, idioma y dificultad
  static List<String> getPalabras(String tema, String idioma, String dificultad) {
    return palabrasPorTematicaIdioma[tema]?[idioma]?[dificultad] ?? [];
  }

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