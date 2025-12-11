/// Clase utilitaria con validadores reutilizables para formularios
class Validators {
  // Constantes de validación
  static const int minUsernameLength = 3;
  static const int minPasswordLength = 6;

  /// Validar nombre de usuario
  /// Retorna null si es válido, o un mensaje de error si no lo es
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu usuario';
    }
    if (value.length < minUsernameLength) {
      return 'El usuario debe tener al menos $minUsernameLength caracteres';
    }
    return null;
  }

  /// Validar usuario o email (para login)
  /// Retorna null si es válido, o un mensaje de error si no lo es
  static String? validateUsernameOrEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu usuario o email';
    }
    return null;
  }

  /// Validar email
  /// Retorna null si es válido, o un mensaje de error si no lo es
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu email';
    }

    // Expresión regular para validar formato de email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Por favor ingresa un email válido';
    }

    return null;
  }

  /// Validar contraseña
  /// Retorna null si es válida, o un mensaje de error si no lo es
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    if (value.length < minPasswordLength) {
      return 'Mínimo $minPasswordLength caracteres';
    }
    return null;
  }

  /// Validar confirmación de contraseña
  /// Retorna null si coincide, o un mensaje de error si no coincide
  static String? validatePasswordMatch(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Por favor confirma tu contraseña';
    }
    if (password != confirmPassword) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  /// Validar email opcional (puede estar vacío)
  /// Retorna null si es válido o vacío, o un mensaje de error si el formato es inválido
  static String? validateOptionalEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email opcional, puede estar vacío
    }

    // Si no está vacío, validar formato
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Por favor ingresa un email válido';
    }

    return null;
  }
}
