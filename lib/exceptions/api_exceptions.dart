/// Excepciones personalizadas para manejo de errores de API
///
/// Estas clases permiten un manejo más específico de errores
/// en lugar de usar Exception genérico

/// Excepción base para todos los errores de API
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const ApiException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() => message;

  /// Mensaje amigable para mostrar al usuario
  String get userFriendlyMessage => message;
}

// ==================== ERRORES DE RED ====================

/// Error de conexión a la red (sin internet, servidor caído, etc.)
class NetworkException extends ApiException {
  const NetworkException([String? message])
      : super(message ?? 'Error de conexión. Verifica tu conexión a internet.');

  @override
  String get userFriendlyMessage =>
      'No se pudo conectar al servidor. Verifica tu conexión a internet.';
}

/// Timeout en la petición
class TimeoutException extends ApiException {
  const TimeoutException([String? message])
      : super(message ?? 'La solicitud tardó demasiado en responder.');

  @override
  String get userFriendlyMessage =>
      'La operación tardó demasiado. Intenta nuevamente.';
}

// ==================== ERRORES DE AUTENTICACIÓN ====================

/// Error de autenticación (401)
class UnauthorizedException extends ApiException {
  const UnauthorizedException([String? message])
      : super(message ?? 'No autorizado. Inicia sesión nuevamente.', statusCode: 401);

  @override
  String get userFriendlyMessage =>
      'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.';
}

/// Token expirado
class TokenExpiredException extends UnauthorizedException {
  const TokenExpiredException()
      : super('El token de sesión ha expirado.');

  @override
  String get userFriendlyMessage =>
      'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.';
}

/// Error de permisos (403)
class ForbiddenException extends ApiException {
  const ForbiddenException([String? message])
      : super(message ?? 'No tienes permisos para realizar esta acción.', statusCode: 403);

  @override
  String get userFriendlyMessage =>
      'No tienes permisos para realizar esta acción.';
}

// ==================== ERRORES DE VALIDACIÓN ====================

/// Error de validación (400)
class ValidationException extends ApiException {
  final Map<String, String>? fieldErrors;

  const ValidationException(String message, {this.fieldErrors})
      : super(message, statusCode: 400);

  @override
  String get userFriendlyMessage => message;
}

/// Recurso duplicado (409) - Por ejemplo, username ya existe
class ConflictException extends ApiException {
  const ConflictException(String message) : super(message, statusCode: 409);

  @override
  String get userFriendlyMessage => message;
}

// ==================== ERRORES DEL SERVIDOR ====================

/// Error del servidor (500)
class ServerException extends ApiException {
  const ServerException([String? message])
      : super(message ?? 'Error interno del servidor.', statusCode: 500);

  @override
  String get userFriendlyMessage =>
      'Ocurrió un error en el servidor. Intenta nuevamente más tarde.';
}

/// Servicio no disponible (503)
class ServiceUnavailableException extends ApiException {
  const ServiceUnavailableException([String? message])
      : super(message ?? 'Servicio no disponible temporalmente.', statusCode: 503);

  @override
  String get userFriendlyMessage =>
      'El servicio no está disponible en este momento. Intenta más tarde.';
}

// ==================== OTROS ERRORES ====================

/// Recurso no encontrado (404)
class NotFoundException extends ApiException {
  const NotFoundException([String? message])
      : super(message ?? 'Recurso no encontrado.', statusCode: 404);

  @override
  String get userFriendlyMessage => 'El recurso solicitado no existe.';
}

/// Error desconocido o no manejado
class UnknownApiException extends ApiException {
  const UnknownApiException([String? message, dynamic originalError])
      : super(message ?? 'Ocurrió un error inesperado.', originalError: originalError);

  @override
  String get userFriendlyMessage =>
      'Ocurrió un error inesperado. Intenta nuevamente.';
}

// ==================== FACTORY PARA CREAR EXCEPCIONES ====================

/// Factory para crear la excepción apropiada según el código de estado HTTP
class ApiExceptionFactory {
  /// Crea una excepción basada en el código de estado HTTP
  static ApiException fromStatusCode(int statusCode, String message, {dynamic originalError}) {
    switch (statusCode) {
      case 400:
        return ValidationException(message);
      case 401:
        return UnauthorizedException(message);
      case 403:
        return ForbiddenException(message);
      case 404:
        return NotFoundException(message);
      case 409:
        return ConflictException(message);
      case 500:
        return ServerException(message);
      case 503:
        return ServiceUnavailableException(message);
      default:
        return UnknownApiException(message, originalError);
    }
  }

  /// Crea una excepción desde un error genérico
  static ApiException fromError(dynamic error) {
    if (error is ApiException) {
      return error;
    }

    // Si es un error de red o timeout
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return NetworkException(error.toString());
    }

    if (errorString.contains('timeout')) {
      return TimeoutException(error.toString());
    }

    return UnknownApiException(error.toString(), error);
  }
}
