import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constants/api_constants.dart';
import '../../../domain/entities/game_progress_entity.dart';
import '../../../services/app_logger.dart';

/// Datasource remoto para progreso de juegos (API Backend)
class GameProgressRemoteDatasource {
  /// Obtener progreso de un juego desde el servidor
  Future<GameProgressEntity?> getProgress(
    String gameType,
    String token,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
                '${ApiConstants.baseUrl}${ApiConstants.gameProgressByType}$gameType'),
            headers: _authHeaders(token),
          )
          .timeout(Duration(seconds: ApiConstants.requestTimeout));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['gameType'] != null) {
          return _mapToEntity(data);
        }
      }
      return null;
    } catch (e) {
      appLogger.error('Error obteniendo progreso del servidor', e);
      return null;
    }
  }

  /// Obtener todos los progresos del usuario
  Future<List<GameProgressEntity>> getAllProgress(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.gameProgress}'),
            headers: _authHeaders(token),
          )
          .timeout(Duration(seconds: ApiConstants.requestTimeout));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => _mapToEntity(e)).toList();
      }
      return [];
    } catch (e) {
      appLogger.error('Error obteniendo progresos del servidor', e);
      return [];
    }
  }

  /// Guardar progreso en el servidor
  Future<bool> saveProgress(GameProgressEntity progress, String token) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.gameProgress}'),
            headers: {
              ..._authHeaders(token),
              'Content-Type': ApiConstants.contentTypeJson,
            },
            body: jsonEncode(_entityToMap(progress)),
          )
          .timeout(Duration(seconds: ApiConstants.requestTimeout));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        appLogger.info('Progreso sincronizado: ${progress.gameType}');
        return true;
      }

      appLogger.warning('Error guardando en servidor: ${response.statusCode}');
      return false;
    } catch (e) {
      appLogger.error('Error sincronizando progreso', e);
      return false;
    }
  }

  /// Eliminar progreso del servidor
  Future<bool> deleteProgress(String gameType, String token) async {
    try {
      final response = await http
          .delete(
            Uri.parse(
                '${ApiConstants.baseUrl}${ApiConstants.gameProgressByType}$gameType'),
            headers: _authHeaders(token),
          )
          .timeout(Duration(seconds: ApiConstants.requestTimeout));

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      appLogger.error('Error eliminando progreso del servidor', e);
      return false;
    }
  }

  Map<String, String> _authHeaders(String token) => {
        ApiConstants.authorizationHeader: ApiConstants.bearerToken(token),
      };

  GameProgressEntity _mapToEntity(Map<String, dynamic> map) {
    return GameProgressEntity(
      userId: map['userId'] as int?,
      gameType: map['gameType'] as String,
      currentLevel: map['currentLevel'] as int? ?? 1,
      highestLevel: map['highestLevel'] as int? ?? 1,
      totalGamesPlayed: map['totalGamesPlayed'] as int? ?? 0,
      lastPlayedAt: map['lastPlayedAt'] != null
          ? DateTime.parse(map['lastPlayedAt'] as String)
          : DateTime.now(),
      customData: map['customData'] as Map<String, dynamic>? ?? {},
      isSynced: true,
      lastSyncedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> _entityToMap(GameProgressEntity e) {
    return {
      'gameType': e.gameType,
      'currentLevel': e.currentLevel,
      'highestLevel': e.highestLevel,
      'totalGamesPlayed': e.totalGamesPlayed,
      'lastPlayedAt': e.lastPlayedAt.toIso8601String(),
      'customData': e.customData,
    };
  }
}
