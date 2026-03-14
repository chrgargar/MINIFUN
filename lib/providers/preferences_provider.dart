import 'package:flutter/material.dart';
import '../core/di/service_locator.dart';
import '../core/sync/sync_service.dart';
import '../domain/entities/user_preferences_entity.dart';
import '../domain/repositories/user_preferences_repository.dart';
import '../services/app_logger.dart';

/// Provider unificado para preferencias de usuario
/// Combina tema, idioma, avatar y audio en un solo provider
class PreferencesProvider extends ChangeNotifier {
  final UserPreferencesRepository _repository;
  final SyncService _syncService;

  UserPreferencesEntity _preferences = const UserPreferencesEntity();
  int? _currentUserId;
  bool _isGuest = true;
  bool _isLoading = false;

  PreferencesProvider()
      : _repository = sl.preferencesRepository,
        _syncService = sl.syncService {
    _loadDefaultPreferences();
  }

  // Getters
  UserPreferencesEntity get preferences => _preferences;
  bool get isLoading => _isLoading;
  bool get isGuest => _isGuest;

  // Tema
  ThemeMode get themeMode =>
      _preferences.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  bool get isDarkMode => _preferences.isDarkMode;

  // Idioma
  String get currentLanguage => _preferences.language;

  // Avatar
  String? get avatar => _preferences.avatar;

  // Audio
  bool get musicEnabled => _preferences.musicEnabled;
  bool get effectsEnabled => _preferences.effectsEnabled;
  double get musicVolume => _preferences.musicVolume;
  double get effectsVolume => _preferences.effectsVolume;

  /// Cargar preferencias por defecto (invitado o sin sesión)
  Future<void> _loadDefaultPreferences() async {
    _preferences = await _repository.getPreferences();
    notifyListeners();
  }

  /// Configurar usuario y cargar sus preferencias
  Future<void> setUser(int userId, {String? token}) async {
    _isLoading = true;
    _currentUserId = userId;
    _isGuest = false;
    notifyListeners();

    try {
      // Cargar preferencias del usuario
      _preferences = await _repository.getPreferences(userId: userId);

      // Si tiene token, intentar cargar del servidor
      if (token != null) {
        final serverPrefs = await _repository.loadFromServer(token, userId);
        if (serverPrefs != null) {
          _preferences = serverPrefs;
        }
      }
    } catch (e) {
      appLogger.error('Error cargando preferencias de usuario', e);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Limpiar usuario (logout)
  void clearUser() {
    _currentUserId = null;
    _isGuest = true;
    _loadDefaultPreferences();
  }

  /// Cambiar tema
  Future<void> setTheme(ThemeMode mode) async {
    final theme = mode == ThemeMode.dark ? 'dark' : 'light';
    await _repository.updateTheme(
      theme,
      userId: _isGuest ? null : _currentUserId,
    );

    _preferences = _preferences.copyWith(theme: theme, isSynced: false);
    _markPendingSync();
    notifyListeners();
  }

  /// Alternar tema
  Future<void> toggleTheme() async {
    final newMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setTheme(newMode);
  }

  /// Cambiar idioma
  Future<void> setLanguage(String language) async {
    if (language == _preferences.language) return;

    await _repository.updateLanguage(
      language,
      userId: _isGuest ? null : _currentUserId,
    );

    _preferences = _preferences.copyWith(language: language, isSynced: false);
    _markPendingSync();
    notifyListeners();
    appLogger.info('Idioma cambiado a $language');
  }

  /// Cambiar avatar
  Future<void> setAvatar(String? avatarPath) async {
    await _repository.updateAvatar(
      avatarPath,
      userId: _isGuest ? null : _currentUserId,
    );

    _preferences = _preferences.copyWith(avatar: avatarPath, isSynced: false);
    _markPendingSync();
    notifyListeners();
  }

  /// Actualizar configuración de audio
  Future<void> updateAudio({
    bool? musicEnabled,
    bool? effectsEnabled,
    double? musicVolume,
    double? effectsVolume,
  }) async {
    await _repository.updateAudioSettings(
      userId: _isGuest ? null : _currentUserId,
      musicEnabled: musicEnabled,
      effectsEnabled: effectsEnabled,
      musicVolume: musicVolume,
      effectsVolume: effectsVolume,
    );

    _preferences = _preferences.copyWith(
      musicEnabled: musicEnabled ?? _preferences.musicEnabled,
      effectsEnabled: effectsEnabled ?? _preferences.effectsEnabled,
      musicVolume: musicVolume ?? _preferences.musicVolume,
      effectsVolume: effectsVolume ?? _preferences.effectsVolume,
      isSynced: false,
    );

    _markPendingSync();
    notifyListeners();
  }

  void _markPendingSync() {
    if (!_isGuest) {
      _syncService.markPendingChanges();
    }
  }

  /// Forzar sincronización
  Future<void> forceSync() async {
    if (_isGuest || _currentUserId == null) return;
    await _syncService.syncPreferences();
    notifyListeners();
  }
}
