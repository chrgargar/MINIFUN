import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../database/local_database.dart';
import '../../services/app_logger.dart';

/// Servicio para migrar datos de SharedPreferences a SQLite
/// Se ejecuta una sola vez durante la actualización de la app
class DataMigrationService {
  static const String _migrationKey = 'data_migration_v1_completed';

  /// Ejecutar migración si es necesaria
  static Future<void> runMigrationIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool(_migrationKey) == true) {
      appLogger.info('Migración ya completada previamente');
      return;
    }

    appLogger.info('Iniciando migración de datos a SQLite...');

    try {
      await _migrateGameProgress(prefs);
      await prefs.setBool(_migrationKey, true);
      appLogger.info('Migración completada exitosamente');
    } catch (e) {
      appLogger.error('Error durante la migración', e);
      // No marcar como completada para reintentar
    }
  }

  /// Migrar progreso de juegos desde SharedPreferences
  static Future<void> _migrateGameProgress(SharedPreferences prefs) async {
    final db = await LocalDatabase.instance.database;
    final gameTypes = [
      'snake',
      'sudoku',
      'buscaminas',
      'sopa_de_letras',
      'ahorcado',
      'water_sort',
    ];

    for (final gameType in gameTypes) {
      final key = 'game_progress_$gameType';
      final json = prefs.getString(key);

      if (json == null) continue;

      try {
        final data = jsonDecode(json) as Map<String, dynamic>;
        final now = DateTime.now().toIso8601String();

        await db.insert('game_progress', {
          'user_id': null, // Invitado
          'game_type': gameType,
          'current_level': data['currentLevel'] ?? 1,
          'highest_level': data['highestLevel'] ?? 1,
          'total_games_played': data['totalGamesPlayed'] ?? 0,
          'last_played_at': data['lastPlayedAt'] ?? now,
          'custom_data': data['customData'] != null
              ? jsonEncode(data['customData'])
              : null,
          'is_synced': 0,
          'last_synced_at': null,
          'created_at': now,
          'updated_at': now,
        });

        appLogger.info('Migrado progreso de $gameType');
      } catch (e) {
        appLogger.warning('Error migrando $gameType: $e');
      }
    }
  }

  /// Migrar preferencias de usuario (tema, idioma)
  static Future<void> migrateUserPreferences(
    SharedPreferences prefs,
    int userId,
  ) async {
    final db = await LocalDatabase.instance.database;

    try {
      final themeKey = 'user_${userId}_theme';
      final langKey = 'user_${userId}_language';
      final avatarKey = 'user_${userId}_avatar';

      final theme = prefs.getString(themeKey) ?? prefs.getString('theme_mode');
      final language = prefs.getString(langKey) ?? 'es';
      final avatar = prefs.getString(avatarKey);

      await db.insert(
        'user_preferences',
        {
          'user_id': userId,
          'theme': theme ?? 'light',
          'language': language,
          'avatar': avatar,
          'music_enabled': 1,
          'effects_enabled': 1,
          'music_volume': 0.7,
          'effects_volume': 1.0,
          'is_synced': 0,
          'last_synced_at': null,
          'updated_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

      appLogger.info('Preferencias migradas para usuario $userId');
    } catch (e) {
      appLogger.warning('Error migrando preferencias: $e');
    }
  }
}
