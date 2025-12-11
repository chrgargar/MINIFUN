import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para manejar el idioma de la aplicación
class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'es'; // Idioma por defecto: español

  String get currentLanguage => _currentLanguage;

  // Lista de idiomas disponibles
  static const Map<String, String> availableLanguages = {
    'es': 'Español',
    'en': 'English',
    'fr': 'Français',
    'pt': 'Português',
  };

  LanguageProvider() {
    _loadLanguage();
  }

  // Cargar idioma guardado
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? 'es';
    notifyListeners();
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
  String get currentLanguageName => availableLanguages[_currentLanguage] ?? 'Español';
}
