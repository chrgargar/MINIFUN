import 'package:flutter/material.dart';

/// Constantes de colores utilizadas en toda la aplicación
class ColoresApp {
  // Colores principales
  static const Color moradoPrincipal = Color(0xFF7B3FF2);
  static const Color moradoLogin = Color(0xFF7B68B8);
  static const Color moradoLoginOscuro = Color(0xFF5B4A8B);

  // Colores de fondo
  static const Color fondoMisionOscuro = Color(0xFF2D1B3D);
  static const Color fondoMisionClaro = Color(0xFFF3E5F5);

  // Colores de comida (Snake)
  static const Color colorComidaManzana = Colors.red;
  static const Color colorComidaFresa = Colors.pink;
  static const Color colorComidaDorada = Color.fromARGB(255, 255, 239, 98);

  // Colores básicos
  static const Color blanco = Colors.white;
  static const Color negro = Colors.black;
  static const Color transparente = Colors.transparent;

  // Colores de estado
  static const Color rojoError = Colors.red;
  static const Color verdeExito = Colors.green;
  static const Color naranjaAdvertencia = Colors.orange;
  static const Color azulInfo = Colors.blue;

  // Colores de Snake
  static const Color colorCabezaSerpiente = Color(0xFF2E7D32);
  static const Color colorCuerpoSerpiente = Color(0xFF4CAF50);
  static const Color colorObstaculo = Colors.brown;

  // Colores de Sudoku
  static const Color colorCeldaSeleccionada = Color(0xFFE3F2FD);
  static const Color colorCeldaMismoNumero = Color(0xFFFFF9C4);
  static const Color colorCeldaRelacionada = Color(0xFFF5F5F5);
  static const Color colorCeldaFija = Color(0xFFEEEEEE);
  static const Color colorCeldaError = Color(0xFFFFEBEE);
  static const Color colorBotonLapiz = Color(0xFFE8F5E9);
  static const Color colorBotonBorrador = Color(0xFFFFEBEE);

  // Colores de grises
  static Color gris100 = Colors.grey[100]!;
  static Color gris300 = Colors.grey[300]!;
  static Color gris400 = Colors.grey[400]!;
  static Color gris600 = Colors.grey[600]!;
  static Color gris800 = Colors.grey[800]!;

  // Colores de Water Sort
  static const Color colorTuboVacio = Color(0xFFE8E8E8);
  static const Color colorTuboBorde = Color(0xFFBDBDBD);
  static const Color colorTuboSeleccionado = Color(0xFF7B3FF2);
}
