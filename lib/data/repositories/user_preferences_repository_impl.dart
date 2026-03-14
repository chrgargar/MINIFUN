import '../../core/network/connectivity_service.dart';
import '../../domain/entities/user_preferences_entity.dart';
import '../../domain/repositories/user_preferences_repository.dart';
import '../../services/app_logger.dart';
import '../datasources/local/user_preferences_local_datasource.dart';
import '../datasources/remote/user_preferences_remote_datasource.dart';

/// Implementación del repositorio de preferencias
/// Patrón Offline-First: local primero, sync en background
class UserPreferencesRepositoryImpl implements UserPreferencesRepository {
  final UserPreferencesLocalDatasource _localDs;
  final UserPreferencesRemoteDatasource _remoteDs;
  final ConnectivityService _connectivity;

  UserPreferencesRepositoryImpl(
    this._localDs,
    this._remoteDs,
    this._connectivity,
  );

  @override
  Future<UserPreferencesEntity> getPreferences({int? userId}) async {
    final prefs = await _localDs.getPreferences(userId: userId);
    return prefs ?? UserPreferencesEntity.defaultFor(userId);
  }

  @override
  Future<void> savePreferences(UserPreferencesEntity preferences) async {
    await _localDs.savePreferences(preferences);
  }

  @override
  Future<void> updateTheme(String theme, {int? userId}) async {
    await _localDs.updateField('theme', theme, userId: userId);
  }

  @override
  Future<void> updateLanguage(String language, {int? userId}) async {
    await _localDs.updateField('language', language, userId: userId);
  }

  @override
  Future<void> updateAvatar(String? avatar, {int? userId}) async {
    await _localDs.updateField('avatar', avatar, userId: userId);
  }

  @override
  Future<void> updateAudioSettings({
    int? userId,
    bool? musicEnabled,
    bool? effectsEnabled,
    double? musicVolume,
    double? effectsVolume,
  }) async {
    if (musicEnabled != null) {
      await _localDs.updateField(
        'music_enabled',
        musicEnabled ? 1 : 0,
        userId: userId,
      );
    }
    if (effectsEnabled != null) {
      await _localDs.updateField(
        'effects_enabled',
        effectsEnabled ? 1 : 0,
        userId: userId,
      );
    }
    if (musicVolume != null) {
      await _localDs.updateField('music_volume', musicVolume, userId: userId);
    }
    if (effectsVolume != null) {
      await _localDs.updateField(
        'effects_volume',
        effectsVolume,
        userId: userId,
      );
    }
  }

  @override
  Future<UserPreferencesEntity?> getUnsyncedPreferences() async {
    return await _localDs.getUnsyncedPreferences();
  }

  @override
  Future<void> syncWithServer(String token, int userId) async {
    if (!await _connectivity.hasConnection()) {
      appLogger.info('Sin conexión - sincronización pospuesta');
      return;
    }

    // 1. Subir preferencias locales no sincronizadas
    final localPrefs = await _localDs.getPreferences(userId: userId);
    if (localPrefs != null && !localPrefs.isSynced) {
      final success = await _remoteDs.savePreferences(localPrefs, token);
      if (success) {
        await _localDs.markAsSynced(userId);
      }
    }

    // 2. Descargar preferencias del servidor
    final serverPrefs = await _remoteDs.getPreferences(token, userId);
    if (serverPrefs != null && localPrefs == null) {
      await _localDs.savePreferences(serverPrefs);
    }

    appLogger.info('Sincronización de preferencias completada');
  }

  @override
  Future<UserPreferencesEntity?> loadFromServer(
    String token,
    int userId,
  ) async {
    if (!await _connectivity.hasConnection()) return null;

    final serverPrefs = await _remoteDs.getPreferences(token, userId);
    if (serverPrefs != null) {
      await _localDs.savePreferences(serverPrefs);
      return serverPrefs;
    }
    return null;
  }

  @override
  Future<void> clearPreferences({int? userId}) async {
    await _localDs.deletePreferences(userId: userId);
  }
}
