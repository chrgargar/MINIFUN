import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../constants/api_constants.dart';

/// Representa un log individual
class LogEntry {
  final String level;
  final String message;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final String? screen; // Pantalla actual cuando ocurrió el log

  LogEntry({
    required this.level,
    required this.message,
    this.metadata,
    this.screen,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'level': level,
    'message': message,
    'metadata': metadata,
    'timestamp': timestamp.toIso8601String(),
    'screen': screen,
  };
}

/// Sistema centralizado de logging para la aplicación
///
/// Captura errores automáticamente, rastrea navegación y envía logs al backend.
class AppLogger {
  // Singleton para acceso global
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  /// Buffer de logs pendientes de enviar
  final List<LogEntry> _logBuffer = [];

  /// Timer para envío en batch
  Timer? _batchTimer;

  /// Intervalo de envío en segundos
  static const int batchIntervalSeconds = 30;

  /// Máximo de logs en buffer antes de forzar envío
  static const int maxBufferSize = 50;

  /// Información del dispositivo (se obtiene una vez)
  Map<String, dynamic>? _deviceInfo;

  /// Versión de la app
  String? _appVersion;

  /// Si está en modo desarrollo (muestra logs en consola)
  bool _isDevelopment = false;

  /// Si el logger está inicializado
  bool _initialized = false;

  /// Pantalla actual (se actualiza con NavigatorObserver)
  String _currentScreen = 'Unknown';

  /// Idioma actual de la app
  String _currentLanguage = 'es';

  /// Getter para la pantalla actual
  String get currentScreen => _currentScreen;

  /// Getter para el idioma actual
  String get currentLanguage => _currentLanguage;

  /// Actualiza la pantalla actual
  void setCurrentScreen(String screen) {
    _currentScreen = screen;
    debug('Navegación a: $screen');
  }

  /// Actualiza el idioma actual
  /// [isManualChange] indica si el usuario cambió el idioma manualmente (true) o es inicialización (false)
  void setLanguage(String language, {bool isManualChange = false}) {
    final oldLanguage = _currentLanguage;
    _currentLanguage = language;

    if (isManualChange) {
      // Cambio manual del usuario
      if (oldLanguage != language) {
        info('Idioma cambiado', null, null, {'from': oldLanguage, 'to': language});
      }
    } else {
      // Inicialización - siempre loguear el idioma inicial
      info('Idioma inicial', null, null, {'language': language});
    }
  }

  /// Inicializa el logger
  Future<void> initialize({bool isDevelopment = true}) async {
    if (_initialized) return;

    _isDevelopment = isDevelopment;
    _deviceInfo = await _getDeviceInfo();
    _appVersion = await _getAppVersion();

    // Iniciar timer de batch
    _startBatchTimer();

    _initialized = true;

    info('Logger inicializado', null, null, {'device': _deviceInfo, 'appVersion': _appVersion});
  }

  /// Obtiene información detallada del dispositivo
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        return {
          'platform': 'Android',
          'model': android.model,
          'brand': android.brand,
          'device': android.device,
          'androidVersion': android.version.release,
          'sdkInt': android.version.sdkInt,
          'isPhysicalDevice': android.isPhysicalDevice,
        };
      } else if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        return {
          'platform': 'iOS',
          'model': ios.model,
          'name': ios.name,
          'systemVersion': ios.systemVersion,
          'isPhysicalDevice': ios.isPhysicalDevice,
        };
      } else if (Platform.isWindows) {
        final windows = await deviceInfo.windowsInfo;
        return {
          'platform': 'Windows',
          'computerName': windows.computerName,
          'productName': windows.productName,
        };
      }
    } catch (e) {
      debugPrint('Error obteniendo info del dispositivo: $e');
    }

    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
    };
  }

  /// Obtiene la versión de la app
  Future<String> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (e) {
      return '1.0.0';
    }
  }

  /// Inicia el timer para envío en batch
  void _startBatchTimer() {
    _batchTimer?.cancel();
    _batchTimer = Timer.periodic(
      const Duration(seconds: batchIntervalSeconds),
      (_) => _sendBatch(),
    );
  }

  /// Formatea el stack trace para que sea más legible
  String _formatStackTrace(StackTrace? stackTrace, {int maxLines = 10}) {
    if (stackTrace == null) return '';

    final lines = stackTrace.toString().split('\n');
    final relevantLines = lines
        .where((line) => line.contains('package:MINIFUN') || line.contains('dart:'))
        .take(maxLines)
        .toList();

    if (relevantLines.isEmpty) {
      return lines.take(maxLines).join('\n');
    }

    return relevantLines.join('\n');
  }

  /// Agrega un log al buffer
  void _log(String level, dynamic message, [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? extraData]) {
    final messageStr = message.toString();
    final metadata = <String, dynamic>{};

    // Agregar datos extra si existen
    if (extraData != null) {
      metadata.addAll(extraData);
    }

    // Agregar error si existe
    if (error != null) {
      metadata['error'] = error.toString();
      metadata['errorType'] = error.runtimeType.toString();
    }

    // Agregar stack trace formateado si existe
    if (stackTrace != null) {
      metadata['stackTrace'] = _formatStackTrace(stackTrace);
    }

    final entry = LogEntry(
      level: level,
      message: messageStr,
      metadata: metadata.isNotEmpty ? metadata : null,
      screen: _currentScreen,
    );

    _logBuffer.add(entry);

    // Mostrar en consola si está en desarrollo
    if (_isDevelopment && !kReleaseMode) {
      final emoji = _getLevelEmoji(level);
      debugPrint('$emoji [$level] [$_currentScreen] $messageStr');
      if (error != null) {
        debugPrint('   Error: $error');
      }
      if (stackTrace != null && (level == 'error' || level == 'fatal')) {
        debugPrint('   Stack: ${_formatStackTrace(stackTrace, maxLines: 5)}');
      }
    }

    // Si el buffer está lleno, enviar inmediatamente
    if (_logBuffer.length >= maxBufferSize) {
      _sendBatch();
    }
  }

  /// Obtiene emoji según nivel de log
  String _getLevelEmoji(String level) {
    switch (level) {
      case 'debug': return '🐛';
      case 'info': return 'ℹ️';
      case 'warning': return '⚠️';
      case 'error': return '❌';
      case 'fatal': return '💀';
      default: return '📝';
    }
  }

  /// Envía el batch de logs al servidor
  Future<void> _sendBatch() async {
    if (_logBuffer.isEmpty) return;

    // Copiar logs y limpiar buffer
    final logsToSend = List<LogEntry>.from(_logBuffer);
    _logBuffer.clear();

    try {
      // Obtener token de autenticación
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(ApiConstants.storageKeyAuthToken);

      if (token == null) {
        if (_isDevelopment) {
          debugPrint('⚠️ No hay token, logs descartados: ${logsToSend.length}');
        }
        return;
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logs}'),
        headers: {
          'Content-Type': ApiConstants.contentTypeJson,
          ApiConstants.authorizationHeader: ApiConstants.bearerToken(token),
        },
        body: jsonEncode({
          'logs': logsToSend.map((e) => e.toJson()).toList(),
          'deviceInfo': _deviceInfo,
          'appVersion': _appVersion,
          'language': _currentLanguage,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (_isDevelopment) {
          debugPrint('✅ Logs enviados: ${logsToSend.length}');
        }
      } else {
        _logBuffer.insertAll(0, logsToSend);
        if (_isDevelopment) {
          debugPrint('❌ Error enviando logs: ${response.statusCode}');
        }
      }
    } catch (e) {
      _logBuffer.insertAll(0, logsToSend);
      if (_isDevelopment) {
        debugPrint('❌ Error de red enviando logs: $e');
      }
    }
  }

  /// Fuerza el envío inmediato de logs pendientes
  Future<void> flush() async {
    await _sendBatch();
  }

  // ==================== MÉTODOS DE LOG ====================

  /// Log de depuración
  void debug(dynamic message, [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? data]) {
    _log('debug', message, error, stackTrace, data);
  }

  /// Log informativo
  void info(dynamic message, [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? data]) {
    _log('info', message, error, stackTrace, data);
  }

  /// Log de advertencia
  void warning(dynamic message, [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? data]) {
    _log('warning', message, error, stackTrace, data);
  }

  /// Log de error
  void error(dynamic message, [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? data]) {
    _log('error', message, error, stackTrace, data);
  }

  /// Log crítico/fatal
  void fatal(dynamic message, [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? data]) {
    _log('fatal', message, error, stackTrace, data);
  }

  // ==================== CAPTURA AUTOMÁTICA DE ERRORES ====================

  /// Captura errores de Flutter (FlutterError)
  void captureFlutterError(FlutterErrorDetails details) {
    fatal(
      'Flutter Error: ${details.exceptionAsString()}',
      details.exception,
      details.stack,
      {
        'library': details.library ?? 'unknown',
        'context': details.context?.toString() ?? 'unknown',
      },
    );
  }

  /// Captura errores de Dart (excepciones no manejadas)
  void captureDartError(Object error, StackTrace stackTrace) {
    fatal(
      'Uncaught Exception: $error',
      error,
      stackTrace,
    );
  }

  // ==================== LOGS ESPECÍFICOS DE LA APP ====================

  /// Log para eventos de autenticación
  void authEvent(String event, {Map<String, dynamic>? metadata}) {
    info('AUTH: $event', null, null, metadata);
  }

  /// Log para llamadas API
  void apiCall(String method, String endpoint, {int? statusCode, dynamic error, StackTrace? stackTrace}) {
    if (error != null) {
      this.error('API $method $endpoint - Error', error, stackTrace, {'statusCode': statusCode});
    } else {
      debug('API $method $endpoint - Status: ${statusCode ?? 'N/A'}');
    }
  }

  /// Log para eventos de navegación
  void navigation(String from, String to) {
    debug('NAVIGATION: $from -> $to');
  }

  /// Log para eventos de juego
  void gameEvent(String gameName, String event, {Map<String, dynamic>? data}) {
    info('GAME [$gameName]: $event', null, null, data);
  }

  /// Log para acciones del usuario (botones, gestos, etc.)
  void userAction(String action, {Map<String, dynamic>? data}) {
    debug('USER_ACTION: $action', null, null, data);
  }

  /// Log para errores de UI (widgets)
  void uiError(String widget, String error, [StackTrace? stackTrace]) {
    this.error('UI_ERROR [$widget]: $error', null, stackTrace);
  }

  /// Cierra el logger y envía logs pendientes
  Future<void> dispose() async {
    _batchTimer?.cancel();
    await _sendBatch();
    _initialized = false;
  }
}

/// Instancia global del logger para acceso rápido
final appLogger = AppLogger();

/// Observer de navegación para rastrear pantallas automáticamente
/// Solo registra rutas con nombre definido (ignora MaterialPageRoute genéricos y diálogos)
class LoggerNavigatorObserver extends NavigatorObserver {
  /// Extrae un nombre útil de la ruta, o null si no es identificable
  String? _getScreenName(Route? route) {
    if (route == null) return null;

    // Ignorar diálogos
    final routeType = route.runtimeType.toString();
    if (routeType.contains('Dialog') || routeType.contains('Popup')) {
      return null;
    }

    // Si tiene nombre definido, usarlo
    final name = route.settings.name;
    if (name != null && name.isNotEmpty && name != '/') {
      return name;
    }

    // No podemos identificar la ruta de forma útil
    return null;
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    final screenName = _getScreenName(route);
    if (screenName != null) {
      appLogger.setCurrentScreen(screenName);
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    final screenName = _getScreenName(previousRoute);
    if (screenName != null) {
      appLogger.setCurrentScreen(screenName);
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final screenName = _getScreenName(newRoute);
    if (screenName != null) {
      appLogger.setCurrentScreen(screenName);
    }
  }
}
