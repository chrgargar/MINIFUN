import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';

import '../constants/api_constants.dart';
import '../exceptions/api_exceptions.dart';
import '../utils/app_logger.dart';

/// Servicio centralizado para comunicación con el backend API
///
/// Maneja todas las peticiones HTTP, logging, timeouts y manejo de errores.
/// Sigue el patrón Repository para abstraer la lógica de red.
class ApiService {
  // Prevenir instanciación directa (clase de utilidad)
  ApiService._();

  // ==================== MÉTODOS PRIVADOS DE UTILIDAD ====================

  /// Construye la URL completa para un endpoint
  static Uri _buildUrl(String endpoint) {
    return Uri.parse('${ApiConstants.baseUrl}$endpoint');
  }

  /// Headers comunes para todas las peticiones
  static Map<String, String> _baseHeaders() {
    return {
      'Content-Type': ApiConstants.contentTypeJson,
    };
  }

  /// Headers con autenticación
  static Map<String, String> _authHeaders(String token) {
    return {
      ..._baseHeaders(),
      ApiConstants.authorizationHeader: ApiConstants.bearerToken(token),
    };
  }

  /// Maneja la respuesta HTTP y lanza excepciones apropiadas si hay error
  static Map<String, dynamic> _handleResponse(http.Response response, String endpoint) {
    final statusCode = response.statusCode;

    appLogger.apiCall(
      'RESPONSE',
      endpoint,
      statusCode: statusCode,
    );

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // Si la respuesta es exitosa (200-299)
      if (statusCode >= 200 && statusCode < 300) {
        return data;
      }

      // Si hay error, extraer el mensaje del backend
      final errorMessage = data['message'] as String? ?? 'Error desconocido';

      // Crear excepción específica según el código de estado
      throw ApiExceptionFactory.fromStatusCode(statusCode, errorMessage);
    } on FormatException catch (e) {
      // Error al parsear JSON
      appLogger.error('Error parseando JSON', e);
      throw const UnknownApiException('Respuesta inválida del servidor');
    }
  }

  /// Maneja excepciones de red y las convierte en ApiException
  static Never _handleError(dynamic error, String endpoint) {
    appLogger.apiCall('ERROR', endpoint, error: error);

    if (error is ApiException) {
      throw error;
    }

    if (error is SocketException) {
      throw const NetworkException();
    }

    if (error is TimeoutException) {
      throw const TimeoutException();
    }

    if (error is FormatException) {
      throw const UnknownApiException('Error al procesar la respuesta');
    }

    throw ApiExceptionFactory.fromError(error);
  }

  // ==================== MÉTODOS PÚBLICOS DE API ====================

  /// POST /auth/register
  /// Registro de nuevo usuario
  ///
  /// [username] debe tener al menos 3 caracteres
  /// [password] debe tener al menos 6 caracteres
  /// [email] es opcional
  static Future<Map<String, dynamic>> register({
    required String username,
    String? email,
    required String password,
  }) async {
    const endpoint = ApiConstants.authRegister;
    appLogger.apiCall('POST', endpoint);

    try {
      final response = await http
          .post(
            _buildUrl(endpoint),
            headers: _baseHeaders(),
            body: jsonEncode({
              'username': username,
              'email': email,
              'password': password,
            }),
          )
          .timeout(
            Duration(seconds: ApiConstants.authTimeout),
          );

      return _handleResponse(response, endpoint);
    } catch (e) {
      _handleError(e, endpoint);
    }
  }

  /// POST /auth/login
  /// Inicio de sesión con username/email y contraseña
  ///
  /// [usernameOrEmail] puede ser el username o el email del usuario
  /// [password] es la contraseña del usuario
  static Future<Map<String, dynamic>> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    const endpoint = ApiConstants.authLogin;
    appLogger.apiCall('POST', endpoint);

    try {
      final response = await http
          .post(
            _buildUrl(endpoint),
            headers: _baseHeaders(),
            body: jsonEncode({
              'usernameOrEmail': usernameOrEmail,
              'password': password,
            }),
          )
          .timeout(
            Duration(seconds: ApiConstants.authTimeout),
          );

      return _handleResponse(response, endpoint);
    } catch (e) {
      _handleError(e, endpoint);
    }
  }

  /// GET /auth/me
  /// Obtener información del usuario autenticado
  ///
  /// Requiere un token JWT válido. Si el token ha expirado,
  /// lanzará [TokenExpiredException]
  static Future<Map<String, dynamic>> getMe(String token) async {
    const endpoint = ApiConstants.authMe;
    appLogger.apiCall('GET', endpoint);

    try {
      final response = await http
          .get(
            _buildUrl(endpoint),
            headers: _authHeaders(token),
          )
          .timeout(
            Duration(seconds: ApiConstants.requestTimeout),
          );

      return _handleResponse(response, endpoint);
    } catch (e) {
      // Si es un error 401, probablemente el token expiró
      if (e is UnauthorizedException) {
        throw const TokenExpiredException();
      }
      _handleError(e, endpoint);
    }
  }

  /// POST /auth/logout
  /// Cerrar sesión
  ///
  /// En JWT stateless, el logout es manejado principalmente por el cliente
  /// eliminando el token. Este endpoint es opcional y puede usarse para
  /// invalidar tokens en el servidor si se implementa una blacklist.
  static Future<Map<String, dynamic>> logout(String token) async {
    const endpoint = ApiConstants.authLogout;
    appLogger.apiCall('POST', endpoint);

    try {
      final response = await http
          .post(
            _buildUrl(endpoint),
            headers: _authHeaders(token),
          )
          .timeout(
            Duration(seconds: ApiConstants.requestTimeout),
          );

      return _handleResponse(response, endpoint);
    } catch (e) {
      _handleError(e, endpoint);
    }
  }

  /// GET /health
  /// Verificar estado del servidor
  ///
  /// Útil para comprobar si el backend está disponible antes de
  /// realizar operaciones críticas
  static Future<Map<String, dynamic>> healthCheck() async {
    const endpoint = ApiConstants.health;
    appLogger.apiCall('GET', endpoint);

    try {
      final response = await http
          .get(
            _buildUrl(endpoint),
            headers: _baseHeaders(),
          )
          .timeout(
            const Duration(seconds: 5), // Timeout corto para health check
          );

      return _handleResponse(response, endpoint);
    } catch (e) {
      _handleError(e, endpoint);
    }
  }

  /// POST /auth/forgot-password
  /// Solicitar restablecimiento de contraseña
  ///
  /// [email] es el correo electrónico del usuario
  /// Envía un email con el enlace para restablecer la contraseña
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    const endpoint = ApiConstants.authForgotPassword;
    appLogger.apiCall('POST', endpoint);

    try {
      final response = await http
          .post(
            _buildUrl(endpoint),
            headers: _baseHeaders(),
            body: jsonEncode({
              'email': email,
            }),
          )
          .timeout(
            Duration(seconds: ApiConstants.authTimeout),
          );

      return _handleResponse(response, endpoint);
    } catch (e) {
      _handleError(e, endpoint);
    }
  }
}
