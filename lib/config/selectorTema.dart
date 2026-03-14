import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

// Proveedor de tema para gestionar tema claro/oscuro
class SelectorTema extends ChangeNotifier {
  // Modo de tema actual (light/dark)
  ThemeMode _themeMode = ThemeMode.light;
  int? _currentUserId; // Usuario actual para guardar preferencia

  // Getters para acceder al estado del tema
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  SelectorTema() {
    _loadDefaultTheme();
  }

  // Cargar tema por defecto (sin usuario logueado)
  Future<void> _loadDefaultTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString('theme_mode');

    if (themeName != null) {
      _themeMode = themeName == 'dark' ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }

  /// Cargar tema específico del usuario cuando hace login
  Future<void> loadUserTheme(int userId) async {
    _currentUserId = userId;
    final prefs = await SharedPreferences.getInstance();
    final userKey = ApiConstants.getUserThemeKey(userId);

    if (prefs.containsKey(userKey)) {
      final themeName = prefs.getString(userKey);
      _themeMode = themeName == 'dark' ? ThemeMode.dark : ThemeMode.light;
    }
    // Si no tiene preferencia guardada, mantener el tema actual

    notifyListeners();
  }

  /// Limpiar usuario actual (logout)
  void clearUser() {
    _currentUserId = null;
    // Mantener el tema actual, no resetear
  }

  // Cambiar entre tema claro y oscuro
  Future<void> cambiarTema() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _saveTheme();
    notifyListeners();
  }

  // Establecer tema específico
  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    await _saveTheme();
    notifyListeners();
  }

  // Guardar tema en SharedPreferences
  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = _themeMode == ThemeMode.dark ? 'dark' : 'light';

    // Guardar para el usuario actual si hay uno logueado
    if (_currentUserId != null) {
      await prefs.setString(ApiConstants.getUserThemeKey(_currentUserId!), themeName);
    }
    // También guardar como fallback global
    await prefs.setString('theme_mode', themeName);
  }
}
