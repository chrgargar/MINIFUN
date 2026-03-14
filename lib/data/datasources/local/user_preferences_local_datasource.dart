import 'package:sqflite/sqflite.dart';
import '../../../core/database/local_database.dart';
import '../../../domain/entities/user_preferences_entity.dart';
import '../../../services/app_logger.dart';

/// Datasource local para preferencias de usuario (SQLite)
class UserPreferencesLocalDatasource {
  final LocalDatabase _localDb;

  UserPreferencesLocalDatasource(this._localDb);

  /// Obtener preferencias
  Future<UserPreferencesEntity?> getPreferences({int? userId}) async {
    final db = await _localDb.database;
    final results = await db.query(
      'user_preferences',
      where: userId == null ? 'user_id IS NULL' : 'user_id = ?',
      whereArgs: userId == null ? null : [userId],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return _mapToEntity(results.first);
  }

  /// Guardar preferencias
  Future<int> savePreferences(UserPreferencesEntity prefs) async {
    final db = await _localDb.database;
    final data = _entityToMap(prefs);

    final id = await db.insert(
      'user_preferences',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    appLogger.info('Preferencias guardadas para usuario ${prefs.userId}');
    return id;
  }

  /// Actualizar campo específico
  Future<void> updateField(
    String field,
    dynamic value, {
    int? userId,
  }) async {
    final db = await _localDb.database;
    final existing = await getPreferences(userId: userId);

    if (existing == null) {
      // Crear nuevo registro
      final prefs = UserPreferencesEntity.defaultFor(userId);
      final updated = _updatePreference(prefs, field, value);
      await savePreferences(updated);
      return;
    }

    await db.update(
      'user_preferences',
      {
        field: value,
        'is_synced': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: userId == null ? 'user_id IS NULL' : 'user_id = ?',
      whereArgs: userId == null ? null : [userId],
    );
  }

  /// Obtener preferencias no sincronizadas
  Future<UserPreferencesEntity?> getUnsyncedPreferences() async {
    final db = await _localDb.database;
    final results = await db.query(
      'user_preferences',
      where: 'is_synced = 0 AND user_id IS NOT NULL',
      limit: 1,
    );

    if (results.isEmpty) return null;
    return _mapToEntity(results.first);
  }

  /// Marcar como sincronizado
  Future<void> markAsSynced(int userId) async {
    final db = await _localDb.database;
    await db.update(
      'user_preferences',
      {
        'is_synced': 1,
        'last_synced_at': DateTime.now().toIso8601String(),
      },
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Eliminar preferencias
  Future<void> deletePreferences({int? userId}) async {
    final db = await _localDb.database;
    await db.delete(
      'user_preferences',
      where: userId == null ? 'user_id IS NULL' : 'user_id = ?',
      whereArgs: userId == null ? null : [userId],
    );
  }

  UserPreferencesEntity _mapToEntity(Map<String, dynamic> map) {
    return UserPreferencesEntity(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      theme: map['theme'] as String? ?? 'light',
      language: map['language'] as String? ?? 'es',
      avatar: map['avatar'] as String?,
      musicEnabled: map['music_enabled'] == 1,
      effectsEnabled: map['effects_enabled'] == 1,
      musicVolume: (map['music_volume'] as num?)?.toDouble() ?? 0.7,
      effectsVolume: (map['effects_volume'] as num?)?.toDouble() ?? 1.0,
      isSynced: map['is_synced'] == 1,
      lastSyncedAt: map['last_synced_at'] != null
          ? DateTime.parse(map['last_synced_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> _entityToMap(UserPreferencesEntity e) {
    return {
      if (e.id != null) 'id': e.id,
      'user_id': e.userId,
      'theme': e.theme,
      'language': e.language,
      'avatar': e.avatar,
      'music_enabled': e.musicEnabled ? 1 : 0,
      'effects_enabled': e.effectsEnabled ? 1 : 0,
      'music_volume': e.musicVolume,
      'effects_volume': e.effectsVolume,
      'is_synced': e.isSynced ? 1 : 0,
      'last_synced_at': e.lastSyncedAt?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  UserPreferencesEntity _updatePreference(
    UserPreferencesEntity prefs,
    String field,
    dynamic value,
  ) {
    switch (field) {
      case 'theme':
        return prefs.copyWith(theme: value as String, isSynced: false);
      case 'language':
        return prefs.copyWith(language: value as String, isSynced: false);
      case 'avatar':
        return prefs.copyWith(avatar: value as String?, isSynced: false);
      case 'music_enabled':
        return prefs.copyWith(musicEnabled: value == 1, isSynced: false);
      case 'effects_enabled':
        return prefs.copyWith(effectsEnabled: value == 1, isSynced: false);
      default:
        return prefs;
    }
  }
}
