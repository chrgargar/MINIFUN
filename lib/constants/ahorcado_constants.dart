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

  // Pistas por palabra
  static const Map<String, List<String>> pistas = {
    // General - Fácil
    'GATO': ['Es un animal doméstico felino', 'Maúlla y ronronea', 'Tiene cola y orejas puntiagudas'],
    'PERRO': ['Es un animal doméstico canino', 'Ladra y es leal', 'Amigo del hombre'],
    'CASA': ['Lugar donde vives', 'Tiene puertas y ventanas', 'Refugio familiar'],
    'SOL': ['Estrella brillante del día', 'Da luz y calor', 'Astro que orbitas'],
    'LUNA': ['Satélite de la Tierra', 'Brilla en la noche', 'Influye en las mareas'],
    'AGUA': ['Líquido transparente', 'Necesario para vivir', 'Cae del cielo en forma de lluvia'],
    'FUEGO': ['Es caliente y peligroso', 'Se enciende con cerillas', 'Emite luz y calor'],
    'ARBOL': ['Ser vivo vegetal grande', 'Tiene tronco y raíces', 'Produce oxígeno'],
    'FLOR': ['Es colorida y bonita', 'Tiene pétalos', 'Se encuentra en un jardín'],
    'RIO': ['Corriente de agua dulce', 'Desemboca en el mar', 'Tiene orillas'],
    'MAR': ['Extensión grande de agua salada', 'Tiene olas', 'Hogar de peces y delfines'],
    'NIEVE': ['Es blanca y fría', 'Cae en invierno', 'Se forma en lugares altos'],
    'VIENTO': ['Aire en movimiento', 'No se ve pero se siente', 'Mueve las plantas'],
    'LLUVIA': ['Agua que cae del cielo', 'Cae en forma de gotas', 'Necesaria para las plantas'],
    'CIELO': ['Se ve sobre nuestras cabezas', 'Donde vuelan los pájaros', 'Es azul durante el día'],
    'TIERRA': ['Planeta donde vivimos', 'Tiene continentes y océanos', 'Es redonda'],
    'MESA': ['Mueble para comer', 'Tiene patas y superficie plana', 'Te sientas cerca de ella'],
    'SILLA': ['Mueble para sentarse', 'Tiene respaldo', 'Se usa en la mesa'],
    'LIBRO': ['Objeto con páginas', 'Contiene historias', 'Se lee'],
    'LAPIZ': ['Utensilio de escritura', 'Tiene punta de grafito', 'Se usa en la escuela'],
    'PAPEL': ['Material blanco y delgado', 'Sirve para escribir', 'Se hace de pulpa de madera'],
    'RELOJ': ['Instrumento que mide el tiempo', 'Tiene manecillas', 'Cuelga en la pared'],
    'PUERTA': ['Entrada y salida', 'Tiene bisagras', 'Se abre y se cierra'],
    'CAMA': ['Mueble para dormir', 'Tiene colchón', 'Está en la habitación'],

    // General - Medio
    'ELEFANTE': ['Animal más grande de continente africano', 'Tiene una trompa larga', 'Es gris'],
    'MARIPOSA': ['Insecto con alas coloridas', 'Son muy bonitas', 'Salen en primavera'],
    'TELEFONO': ['Aparato de comunicación', 'Tiene botones', 'Te permite hablar con otros'],
    'BICICLETA': ['Vehículo de dos ruedas', 'Tiene pedales', 'No necesita gasolina'],
    'ESCUELA': ['Lugar donde estudian los niños', 'Tiene aulas', 'Vas allí para aprender'],
    'VENTANA': ['Abertura en la pared', 'Tiene vidrios', 'Dejas entrar luz'],
    'COMPUTADORA': ['Máquina electrónica', 'Tiene teclado y mouse', 'Sirve para muchas cosas'],
    'BIBLIOTECA': ['Lugar con muchos libros', 'Es un lugar tranquilo', 'Aquí estudian muchos'],
    'HOSPITAL': ['Lugar donde se cura gente enferma', 'Trabajan doctores', 'Hay enfermeras'],
    'MERCADO': ['Lugar donde compras cosas', 'Venden frutas y verduras', 'Hay muchos vendedores'],
    'TELEVISION': ['Aparato para ver películas', 'Tiene una pantalla', 'Transmite programas'],
    'REFRIGERADOR': ['Electrodoméstico para conservar comida', 'Mantiene frío', 'Está en la cocina'],
    'LAVADORA': ['Máquina para lavar ropa', 'Tiene un tambor rotativo', 'Usa agua y detergente'],
    'IMPRESORA': ['Máquina que imprime documentos', 'Se conecta a una computadora', 'Usa tinta'],
    'CALENDARIO': ['Objeto que muestra los días', 'Ayuda a planificar', 'Cambia cada año'],
    'ESCRITORIO': ['Mueble de trabajo', 'Tiene cajones', 'Aquí trabajas o estudias'],

    // General - Difícil
    'ELECTRICIDAD': ['Forma de energía', 'Enciende las luces', 'Peligrosa si tocas cables'],
    'UNIVERSIDAD': ['Institución de educación superior', 'Tiene facultades', 'Aquí estudian adultos'],
    'TECNOLOGIA': ['Aplicación de ciencia', 'Crea aparatos modernos', 'Cambia constantemente'],
    'PROGRAMACION': ['Arte de crear programas', 'Se usa en computadoras', 'Requiere lógica'],
    'COMUNICACION': ['Acto de transmitir información', 'Es fundamental', 'Necesita emisor y receptor'],
    'INVESTIGACION': ['Búsqueda de conocimiento', 'Se hace en laboratorios', 'Busca descubrimientos'],
    'ARQUITECTURA': ['Diseño de edificios', 'Necesita matemáticas', 'Crea estructuras'],
    'MATEMATICAS': ['Ciencia de números', 'Requiere cálculos', 'Es exacta'],
    'EXTRAORDINARIO': ['Muy especial y raro', 'Fuera de lo común', 'Sorprende'],
    'ADMINISTRACION': ['Gestión de recursos', 'Organiza funciones', 'Dirige negocios'],
    'RESPONSABILIDAD': ['Deber u obligación', 'Característica importante', 'Muestra madurez'],
    'CONOCIMIENTO': ['Saber y entender cosas', 'Se adquiere con estudio', 'Es poder'],

    // Animales - Fácil
    'PATO': ['Ave acuática', 'Vive en lagunas', 'Tiene alas'],
    'RANA': ['Anfibio pequeño', 'Vive en el agua y tierra', 'Salta'],
    'LEON': ['Animal felino cazador', 'Rey de la selva', 'Tiene melena'],
    'TIGRE': ['Felino con rayas', 'Es muy peligroso', 'Vive en Asia'],
    'OSO': ['Mamífero grande', 'Tiene garras', 'Hiberna en invierno'],
    'LOBO': ['Canino salvaje', 'Vive en manadas', 'Aúlla en la noche'],
    'RATA': ['Roedor pequeño', 'Tiene cola larga', 'Es considerada plaga'],
    'PAVO': ['Ave grande doméstica', 'Tiene plumas coloridas', 'Se cría para carne'],
    'LORO': ['Ave con colores llamativos', 'Puede hablar', 'Come semillas'],
    'BUHO': ['Ave nocturna cazadora', 'Tiene ojos grandes', 'Vive en bosques'],
    'PUMA': ['Felino de América', 'Es ágil', 'Salta muy alto'],
    'ZORRO': ['Canino astuto', 'Tiene cola esponjosa', 'Es muy inteligente'],
    'CIERVO': ['Mamífero con astas', 'Corre rápido', 'Es herbívoro'],
    'CONEJO': ['Mamífero pequeño', 'Tiene orejas largas', 'Salta mucho'],

    // Animales - Medio
    'JIRAFA': ['Animal africano muy alto', 'Tiene un cuello largo', 'Come hojas altas'],
    'CEBRA': ['Animal africano con rayas', 'Parece un caballo', 'Vive en manadas'],
    'COCODRILO': ['Reptil acuático peligroso', 'Tiene muchos dientes', 'Vive en ríos'],
    'HIPOPOTAMO': ['Animal enorme de agua dulce', 'Come plantas', 'Africano'],
    'RINOCERONTE': ['Mamífero con cuerno', 'Es muy grande', 'Africano'],
    'GORILA': ['Primate muy fuerte', 'Come frutas', 'Africano'],
    'CHIMPANCE': ['Primate inteligente', 'Es parecido al humano', 'Come frutas'],
    'DELFIN': ['Mamífero marino inteligente', 'Vive en océanos', 'Juguetón y amistoso'],
    'BALLENA': ['Mamífero marino más grande', 'Muy grande', 'Come krill'],
    'TIBURON': ['Pez depredador marino', 'Tiene aletas', 'Peligroso'],
    'TORTUGA': ['Reptil con caparazón', 'Vive mucho tiempo', 'Es lenta'],
    'SERPIENTE': ['Reptil sin patas', 'Algunos son venenosos', 'Reptil alargado'],
    'LAGARTO': ['Reptil pequeño', 'Tiene cola', 'Come insectos'],
    'CANGREJO': ['Crustáceo con pinzas', 'Vive en el mar', 'Camina de lado'],
    'PULPO': ['Cefalópodo marino', 'Tiene ocho brazos', 'Es inteligente'],

    // Animales - Difícil
    'ORANGUTAN': ['Primate asiático', 'Vive en selvas', 'Muy inteligente'],
    'MURCIELAGO': ['Mamífero volador nocturno', 'Usa ecolocalización', 'Come insectos'],
    'ORNITORRINCO': ['Mamífero australiano extraño', 'Pone huevos', 'Tiene pico de pato'],
    'SALAMANDRA': ['Anfibio pequeño', 'Tiene cola larga', 'Vive en lugares húmedos'],
    'ARMADILLO': ['Mamífero con caparazón', 'Vive en América', 'Se enrolla'],
    'PEREZOSO': ['Mamífero lento', 'Se cuelga de árboles', 'Vive en selvas'],
    'PUERCOESPIN': ['Mamífero con púas', 'Es pequeño', 'Se defiende con espinas'],
    'CAMALEON': ['Reptil que cambia color', 'Tiene lengua larga', 'Ojos independientes'],
    'MANTARRAYA': ['Pez marino plano', 'Parece un fantasma', 'Vive en océanos'],
    'ESCORPION': ['Aracnido con cola venenosa', 'Tiene pinzas', 'Peligroso'],

    // Países - Fácil
    'PERU': ['País en Sudamérica', 'Capital es Lima', 'Tiene los Andes'],
    'CUBA': ['Isla del Caribe', 'Capital es La Habana', 'Muy hermosa'],
    'CHILE': ['País alargado de Sudamérica', 'Tiene frontera con Argentina', 'Produce vino'],
    'CHINA': ['País asiático más poblado', 'Construyó la Gran Muralla', 'Muy desarrollado'],
    'INDIA': ['País asiático', 'Tiene Taj Mahal', 'Muy poblada'],
    'JAPON': ['País asiático del este', 'Capital es Tokio', 'Antiguas tradiciones'],
    'COREA': ['País de Asia', 'Dividido en dos partes', 'K-pop famoso'],
    'RUSIA': ['País más grande del mundo', 'Capital es Moscú', 'Tiene Siberia'],
    'ITALIA': ['País europeo', 'Capital es Roma', 'Famosa por la pasta'],
    'FRANCIA': ['País europeo', 'Capital es París', 'Conocida por vinos'],
    'ESPANA': ['País europeo', 'Capital es Madrid', 'Conocida por flamenco'],
    'GRECIA': ['País europeo', 'Capital es Atenas', 'Cuna de la democracia'],
    'EGIPTO': ['País africano', 'Tiene las pirámides', 'Nilo atraviesa'],
    'MEXICO': ['País de América del Norte', 'Capital es Ciudad de México', 'Famoso por pirámides aztecas'],
    'BRASIL': ['País más grande de Sudamérica', 'Tiene la selva amazónica', 'Capital es Brasilia'],

    // Países - Medio
    'ALEMANIA': ['País europeo', 'Capital es Berlín', 'Famosa por cerveza'],
    'PORTUGAL': ['País europeo', 'Capital es Lisboa', 'En la Península Ibérica'],
    'COLOMBIA': ['País en Sudamérica', 'Capital es Bogotá', 'Famosa por café'],
    'ARGENTINA': ['País en Sudamérica', 'Capital es Buenos Aires', 'Famosa por tango'],
    'VENEZUELA': ['País en Sudamérica', 'Capital es Caracas', 'Tiene oro negro'],
    'ECUADOR': ['País en Sudamérica', 'En el ecuador terrestre', 'Tiene Galápagos'],
    'URUGUAY': ['País pequeño de Sudamérica', 'Capital es Montevideo', 'Muy tranquilo'],
    'PARAGUAY': ['País sin litoral', 'Capital es Asunción', 'En Sudamérica'],
    'BOLIVIA': ['País andino', 'Capital es La Paz', 'Tierra de minerales'],
    'CANADA': ['País de América del Norte', 'Capital es Ottawa', 'Muy grande'],
    'AUSTRALIA': ['País isla', 'Capital es Canberra', 'Tiene canguros'],
    'NORUEGA': ['País escandinavo', 'Capital es Oslo', 'Famosa por fiordos'],

    // Países - Difícil
    'MADAGASCAR': ['Isla africana grande', 'Capital es Antananarivo', 'Única en biodiversidad'],
    'MOZAMBIQUE': ['País africano', 'Capital es Maputo', 'En la costa este'],
    'AZERBAIYAN': ['País de Asia menor', 'Capital es Bakú', 'Tierra de fuego'],
    'KAZAJISTAN': ['País asiático grande', 'Capital es Astaná', 'Tierra de estepa'],
    'UZBEKISTAN': ['País de Asia central', 'Capital es Taskent', 'Ruta de la seda'],
    'TURKMENISTAN': ['País de Asia central', 'Capital es Asjabad', 'Gas natural'],
    'BANGLADESH': ['País asiático densamente poblado', 'Capital es Daca', 'Delta del Ganges'],
    'AFGANISTAN': ['País de Asia central', 'Capital es Kabul', 'Montañoso'],
    'LIECHTENSTEIN': ['País europeo pequeño', 'Capital es Vaduz', 'Entre Suiza y Austria'],

    // Comida - Fácil
    'PAN': ['Alimento hecho con harina', 'Se come en el desayuno', 'Es blanco o integral'],
    'QUESO': ['Producto lácteo', 'Se hace con leche', 'Tiene muchas variedades'],
    'LECHE': ['Líquido nutritivo', 'Viene de animales', 'Color blanco'],
    'HUEVO': ['Alimento proteínico', 'Lo pone la gallina', 'Tiene cáscara'],
    'ARROZ': ['Cereal blanco', 'Es popular en Asia', 'Grano pequeño'],
    'PASTA': ['Alimento hecho con trigo', 'Italiana', 'Hay muchas formas'],
    'CARNE': ['Alimento proteído', 'Viene de los animales', 'Roja o blanca'],
    'POLLO': ['Ave domesticada', 'Carne blanca', 'Muy sabroso'],
    'SOPA': ['Caldo con ingredientes', 'Se come caliente', 'Reconfortante'],
    'PIZZA': ['Alimento italiano', 'Tiene queso y salsa', 'Circular'],
    'TACO': ['Comida mexicana', 'Tiene tortilla', 'Relleno diverso'],
    'TORTA': ['Pastel dulce', 'Se celebra en cumpleaños', 'Tiene capas'],
    'FRESA': ['Fruta roja pequeña', 'Dulce y ácida', 'Tiene semillas'],
    'MANGO': ['Fruta tropical', 'Rey de las frutas', 'Naranja o amarilla'],
    'LIMON': ['Fruta cítrica', 'Ácido', 'Amarillo'],
    'NARANJA': ['Fruta cítrica redonda', 'Color del mismo nombre', 'Vitamina C'],

    // Comida - Medio
    'ESPAGUETI': ['Pasta larga y delgada', 'Italiana', 'Se acompaña con salsa'],
    'HAMBURGUESA': ['Sándwich de carne', 'Americana popular', 'Tiene pan redondo'],
    'ENSALADA': ['Plato vegetal frío', 'Saludable', 'Lleva lechuga'],
    'CHOCOLATE': ['Alimento dulce', 'Hecho del cacao', 'Se come en bloques'],
    'GALLETA': ['Alimento crocante', 'Dulce muy popular', 'Se come con café'],
    'SANDWICH': ['Alimento entre dos panes', 'Rápido de hacer', 'Tiene relleno'],
    'LASAGNA': ['Pasta en capas', 'Italiana', 'Requiere horno'],
    'EMPANADA': ['Pastel relleno', 'Latinoamericana', 'Se fríe'],
    'TORTILLA': ['Pan plano mexicano', 'Maíz o trigo', 'Se usa para envolver'],
    'GUACAMOLE': ['Pasta de aguacate', 'Mexicana', 'Verde'],
    'BURRITO': ['Tortilla rellena', 'Mexicana', 'Enrollado'],

    // Comida - Difícil
    'QUESADILLA': ['Tortilla con queso', 'Mexicana', 'Se puede rellenar'],
    'CHILAQUILES': ['Platillo mexicano', 'Con tortillas de maíz', 'Se sirve caliente'],
    'ENCHILADAS': ['Tortilla rellena y cubierta', 'Mexicana', 'Con salsa picante'],
    'RATATOUILLE': ['Guiso de vegetales', 'Francesa', 'Provenzal'],
    'CROISSANT': ['Pan en forma de medialuna', 'Francés', 'Hojaldrado'],
    'CARPACCIO': ['Carne o pescado crudo', 'Italiana', 'En rodajas finas'],
    'BRUSCHETTA': ['Pan tostado con tomate', 'Italiana', 'Aperitivo'],
    'ZANAHORIA': ['Verdura naranja', 'Vegetación subterránea', 'Rico en vitamina A'],
    'BERENJENA': ['Verdura morada', 'Se come guisada', 'Mediterránea'],
    'CALABACIN': ['Verdura alargada verde', 'Se come cocida', 'Similar al pepino'],
  };

  // Número de pistas según dificultad
  static const Map<String, int> pistasPorDificultad = {
    'facil': 3,
    'medio': 2,
    'dificil': 1
  };
}
