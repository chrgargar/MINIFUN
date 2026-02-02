/// Constantes relacionadas con la API y configuración de red
///
/// Centraliza todas las URLs, timeouts y configuraciones de API
/// para facilitar cambios entre entornos (desarrollo, producción)
class ApiConstants {
  // Prevenir instanciación de esta clase de constantes
  ApiConstants._();

  // ==================== CONFIGURACIÓN DE ENTORNO ====================

  /// Modo de desarrollo (cambiar a false en producción)
  static const bool isDevelopment = false;

  // ==================== URLs BASE ====================

  /// URL base para desarrollo local (computadora)
  /// Para usar con ngrok, cambia a: 'https://TU-URL-NGROK.ngrok.io/api'
  static const String _baseUrlDevelopment = 'http://localhost:3000/api';

  /// URL base para emulador Android (10.0.2.2 es localhost del host)
  static const String _baseUrlAndroidEmulator = 'http://10.0.2.2:3000/api';

  /// URL base para producción (configurar cuando se despliegue)
  static const String _baseUrlProduction = 'https://backend-minifun.onrender.com/api';

  /// URL base activa según el entorno
  static String get baseUrl => isDevelopment ? _baseUrlDevelopment : _baseUrlProduction;

  /// URL base para emulador Android
  static String get baseUrlAndroid => _baseUrlAndroidEmulator;

  // ==================== ENDPOINTS ====================

  /// Endpoints de autenticación
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';
  static const String authLogout = '/auth/logout';
  static const String authForgotPassword = '/auth/forgot-password';

  /// Endpoint de health check
  static const String health = '/health';

  // ==================== TIMEOUTS ====================

  /// Timeout para requests normales (en segundos)
  static const int requestTimeout = 30;

  /// Timeout para operaciones de autenticación (en segundos)
  static const int authTimeout = 15;

  /// Timeout para operaciones de upload (en segundos)
  static const int uploadTimeout = 60;

  // ==================== HEADERS ====================

  /// Content-Type para JSON
  static const String contentTypeJson = 'application/json';

  /// Header de autorización
  static const String authorizationHeader = 'Authorization';

  /// Formato del token Bearer
  static String bearerToken(String token) => 'Bearer $token';

  // ==================== CÓDIGOS DE ESTADO HTTP ====================

  /// Success
  static const int httpOk = 200;
  static const int httpCreated = 201;

  /// Client Errors
  static const int httpBadRequest = 400;
  static const int httpUnauthorized = 401;
  static const int httpForbidden = 403;
  static const int httpNotFound = 404;
  static const int httpConflict = 409;

  /// Server Errors
  static const int httpInternalError = 500;
  static const int httpServiceUnavailable = 503;

  // ==================== KEYS DE STORAGE ====================

  /// Key para guardar el token JWT en SharedPreferences
  static const String storageKeyAuthToken = 'auth_token';

  /// Key para guardar el ID del usuario actual
  static const String storageKeyUserId = 'current_user_id';

  /// Keys de Google Sign-In
  static const String storageKeyGoogleUserId = 'google_user_id';
  static const String storageKeyGoogleUserEmail = 'google_user_email';
  static const String storageKeyGoogleUserName = 'google_user_name';
}
