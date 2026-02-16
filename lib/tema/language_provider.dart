import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para manejar el idioma de la aplicación
class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'en'; // Idioma por defecto: inglés

  String get currentLanguage => _currentLanguage;

  // Lista de idiomas disponibles
  static const Map<String, String> availableLanguages = {
    'es': 'Español',
    'en': 'English',
    'ca': 'Català',
  };

  LanguageProvider() {
    _loadLanguage();
  }

  // Cargar idioma guardado o detectar del dispositivo
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Verificar si ya existe un idioma guardado
    if (prefs.containsKey('language')) {
      _currentLanguage = prefs.getString('language') ?? 'en';
    } else {
      // Detectar idioma del dispositivo en la primera instalación
      _currentLanguage = _detectDeviceLanguage();
      // Guardar el idioma detectado
      await prefs.setString('language', _currentLanguage);
    }
    
    notifyListeners();
  }

  /// Detecta el idioma del dispositivo y lo mapea a los idiomas disponibles
  /// Si el idioma no está disponible, devuelve inglés como idioma por defecto
  String _detectDeviceLanguage() {
    // Obtener el código de idioma del dispositivo
    final String deviceLanguageCode = WidgetsBinding.instance.window.locale.languageCode;
    
    // Verificar si el idioma del dispositivo está disponible
    if (availableLanguages.containsKey(deviceLanguageCode)) {
      return deviceLanguageCode;
    }
    
    // Si no está disponible, devolver inglés como fallback
    return 'en';
  }

  // Cambiar idioma
  Future<void> setLanguage(String languageCode) async {
    if (_currentLanguage != languageCode && availableLanguages.containsKey(languageCode)) {
      _currentLanguage = languageCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);
      notifyListeners();
    }
  }

  // Obtener nombre del idioma actual
  String get currentLanguageName => availableLanguages[_currentLanguage] ?? 'English';
}
