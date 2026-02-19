import 'dart:ui' as ui;
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
    'ca': 'Català',
  };

  LanguageProvider() {
    _loadLanguage();
  }

  // Cargar idioma guardado o detectar del dispositivo
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('language')) {
      _currentLanguage = prefs.getString('language') ?? 'es';
    } else {
      // Detectar idioma del dispositivo en la primera instalación
      final deviceLocale = ui.PlatformDispatcher.instance.locale.languageCode;
      if (availableLanguages.containsKey(deviceLocale)) {
        _currentLanguage = deviceLocale;
      } else {
        _currentLanguage = 'es'; // Fallback a español
      }
      // Guardar el idioma detectado
      await prefs.setString('language', _currentLanguage);
    }
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
