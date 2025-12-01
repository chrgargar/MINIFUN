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

  // Puedes agregar más guías para otros juegos aquí
  // Por ejemplo:
  /*
  static const watersortObjetivo = '...';
  static const watersortInstrucciones = [...];
  static const watersortControles = [...];
  */
}
