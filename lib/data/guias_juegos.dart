import '../widgets/guia_juego_dialog.dart';

/// Contiene todas las guías de los juegos
class GuiasJuegos {
  // Guía para Snake
  static const snakeObjetivo =
      'Controla la serpiente para comer manzanas y crecer lo máximo posible sin chocar con las paredes o contigo mismo.';

  static const snakeInstrucciones = [
    'La serpiente se mueve constantemente en la dirección seleccionada',
    'Cada manzana que comas hará crecer tu serpiente',
    'Tu puntuación aumenta con cada manzana consumida',
    'El juego termina si chocas con las paredes o con tu propio cuerpo',
    'Intenta conseguir la puntuación más alta posible',
  ];

  static const snakeControles = [
    ControlItem(
      icon: '⬆️',
      name: 'Arriba',
      description: 'Desliza hacia arriba o presiona el botón arriba del joystick',
    ),
    ControlItem(
      icon: '⬇️',
      name: 'Abajo',
      description: 'Desliza hacia abajo o presiona el botón abajo del joystick',
    ),
    ControlItem(
      icon: '⬅️',
      name: 'Izquierda',
      description: 'Desliza hacia la izquierda o presiona el botón izquierda',
    ),
    ControlItem(
      icon: '➡️',
      name: 'Derecha',
      description: 'Desliza hacia la derecha o presiona el botón derecha',
    ),
    ControlItem(
      icon: '🎮',
      name: 'Joystick Virtual',
      description: 'Usa el D-Pad en la esquina inferior derecha',
    ),
  ];

  // Guía para Sudoku
  static const sudokuObjetivo =
      'Completa el tablero 9x9 con números del 1 al 9, sin repetir en filas, columnas o subcuadrículas de 3x3.';

  static const sudokuInstrucciones = [
    'Cada fila debe contener los números del 1 al 9 sin repetir',
    'Cada columna debe contener los números del 1 al 9 sin repetir',
    'Cada subcuadrícula de 3x3 debe contener los números del 1 al 9 sin repetir',
    'Los números negros son fijos y no se pueden modificar',
    'Los números morados son los que tú colocas',
    'Usa el modo "Lápiz" para colocar números que serán validados',
    'Usa el modo "Notas" para escribir números candidatos sin penalización',
    'Si colocas un número incorrecto en modo lápiz, se marcará en rojo',
    'Usa el botón "Pista" si necesitas ayuda (no disponible en modo perfecto)',
  ];

  static const sudokuControles = [
    ControlItem(
      icon: '👆',
      name: 'Seleccionar celda',
      description: 'Toca una celda vacía para seleccionarla',
    ),
    ControlItem(
      icon: '✏️',
      name: 'Lápiz',
      description: 'Coloca números definitivos que serán validados',
    ),
    ControlItem(
      icon: '📝',
      name: 'Notas',
      description: 'Escribe notas/candidatos sin penalización ni validación',
    ),
    ControlItem(
      icon: '1️⃣',
      name: 'Colocar número',
      description: 'Toca un número del 1-9 para colocarlo según el modo activo',
    ),
    ControlItem(
      icon: '🔙',
      name: 'Borrar',
      description: 'Borra el número y las notas de la celda seleccionada',
    ),
    ControlItem(
      icon: '💡',
      name: 'Pista',
      description: 'Revela el número correcto de una celda vacía',
    ),
  ];

  // Guía para Water Sort
  static const waterSortObjetivo =
      'Ordena el agua de colores en los tubos hasta que cada tubo contenga un solo color.';

  static const waterSortInstrucciones = [
    'Toca un tubo para seleccionarlo',
    'Toca otro tubo para verter el agua del primero al segundo',
    'Solo puedes verter agua del mismo color sobre agua del mismo color',
    'También puedes verter en tubos vacíos',
    'Cada tubo tiene capacidad para 4 segmentos de agua',
    'Completa el nivel cuando cada tubo tenga un solo color',
    'Usa el botón "Deshacer" si te equivocas',
  ];

  static const waterSortControles = [
    ControlItem(
      icon: '👆',
      name: 'Seleccionar',
      description: 'Toca un tubo con agua para seleccionarlo',
    ),
    ControlItem(
      icon: '💧',
      name: 'Verter',
      description: 'Toca otro tubo para verter el agua seleccionada',
    ),
    ControlItem(
      icon: '↩️',
      name: 'Deshacer',
      description: 'Deshace el último movimiento realizado',
    ),
    ControlItem(
      icon: '🔄',
      name: 'Reiniciar',
      description: 'Reinicia el nivel desde el principio',
    ),
  ];
}
