import '../entities/user_preferences_entity.dart';

/// Interfaz del repositorio de preferencias de usuario
abstract class UserPreferencesRepository {
  /// Obtener preferencias del usuario
  Future<UserPreferencesEntity> getPreferences({int? userId});

  /// Guardar preferencias
  Future<void> savePreferences(UserPreferencesEntity preferences);

  /// Actualizar tema
  Future<void> updateTheme(String theme, {int? userId});

  /// Actualizar idioma
  Future<void> updateLanguage(String language, {int? userId});

  /// Actualizar avatar
  Future<void> updateAvatar(String? avatar, {int? userId});

  /// Actualizar configuración de audio
  Future<void> updateAudioSettings({
    int? userId,
    bool? musicEnabled,
    bool? effectsEnabled,
    double? musicVolume,
    double? effectsVolume,
  });

  /// Obtener preferencias pendientes de sincronizar
  Future<UserPreferencesEntity?> getUnsyncedPreferences();

  /// Sincronizar con el servidor
  Future<void> syncWithServer(String token, int userId);

  /// Cargar preferencias del servidor
  Future<UserPreferencesEntity?> loadFromServer(String token, int userId);

  /// Limpiar preferencias (logout)
  Future<void> clearPreferences({int? userId});
}
