import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../core/database/local_database.dart';
import '../../../domain/entities/game_progress_entity.dart';
import '../../../services/app_logger.dart';

/// Datasource local para progreso de juegos (SQLite)
class GameProgressLocalDatasource {
  final LocalDatabase _localDb;

  GameProgressLocalDatasource(this._localDb);

  /// Obtener progreso de un juego
  Future<GameProgressEntity?> getProgress(String gameType, {int? userId}) async {
    final db = await _localDb.database;
    final results = await db.query(
      'game_progress',
      where: 'game_type = ? AND user_id ${userId == null ? 'IS NULL' : '= ?'}',
      whereArgs: userId == null ? [gameType] : [gameType, userId],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return _mapToEntity(results.first);
  }

  /// Obtener todos los progresos
  Future<List<GameProgressEntity>> getAllProgress({int? userId}) async {
    final db = await _localDb.database;
    final results = await db.query(
      'game_progress',
      where: userId == null ? 'user_id IS NULL' : 'user_id = ?',
      whereArgs: userId == null ? null : [userId],
    );

    return results.map(_mapToEntity).toList();
  }

  /// Guardar progreso
  Future<int> saveProgress(GameProgressEntity progress) async {
    final db = await _localDb.database;
    final now = DateTime.now().toIso8601String();
    final data = _entityToMap(progress, now);

    // Usar INSERT OR REPLACE para upsert
    final id = await db.insert(
      'game_progress',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    appLogger.info('Progreso guardado localmente: ${progress.gameType}');
    return id;
  }

  /// Obtener progresos no sincronizados
  Future<List<GameProgressEntity>> getUnsyncedProgress() async {
    final db = await _localDb.database;
    final results = await db.query(
      'game_progress',
      where: 'is_synced = 0 AND user_id IS NOT NULL',
    );

    return results.map(_mapToEntity).toList();
  }

  /// Marcar como sincronizado
  Future<void> markAsSynced(int id) async {
    final db = await _localDb.database;
    await db.update(
      'game_progress',
      {
        'is_synced': 1,
        'last_synced_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Eliminar progreso
  Future<void> deleteProgress(String gameType, {int? userId}) async {
    final db = await _localDb.database;
    await db.delete(
      'game_progress',
      where: 'game_type = ? AND user_id ${userId == null ? 'IS NULL' : '= ?'}',
      whereArgs: userId == null ? [gameType] : [gameType, userId],
    );
  }

  GameProgressEntity _mapToEntity(Map<String, dynamic> map) {
    return GameProgressEntity(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      gameType: map['game_type'] as String,
      currentLevel: map['current_level'] as int? ?? 1,
      highestLevel: map['highest_level'] as int? ?? 1,
      totalGamesPlayed: map['total_games_played'] as int? ?? 0,
      lastPlayedAt: DateTime.parse(map['last_played_at'] as String),
      customData: map['custom_data'] != null
          ? jsonDecode(map['custom_data'] as String) as Map<String, dynamic>
          : {},
      isSynced: map['is_synced'] == 1,
      lastSyncedAt: map['last_synced_at'] != null
          ? DateTime.parse(map['last_synced_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> _entityToMap(GameProgressEntity e, String now) {
    return {
      if (e.id != null) 'id': e.id,
      'user_id': e.userId,
      'game_type': e.gameType,
      'current_level': e.currentLevel,
      'highest_level': e.highestLevel,
      'total_games_played': e.totalGamesPlayed,
      'last_played_at': e.lastPlayedAt.toIso8601String(),
      'custom_data': jsonEncode(e.customData),
      'is_synced': e.isSynced ? 1 : 0,
      'last_synced_at': e.lastSyncedAt?.toIso8601String(),
      'created_at': now,
      'updated_at': now,
    };
  }
}
