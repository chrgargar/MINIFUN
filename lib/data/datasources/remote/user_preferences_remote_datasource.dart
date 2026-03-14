import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constants/api_constants.dart';
import '../../../domain/entities/user_preferences_entity.dart';
import '../../../services/app_logger.dart';

/// Datasource remoto para preferencias de usuario (API Backend)
class UserPreferencesRemoteDatasource {
  /// Obtener preferencias del servidor
  Future<UserPreferencesEntity?> getPreferences(
    String token,
    int userId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}/users/$userId/preferences'),
            headers: _authHeaders(token),
          )
          .timeout(Duration(seconds: ApiConstants.requestTimeout));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _mapToEntity(data, userId);
      }
      return null;
    } catch (e) {
      appLogger.error('Error obteniendo preferencias del servidor', e);
      return null;
    }
  }

  /// Guardar preferencias en el servidor
  Future<bool> savePreferences(
    UserPreferencesEntity prefs,
    String token,
  ) async {
    if (prefs.userId == null) return false;

    try {
      final response = await http
          .put(
            Uri.parse(
                '${ApiConstants.baseUrl}/users/${prefs.userId}/preferences'),
            headers: {
              ..._authHeaders(token),
              'Content-Type': ApiConstants.contentTypeJson,
            },
            body: jsonEncode(_entityToMap(prefs)),
          )
          .timeout(Duration(seconds: ApiConstants.requestTimeout));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        appLogger.info('Preferencias sincronizadas');
        return true;
      }

      appLogger.warning(
          'Error guardando preferencias: ${response.statusCode}');
      return false;
    } catch (e) {
      appLogger.error('Error sincronizando preferencias', e);
      return false;
    }
  }

  /// Actualizar campo específico en el servidor
  Future<bool> updateField(
    int userId,
    String field,
    dynamic value,
    String token,
  ) async {
    try {
      final response = await http
          .patch(
            Uri.parse('${ApiConstants.baseUrl}/users/$userId/preferences'),
            headers: {
              ..._authHeaders(token),
              'Content-Type': ApiConstants.contentTypeJson,
            },
            body: jsonEncode({field: value}),
          )
          .timeout(Duration(seconds: ApiConstants.requestTimeout));

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      appLogger.error('Error actualizando preferencia $field', e);
      return false;
    }
  }

  Map<String, String> _authHeaders(String token) => {
        ApiConstants.authorizationHeader: ApiConstants.bearerToken(token),
      };

  UserPreferencesEntity _mapToEntity(Map<String, dynamic> map, int userId) {
    return UserPreferencesEntity(
      userId: userId,
      theme: map['theme'] as String? ?? 'light',
      language: map['language'] as String? ?? 'es',
      avatar: map['avatar'] as String?,
      musicEnabled: map['musicEnabled'] as bool? ?? true,
      effectsEnabled: map['effectsEnabled'] as bool? ?? true,
      musicVolume: (map['musicVolume'] as num?)?.toDouble() ?? 0.7,
      effectsVolume: (map['effectsVolume'] as num?)?.toDouble() ?? 1.0,
      isSynced: true,
      lastSyncedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> _entityToMap(UserPreferencesEntity e) {
    return {
      'theme': e.theme,
      'language': e.language,
      'avatar': e.avatar,
      'musicEnabled': e.musicEnabled,
      'effectsEnabled': e.effectsEnabled,
      'musicVolume': e.musicVolume,
      'effectsVolume': e.effectsVolume,
    };
  }
}
