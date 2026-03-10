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

  // Pistas disponibles por dificultad
  static const Map<String, int> pistasPorDificultad = {
    'facil': 3,
    'medio': 2,
    'dificil': 1,
  };

  // Pistas para cada palabra (3 pistas por palabra, de más vaga a más específica)
  static const Map<String, List<String>> pistas = {
    // GENERAL - Fácil
    'GATO': ['Es un animal doméstico', 'Dice "miau"', 'Le gusta cazar ratones'],
    'PERRO': ['Es el mejor amigo del hombre', 'Dice "guau"', 'Mueve la cola cuando está feliz'],
    'CASA': ['Es un lugar para vivir', 'Tiene techo y paredes', 'Es tu hogar'],
    'SOL': ['Sale de día', 'Es amarillo y brillante', 'Es una estrella'],
    'LUNA': ['Sale de noche', 'Tiene fases', 'Los lobos le aúllan'],
    'AGUA': ['Es líquida', 'La bebes cuando tienes sed', 'Cubre el 70% de la Tierra'],
    'FUEGO': ['Es muy caliente', 'Puede quemar', 'Es rojo y naranja'],
    'ARBOL': ['Es una planta grande', 'Tiene hojas y ramas', 'Los pájaros hacen nidos en él'],
    'FLOR': ['Es parte de una planta', 'Es bonita y colorida', 'Las abejas la visitan'],
    'RIO': ['Es agua que fluye', 'Desemboca en el mar', 'Los peces viven ahí'],
    'MAR': ['Es muy grande y salado', 'Tiene olas', 'Los barcos navegan en él'],
    'NIEVE': ['Es blanca y fría', 'Cae en invierno', 'Puedes hacer muñecos con ella'],
    'VIENTO': ['No se ve pero se siente', 'Mueve las hojas', 'Puede ser muy fuerte'],
    'LLUVIA': ['Cae del cielo', 'Moja todo', 'Viene de las nubes'],
    'CIELO': ['Está arriba de ti', 'Es azul de día', 'Las estrellas están ahí de noche'],
    'TIERRA': ['Es donde vivimos', 'Es un planeta', 'Gira alrededor del Sol'],
    'MESA': ['Es un mueble', 'Tiene patas y superficie plana', 'Comes sobre ella'],
    'SILLA': ['Es para sentarse', 'Tiene respaldo', 'Va junto a la mesa'],
    'LIBRO': ['Tiene muchas páginas', 'Se lee', 'Cuenta historias o información'],
    'LAPIZ': ['Sirve para escribir', 'Es de madera', 'Tiene una punta de grafito'],
    'PAPEL': ['Es delgado y plano', 'Se escribe en él', 'Viene de los árboles'],
    'RELOJ': ['Marca el tiempo', 'Tiene números', 'Tiene manecillas o pantalla digital'],
    'PUERTA': ['Se abre y se cierra', 'Tiene manija', 'Sirve para entrar a un lugar'],
    'CAMA': ['Es para dormir', 'Tiene colchón', 'Tiene almohadas y sábanas'],

    // GENERAL - Medio
    'ELEFANTE': ['Es el animal terrestre más grande', 'Tiene trompa', 'Vive en África y Asia'],
    'MARIPOSA': ['Tiene alas coloridas', 'Era una oruga', 'Vuela entre las flores'],
    'TELEFONO': ['Sirve para comunicarse', 'Puedes llamar y escribir mensajes', 'Todos llevan uno en el bolsillo'],
    'BICICLETA': ['Tiene dos ruedas', 'Se pedalea', 'Es un vehículo sin motor'],
    'ESCUELA': ['Es donde se estudia', 'Hay profesores y alumnos', 'Tiene aulas y pizarras'],
    'VENTANA': ['Deja pasar la luz', 'Es de vidrio', 'Se puede abrir para que entre aire'],
    'COMPUTADORA': ['Es una máquina electrónica', 'Tiene pantalla y teclado', 'Sirve para trabajar y jugar'],
    'BIBLIOTECA': ['Tiene muchos libros', 'Debes guardar silencio', 'Puedes pedir prestado material'],
    'HOSPITAL': ['Van los enfermos', 'Hay doctores y enfermeras', 'Te curan ahí'],
    'MERCADO': ['Se venden cosas', 'Hay frutas, verduras, etc.', 'La gente va a comprar alimentos'],
    'TELEVISION': ['Es una pantalla grande', 'Muestra programas y películas', 'Tiene control remoto'],
    'REFRIGERADOR': ['Mantiene la comida fría', 'Está en la cocina', 'Tiene congelador'],
    'LAVADORA': ['Limpia la ropa', 'Usa agua y jabón', 'Tiene un tambor que gira'],
    'IMPRESORA': ['Pone tinta en papel', 'Se conecta a la computadora', 'Crea documentos físicos'],
    'CALENDARIO': ['Muestra los días del año', 'Tiene meses y semanas', 'Sirve para organizar fechas'],
    'ESCRITORIO': ['Es un mueble para trabajar', 'Tiene cajones', 'Pones tu computadora encima'],

    // GENERAL - Difícil
    'ELECTRICIDAD': ['Hace funcionar los aparatos', 'Viaja por cables', 'Los rayos la producen'],
    'UNIVERSIDAD': ['Es para estudios superiores', 'Otorga títulos profesionales', 'Hay carreras y facultades'],
    'TECNOLOGIA': ['Son avances científicos', 'Mejora nuestra vida', 'Computadoras y celulares la usan'],
    'PROGRAMACION': ['Crea software', 'Usa código', 'Los desarrolladores la practican'],
    'COMUNICACION': ['Es el intercambio de información', 'Puede ser verbal o escrita', 'Es fundamental para la sociedad'],
    'INVESTIGACION': ['Busca descubrir cosas nuevas', 'Usa el método científico', 'La hacen los científicos'],
    'ARQUITECTURA': ['Diseña edificios', 'Combina arte y ciencia', 'Los arquitectos la estudian'],
    'MATEMATICAS': ['Es la ciencia de los números', 'Incluye álgebra y geometría', 'Se usa para calcular'],
    'EXTRAORDINARIO': ['Significa fuera de lo común', 'Es algo muy especial', 'Lo opuesto a ordinario'],
    'ADMINISTRACION': ['Gestiona recursos', 'Organiza empresas', 'Planifica y controla'],
    'RESPONSABILIDAD': ['Es cumplir con tus deberes', 'Es una virtud', 'Implica madurez'],
    'CONOCIMIENTO': ['Es lo que sabes', 'Se adquiere estudiando', 'La educación lo proporciona'],

    // ANIMALES - Fácil
    'LEON': ['Es el rey de la selva', 'Tiene melena', 'Ruge muy fuerte'],
    'TIGRE': ['Tiene rayas', 'Es un gran felino', 'Vive en Asia'],
    'OSO': ['Es grande y peludo', 'Hiberna en invierno', 'Le gusta la miel'],
    'LOBO': ['Aúlla a la luna', 'Vive en manadas', 'Es pariente del perro'],
    'RATA': ['Es un roedor pequeño', 'Tiene cola larga', 'Vive en ciudades'],
    'PAVO': ['Se come en Navidad', 'Hace "glu glu"', 'Tiene plumas coloridas'],
    'LORO': ['Puede hablar', 'Tiene plumas coloridas', 'Vive en árboles tropicales'],
    'BUHO': ['Caza de noche', 'Dice "uh-uh"', 'Puede girar mucho la cabeza'],
    'PUMA': ['Es un gran felino americano', 'Es color café', 'También se llama león de montaña'],
    'ZORRO': ['Es astuto', 'Es de color naranja', 'Tiene cola esponjosa'],
    'CIERVO': ['Tiene cuernos llamados astas', 'Es un herbívoro', 'Rudolph es uno famoso'],
    'CONEJO': ['Tiene orejas largas', 'Salta mucho', 'Come zanahorias'],
    'PATO': ['Dice "cuac"', 'Nada en el agua', 'Donald es uno famoso'],
    'RANA': ['Salta y crocea', 'Vive en el agua y en tierra', 'Era un renacuajo'],

    // ANIMALES - Medio
    'JIRAFA': ['Es el animal más alto', 'Tiene cuello muy largo', 'Tiene manchas'],
    'CEBRA': ['Parece un caballo rayado', 'Es blanca y negra', 'Vive en África'],
    'COCODRILO': ['Es un reptil grande', 'Vive en ríos', 'Tiene muchos dientes'],
    'HIPOPOTAMO': ['Pasa mucho tiempo en el agua', 'Es muy grande y pesado', 'Vive en África'],
    'RINOCERONTE': ['Tiene cuernos en la nariz', 'Es muy grande', 'Está en peligro de extinción'],
    'GORILA': ['Es un primate grande', 'Vive en la selva', 'Se golpea el pecho'],
    'CHIMPANCE': ['Es muy inteligente', 'Usa herramientas', 'Es pariente del humano'],
    'DELFIN': ['Es muy inteligente', 'Vive en el mar', 'Hace sonidos con clicks'],
    'BALLENA': ['Es el animal más grande', 'Vive en el océano', 'Es un mamífero marino'],
    'TIBURON': ['Es un pez depredador', 'Tiene muchos dientes', 'La película Jaws es sobre él'],
    'TORTUGA': ['Tiene caparazón', 'Es muy lenta', 'Puede vivir muchos años'],
    'SERPIENTE': ['No tiene patas', 'Se arrastra', 'Algunas son venenosas'],
    'LAGARTO': ['Es un reptil', 'Tiene cola larga', 'Le gusta el sol'],
    'CANGREJO': ['Camina de lado', 'Tiene pinzas', 'Vive en la playa'],
    'PULPO': ['Tiene ocho tentáculos', 'Vive en el mar', 'Puede cambiar de color'],

    // ANIMALES - Difícil
    'ORANGUTAN': ['Es un primate naranja', 'Vive en árboles', 'Es muy inteligente'],
    'MURCIELAGO': ['Vuela de noche', 'Es el único mamífero volador', 'Usa ecolocación'],
    'ORNITORRINCO': ['Pone huevos pero es mamífero', 'Tiene pico de pato', 'Vive en Australia'],
    'SALAMANDRA': ['Es un anfibio', 'Parece lagartija', 'Regenera partes de su cuerpo'],
    'ARMADILLO': ['Tiene armadura', 'Se hace bolita', 'Vive en América'],
    'PEREZOSO': ['Es muy lento', 'Duerme mucho', 'Vive colgado de los árboles'],
    'PUERCOESPIN': ['Tiene púas', 'Se defiende pinchando', 'Es un roedor'],
    'CAMALEON': ['Cambia de color', 'Tiene lengua muy larga', 'Sus ojos se mueven independientes'],
    'MANTARRAYA': ['Parece una manta', 'Nada en el mar', 'Tiene cola larga'],
    'ESCORPION': ['Tiene pinzas y aguijón', 'Es venenoso', 'Vive en el desierto'],

    // PAISES - Fácil
    'PERU': ['Está en Sudamérica', 'Tiene Machu Picchu', 'Su capital es Lima'],
    'CUBA': ['Es una isla caribeña', 'Tiene música y baile', 'Su capital es La Habana'],
    'CHILE': ['Es largo y delgado', 'Está en Sudamérica', 'Tiene el desierto de Atacama'],
    'CHINA': ['Tiene la muralla más famosa', 'Es el país más poblado', 'Inventaron la pólvora'],
    'INDIA': ['Tiene el Taj Mahal', 'Tiene vacas sagradas', 'Es muy poblado'],
    'JAPON': ['Es el país del sol naciente', 'Tiene sushi y anime', 'Su capital es Tokio'],
    'COREA': ['Está dividido en dos', 'Tiene K-pop', 'Está en Asia'],
    'RUSIA': ['Es el país más grande', 'Tiene el Kremlin', 'Tiene inviernos muy fríos'],
    'ITALIA': ['Tiene forma de bota', 'Inventó la pizza', 'Roma es su capital'],
    'FRANCIA': ['Tiene la Torre Eiffel', 'Su capital es París', 'Es famoso por el vino'],
    'ESPANA': ['Tiene corridas de toros', 'Su idioma es el español', 'Tiene flamenco'],
    'GRECIA': ['Inventó la democracia', 'Tiene el Partenón', 'Tuvo dioses como Zeus'],
    'EGIPTO': ['Tiene pirámides', 'Tiene la Esfinge', 'El Nilo pasa por ahí'],
    'MEXICO': ['Tiene tacos y mariachis', 'Su capital es muy grande', 'Tiene pirámides mayas'],
    'BRASIL': ['Es el más grande de Sudamérica', 'Tiene el Amazonas', 'Es famoso por el carnaval'],

    // PAISES - Medio
    'ALEMANIA': ['Tiene cerveza famosa', 'Su capital es Berlín', 'Inventó el coche'],
    'PORTUGAL': ['Está junto a España', 'Colonizó Brasil', 'Su capital es Lisboa'],
    'COLOMBIA': ['Produce mucho café', 'Su capital es Bogotá', 'Tiene costa en dos océanos'],
    'ARGENTINA': ['Tiene el tango', 'Come mucha carne', 'Messi es de ahí'],
    'VENEZUELA': ['Tiene petróleo', 'Tiene el Salto Ángel', 'Su capital es Caracas'],
    'ECUADOR': ['El ecuador pasa por ahí', 'Tiene las Galápagos', 'Su capital es Quito'],
    'URUGUAY': ['Es pequeño en Sudamérica', 'Su capital es Montevideo', 'Ganó mundiales de fútbol'],
    'PARAGUAY': ['No tiene costa', 'Está en Sudamérica', 'Su capital es Asunción'],
    'BOLIVIA': ['No tiene costa', 'Tiene el Salar de Uyuni', 'Tiene dos capitales'],
    'CANADA': ['Está al norte de USA', 'Tiene jarabe de maple', 'Tiene mucho frío'],
    'AUSTRALIA': ['Tiene canguros', 'Es un continente-isla', 'Tiene la Gran Barrera de Coral'],
    'NORUEGA': ['Tiene fiordos', 'Tiene auroras boreales', 'Está en Escandinavia'],

    // PAISES - Difícil
    'MADAGASCAR': ['Es una isla africana', 'Tiene lémures únicos', 'Hay una película animada'],
    'MOZAMBIQUE': ['Está en África', 'Fue colonia portuguesa', 'Su capital es Maputo'],
    'AZERBAIYAN': ['Está entre Europa y Asia', 'Tiene petróleo', 'Su capital es Bakú'],
    'KAZAJISTAN': ['Es muy grande en Asia Central', 'Fue parte de la URSS', 'Su capital es Astana'],
    'UZBEKISTAN': ['Está en Asia Central', 'Tiene la Ruta de la Seda', 'Su capital es Tashkent'],
    'TURKMENISTAN': ['Está en Asia Central', 'Tiene un cráter en llamas', 'Es muy desértico'],
    'BANGLADESH': ['Está junto a India', 'Tiene muchos ríos', 'Es muy poblado'],
    'AFGANISTAN': ['Está en Asia', 'Tiene montañas altas', 'Su capital es Kabul'],
    'LIECHTENSTEIN': ['Es muy pequeño', 'Está en Europa', 'Entre Suiza y Austria'],

    // COMIDA - Fácil
    'PAN': ['Se hace con harina', 'Es básico en las comidas', 'Se hornea'],
    'QUESO': ['Se hace con leche', 'Puede ser amarillo', 'Los ratones lo aman'],
    'LECHE': ['Viene de las vacas', 'Es blanca', 'Se toma en el desayuno'],
    'HUEVO': ['Lo ponen las gallinas', 'Se puede freír', 'Tiene yema y clara'],
    'ARROZ': ['Es un grano blanco', 'Se come mucho en Asia', 'Se hierve'],
    'PASTA': ['Es de origen italiano', 'Se hace con harina', 'Hay espagueti y macarrones'],
    'CARNE': ['Viene de animales', 'Tiene proteína', 'Se puede asar'],
    'POLLO': ['Es un ave de corral', 'Su carne es blanca', 'KFC lo prepara'],
    'SOPA': ['Es líquida y caliente', 'Se come con cuchara', 'Tiene verduras'],
    'PIZZA': ['Es redonda y plana', 'Tiene queso y tomate', 'Es italiana'],
    'TACO': ['Es mexicano', 'Tiene tortilla doblada', 'Puede tener carne'],
    'TORTA': ['Es un pastel', 'Se come en cumpleaños', 'Tiene crema'],
    'FRESA': ['Es roja y dulce', 'Es una fruta pequeña', 'Tiene semillas afuera'],
    'MANGO': ['Es tropical', 'Es amarillo o naranja', 'Tiene un hueso grande'],
    'LIMON': ['Es ácido', 'Es amarillo o verde', 'Se usa en limonada'],
    'NARANJA': ['Es cítrica', 'Es de color naranja', 'Se hace jugo con ella'],

    // COMIDA - Medio
    'ESPAGUETI': ['Es un tipo de pasta larga', 'Es italiano', 'Se come con salsa'],
    'HAMBURGUESA': ['Tiene carne entre panes', 'Es americana', 'McDonald\'s las vende'],
    'ENSALADA': ['Tiene muchas verduras', 'Es saludable', 'Se come fría'],
    'CHOCOLATE': ['Es dulce y café', 'Viene del cacao', 'Es delicioso'],
    'GALLETA': ['Es un dulce horneado', 'Puede tener chispas', 'Se come con leche'],
    'SANDWICH': ['Tiene pan con relleno', 'Es rápido de hacer', 'Se come con las manos'],
    'LASAGNA': ['Tiene capas de pasta', 'Es italiana', 'Tiene carne y queso'],
    'EMPANADA': ['Es masa rellena', 'Se hornea o fríe', 'Es latinoamericana'],
    'TORTILLA': ['Puede ser de maíz o harina', 'Es plana y redonda', 'Es base de tacos'],
    'GUACAMOLE': ['Es verde', 'Se hace con aguacate', 'Es mexicano'],
    'BURRITO': ['Es mexicano', 'Tiene tortilla enrollada', 'Tiene relleno'],

    // COMIDA - Difícil
    'QUESADILLA': ['Es mexicana', 'Tiene queso derretido', 'Se hace con tortilla'],
    'CHILAQUILES': ['Son mexicanos', 'Tienen tortilla frita', 'Se bañan en salsa'],
    'ENCHILADAS': ['Son mexicanas', 'Tienen tortilla enrollada', 'Están bañadas en salsa'],
    'RATATOUILLE': ['Es francesa', 'Tiene verduras', 'Hay una película de Pixar'],
    'CROISSANT': ['Es francés', 'Tiene forma de luna', 'Es de hojaldre'],
    'CARPACCIO': ['Es italiano', 'Es carne cruda en láminas', 'Se come como entrada'],
    'BRUSCHETTA': ['Es italiana', 'Es pan tostado con tomate', 'Es un aperitivo'],
    'ZANAHORIA': ['Es naranja', 'Es una raíz', 'Los conejos la comen'],
    'BERENJENA': ['Es morada', 'Es una verdura', 'Se usa en moussaka'],
    'CALABACIN': ['Es verde alargado', 'Es una verdura', 'Parece pepino pero no lo es'],
  };
}
