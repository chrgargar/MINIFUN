import 'package:logger/logger.dart';

/// Sistema centralizado de logging para la aplicación
///
/// Proporciona diferentes niveles de log (debug, info, warning, error)
/// y permite configurar el comportamiento según el entorno
class AppLogger {
  // Singleton para acceso global
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  late final Logger _logger;

  /// Inicializa el logger con la configuración apropiada
  void initialize({bool isDevelopment = true}) {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2, // Número de stack trace a mostrar
        errorMethodCount: 8, // Más detalle en errores
        lineLength: 120, // Ancho de línea
        colors: true, // Colores en consola
        printEmojis: true, // Emojis para identificar niveles
        printTime: true, // Timestamp
      ),
      level: isDevelopment ? Level.debug : Level.info,
    );
  }

  /// Log de depuración (solo en desarrollo)
  void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log informativo
  void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log de advertencia
  void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log de error
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log crítico/fatal
  void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  // ==================== LOGS ESPECÍFICOS DE LA APP ====================

  /// Log para eventos de autenticación
  void authEvent(String event, {Map<String, dynamic>? metadata}) {
    info('AUTH: $event', metadata);
  }

  /// Log para llamadas API
  void apiCall(String method, String endpoint, {int? statusCode, dynamic error}) {
    if (error != null) {
      this.error('API $method $endpoint - Error', error);
    } else {
      info('API $method $endpoint - Status: ${statusCode ?? 'N/A'}');
    }
  }

  /// Log para eventos de navegación
  void navigation(String from, String to) {
    debug('NAVIGATION: $from -> $to');
  }

  /// Log para eventos de juego
  void gameEvent(String gameName, String event, {Map<String, dynamic>? data}) {
    info('GAME [$gameName]: $event', data);
  }
}

/// Instancia global del logger para acceso rápido
final appLogger = AppLogger();
