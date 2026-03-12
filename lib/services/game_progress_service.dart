import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_progress_model.dart';
import '../constants/api_constants.dart';
import 'app_logger.dart';

/// Servicio para guardar y cargar progreso de juegos
/// - Local (SharedPreferences) para invitados
/// - Backend (API) para usuarios con cuenta
class GameProgressService {
  GameProgressService._();

  // ==================== KEYS DE STORAGE ====================

  static String _getProgressKey(String gameType) {
    return 'game_progress_$gameType';
  }

  static const String _syncQueueKey = 'game_progress_sync_queue';

  // ==================== MÉTODOS LOCALES (SharedPreferences) ====================

  /// Guardar progreso LOCALMENTE
  static Future<void> saveProgressLocal(GameProgress progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getProgressKey(progress.gameType);

      await prefs.setString(key, progress.toJson());

      appLogger.info('Progreso guardado localmente: ${progress.gameType} nivel ${progress.highestLevel}');
    } catch (e) {
      appLogger.error('Error guardando progreso localmente', e);
    }
  }

  /// Cargar progreso LOCAL
  static Future<GameProgress?> loadProgressLocal(String gameType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getProgressKey(gameType);

      final json = prefs.getString(key);
      if (json == null) return null;

      return GameProgress.fromJson(json);
    } catch (e) {
      appLogger.error('Error cargando progreso localmente', e);
      return null;
    }
  }

  /// Obtener nivel más alto alcanzado localmente
  static Future<int> getHighestLevelLocal(String gameType) async {
    final progress = await loadProgressLocal(gameType);
    return progress?.highestLevel ?? 1;
  }

  /// Actualizar nivel completado
  static Future<void> updateLevelCompleted(String gameType, int completedLevel) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getProgressKey(gameType);

      // Cargar progreso existente o crear nuevo
      GameProgress progress;
      final existingJson = prefs.getString(key);

      if (existingJson != null) {
        progress = GameProgress.fromJson(existingJson);
        // Actualizar solo si el nivel completado es mayor
        if (completedLevel >= progress.highestLevel) {
          progress = progress.copyWith(
            currentLevel: completedLevel + 1,
            highestLevel: completedLevel + 1,
            totalGamesPlayed: progress.totalGamesPlayed + 1,
            lastPlayedAt: DateTime.now(),
            isSynced: false,
          );
        } else {
          progress = progress.copyWith(
            totalGamesPlayed: progress.totalGamesPlayed + 1,
            lastPlayedAt: DateTime.now(),
          );
        }
      } else {
        progress = GameProgress(
          gameType: gameType,
          currentLevel: completedLevel + 1,
          highestLevel: completedLevel + 1,
          totalGamesPlayed: 1,
          lastPlayedAt: DateTime.now(),
        );
      }

      await prefs.setString(key, progress.toJson());
      appLogger.info('Nivel $completedLevel completado en $gameType. Siguiente: ${progress.currentLevel}');
    } catch (e) {
      appLogger.error('Error actualizando nivel completado', e);
    }
  }

  /// Limpiar progreso LOCAL de un juego
  static Future<void> deleteProgressLocal(String gameType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getProgressKey(gameType);
      await prefs.remove(key);
      appLogger.info('Progreso local eliminado: $gameType');
    } catch (e) {
      appLogger.error('Error eliminando progreso local', e);
    }
  }

  // ==================== MÉTODOS DE BACKEND (API) ====================

  /// Guardar progreso en BACKEND (usuarios con cuenta)
  static Future<bool> saveProgressBackend(GameProgress progress, String token) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.gameProgress}'),
            headers: {
              'Content-Type': ApiConstants.contentTypeJson,
              ApiConstants.authorizationHeader: ApiConstants.bearerToken(token),
            },
            body: jsonEncode(progress.toMap()),
          )
          .timeout(Duration(seconds: ApiConstants.requestTimeout));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        appLogger.info('Progreso guardado en backend: ${progress.gameType}');
        return true;
      } else {
        appLogger.warning('Error guardando en backend: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      appLogger.error('Error sincronizando con backend', e);
      return false;
    }
  }

  /// Cargar progreso del BACKEND
  static Future<GameProgress?> loadProgressBackend(String gameType, String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.gameProgressByType}$gameType'),
            headers: {
              ApiConstants.authorizationHeader: ApiConstants.bearerToken(token),
            },
          )
          .timeout(Duration(seconds: ApiConstants.requestTimeout));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['gameType'] != null) {
          return GameProgress.fromMap(data);
        }
      }
      return null;
    } catch (e) {
      appLogger.error('Error cargando progreso del backend', e);
      return null;
    }
  }

  /// Añadir a cola de sincronización (para cuando no hay conexión)
  static Future<void> queueForSync(GameProgress progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queue = prefs.getStringList(_syncQueueKey) ?? [];
      queue.add(progress.toJson());
      await prefs.setStringList(_syncQueueKey, queue);
      appLogger.info('Progreso añadido a cola de sincronización');
    } catch (e) {
      appLogger.error('Error añadiendo a cola de sincronización', e);
    }
  }

  /// Sincronizar cola pendiente con backend
  static Future<void> syncPendingProgress(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queue = prefs.getStringList(_syncQueueKey) ?? [];
      if (queue.isEmpty) return;

      final failedItems = <String>[];

      for (final jsonProgress in queue) {
        final progress = GameProgress.fromJson(jsonProgress);
        final success = await saveProgressBackend(progress, token);

        if (!success) {
          failedItems.add(jsonProgress);
        }
      }

      await prefs.setStringList(_syncQueueKey, failedItems);
      appLogger.info('Sincronización completada. Pendientes: ${failedItems.length}');
    } catch (e) {
      appLogger.error('Error sincronizando cola', e);
    }
  }

  // ==================== MÉTODOS COMBINADOS ====================

  /// Guardar progreso (automáticamente local + backend si tiene cuenta)
  static Future<void> saveProgress({
    required String gameType,
    required int completedLevel,
    required bool isGuest,
    String? token,
  }) async {
    // Siempre guardar localmente
    await updateLevelCompleted(gameType, completedLevel);

    // Si tiene cuenta, intentar guardar en backend
    if (!isGuest && token != null) {
      final progress = await loadProgressLocal(gameType);
      if (progress != null) {
        final success = await saveProgressBackend(progress, token);
        if (!success) {
          await queueForSync(progress);
        } else {
          // Marcar como sincronizado
          await saveProgressLocal(progress.copyWith(
            isSynced: true,
            lastSyncedAt: DateTime.now(),
          ));
        }
      }
    }
  }

  /// Cargar progreso (combina local y backend)
  static Future<GameProgress?> loadProgress({
    required String gameType,
    required bool isGuest,
    String? token,
  }) async {
    // Cargar local primero
    final localProgress = await loadProgressLocal(gameType);

    // Si es invitado, solo devolver local
    if (isGuest || token == null) {
      return localProgress;
    }

    // Si tiene cuenta, intentar cargar del backend
    final backendProgress = await loadProgressBackend(gameType, token);

    // Si no hay progreso en backend, devolver local
    if (backendProgress == null) {
      return localProgress;
    }

    // Si no hay local, guardar el del backend localmente
    if (localProgress == null) {
      await saveProgressLocal(backendProgress);
      return backendProgress;
    }

    // Si hay ambos, usar el que tenga mayor nivel
    if (backendProgress.highestLevel > localProgress.highestLevel) {
      await saveProgressLocal(backendProgress);
      return backendProgress;
    }

    return localProgress;
  }
}
