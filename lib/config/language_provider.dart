import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/app_logger.dart';
import '../constants/api_constants.dart';

/// Provider para manejar el idioma de la aplicación
class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'es'; // Idioma por defecto: español
  int? _currentUserId; // Usuario actual para guardar preferencia

  String get currentLanguage => _currentLanguage;

  // Lista de idiomas disponibles
  static const Map<String, String> availableLanguages = {
    'es': 'Español',
    'en': 'English',
    'ca': 'Català',
  };

  LanguageProvider() {
    _loadDefaultLanguage();
  }

  // Cargar idioma por defecto (sin usuario logueado)
  Future<void> _loadDefaultLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    // Intentar cargar idioma global como fallback
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
    }
    appLogger.setLanguage(_currentLanguage);
    notifyListeners();
  }

  /// Cargar idioma específico del usuario cuando hace login
  Future<void> loadUserLanguage(int userId) async {
    _currentUserId = userId;
    final prefs = await SharedPreferences.getInstance();
    final userKey = ApiConstants.getUserLanguageKey(userId);

    if (prefs.containsKey(userKey)) {
      _currentLanguage = prefs.getString(userKey) ?? 'es';
    } else {
      // Primera vez del usuario - usar idioma actual o detectar
      final deviceLocale = ui.PlatformDispatcher.instance.locale.languageCode;
      if (availableLanguages.containsKey(deviceLocale)) {
        _currentLanguage = deviceLocale;
      }
      // Guardar preferencia para este usuario
      await prefs.setString(userKey, _currentLanguage);
    }

    appLogger.setLanguage(_currentLanguage);
    notifyListeners();
  }

  /// Limpiar usuario actual (logout)
  void clearUser() {
    _currentUserId = null;
    // Mantener el idioma actual, no resetear
  }

  // Cambiar idioma
  Future<void> setLanguage(String languageCode) async {
    if (_currentLanguage != languageCode && availableLanguages.containsKey(languageCode)) {
      _currentLanguage = languageCode;
      final prefs = await SharedPreferences.getInstance();

      // Guardar para el usuario actual si hay uno logueado
      if (_currentUserId != null) {
        await prefs.setString(ApiConstants.getUserLanguageKey(_currentUserId!), languageCode);
      }
      // También guardar como fallback global
      await prefs.setString('language', languageCode);

      appLogger.setLanguage(languageCode, isManualChange: true);
      notifyListeners();
    }
  }

  // Obtener nombre del idioma actual
  String get currentLanguageName => availableLanguages[_currentLanguage] ?? 'Español';
}
