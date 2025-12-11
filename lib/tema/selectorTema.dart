import 'package:flutter/material.dart';

// Proveedor de tema para gestionar tema claro/oscuro
class SelectorTema extends ChangeNotifier {
  // Modo de tema actual (light/dark)
  ThemeMode _themeMode = ThemeMode.light;

  // Getters para acceder al estado del tema
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Cambiar entre tema claro y oscuro
  void cambiarTema() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notificar a los widgets que escuchan
  }

  // Establecer tema específico
  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
