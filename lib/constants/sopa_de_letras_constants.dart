/// Constantes para el juego Sopa de Letras
class ConstantesSopaDeLetras {
  // Constantes del tablero
  static const int tamanoTableroFacil = 10; // TamaÃ±o del tablero fÃ¡cil (10x10)
  static const int tamanoTableroMedio = 12; // TamaÃ±o del tablero medio (12x12)
  static const int tamanoTableroDificil = 15; // TamaÃ±o del tablero difÃ­cil (15x15)

  // Constantes de dificultad (nÃºmero de palabras)
  static const int numPalabrasFacil = 5; // FÃ¡cil: 5 palabras
  static const int numPalabrasMedio = 8; // Medio: 8 palabras
  static const int numPalabrasDificil = 12; // DifÃ­cil: 12 palabras

  // Constantes de tiempo contrarreloj (en segundos)
  static const int duracionContrarreloj = 300; // 5 minutos para modo contrarreloj

  // Direcciones posibles para colocar palabras
  static const List<List<int>> direcciones = [
    [0, 1],   // Horizontal derecha
    [1, 0],   // Vertical abajo
    [1, 1],   // Diagonal abajo-derecha
    [0, -1],  // Horizontal izquierda
    [-1, 0],  // Vertical arriba
    [-1, -1], // Diagonal arriba-izquierda
    [1, -1],  // Diagonal abajo-izquierda
    [-1, 1],  // Diagonal arriba-derecha
  ];

  // Lista de palabras por dificultad (en espaÃ±ol)
  static const List<String> palabrasFacil = [
    'GATO',
    'PERRO',
    'CASA',
    'SOL',
    'LUNA',
    'AGUA',
    'FUEGO',
    'TIERRA',
    'AIRE',
    'FLOR',
    'ARBOL',
    'MANO',
    'PIE',
    'OJO',
    'BOCA',
  ];

  static const List<String> palabrasMedio = [
    'ELEFANTE',
    'MARIPOSA',
    'COMPUTADORA',
    'TELEFONO',
    'BICICLETA',
    'HELADERIA',
    'ESCUELA',
    'BIBLIOTECA',
    'HOSPITAL',
    'RESTAURANTE',
    'SUPERMERCADO',
    'ESTADIO',
    'TEATRO',
    'MUSEO',
    'PARQUE',
  ];

  static const List<String> palabrasDificil = [
    'ELECTRICIDAD',
    'REVOLUCION',
    'UNIVERSIDAD',
    'CONSTITUCION',
    'TECNOLOGIA',
    'ARQUITECTURA',
    'FILOSOFIA',
    'MATEMATICAS',
    'QUIMICA',
    'FISICA',
    'BIOLOGIA',
    'GEOGRAFIA',
    'HISTORIA',
    'LITERATURA',
    'MUSICA',
  ];

  // Constantes de puntuaciÃ³n
  static const int puntosPorPalabra = 100; // Puntos por palabra encontrada
  static const int penalizacionPista = 50; // PenalizaciÃ³n por usar pista
  static const int bonusTiempoRapido = 50; // Bonus por completar rÃ¡pido

  // Constantes de validaciÃ³n
  static const String letrasValidas = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
}
