import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';
import '../exceptions/api_exceptions.dart';
import '../utils/app_logger.dart';

/// Provider para gestionar el estado de autenticación de la aplicación
///
/// Maneja el ciclo de vida completo de autenticación: registro, login, logout,
/// persistencia de sesión y validación de tokens. Integrado con el backend
/// para autenticación tradicional y con Google Sign-In para OAuth.
class AuthProvider extends ChangeNotifier {
  // Estado del usuario actual
  UserModel? _currentUser;

  // Estados de UI
  bool _isLoading = false;
  String? _errorMessage;

  // Servicio de base de datos
  // final DatabaseService _dbHelper = DatabaseService.instance; // DATABASE DEACTIVATED

  // Getters para acceder al estado
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isGuest => _currentUser?.isGuest ?? false;
  bool get isPremium => _currentUser?.isPremium ?? false;

  /// Inicializar y verificar si hay una sesión guardada
  ///
  /// Se ejecuta al iniciar la app para restaurar la sesión del usuario
  /// si existe un token válido almacenado. Si el token ha expirado o
  /// es inválido, limpia la sesión automáticamente.
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(ApiConstants.storageKeyAuthToken);

      if (token != null) {
        appLogger.info('Validando sesión existente');

        try {
          final response = await ApiService.getMe(token);

          if (response['success'] == true) {
            final userData = response['data']['user'] as Map<String, dynamic>;

            _currentUser = _createUserFromServerData(userData);
            appLogger.authEvent('Sesión restaurada', metadata: {'userId': _currentUser!.id});
          } else {
            appLogger.warning('Token inválido, limpiando sesión');
            await _clearSession(prefs);
          }
        } on TokenExpiredException catch (e) {
          appLogger.warning('Token expirado', e);
          await _clearSession(prefs);
          _errorMessage = 'Tu sesión ha expirado. Inicia sesión nuevamente.';
        } on ApiException catch (e) {
          appLogger.error('Error de API validando sesión', e);
          await _clearSession(prefs);
        }
      }
    } catch (e) {
      appLogger.error('Error al inicializar sesión', e);
      _errorMessage = 'Error al inicializar sesión';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpiar sesión del almacenamiento local
  Future<void> _clearSession(SharedPreferences prefs) async {
    await prefs.remove(ApiConstants.storageKeyAuthToken);
    await prefs.remove(ApiConstants.storageKeyUserId);
  }

  /// Crear UserModel desde datos del servidor
  ///
  /// Centraliza la lógica de parseo para evitar duplicación
  UserModel _createUserFromServerData(Map<String, dynamic> userData) {
    return UserModel(
      id: userData['id'] as int,
      username: userData['username'] as String,
      email: userData['email'] as String?,
      passwordHash: '', // No almacenamos el hash en el cliente por seguridad
      isGuest: false,
      isPremium: userData['is_premium'] as bool? ?? false,
      createdAt: DateTime.parse(userData['created_at'] as String),
      lastLogin: DateTime.parse(userData['last_login'] as String),
      streakDays: userData['streak_days'] as int? ?? 0,
    );
  }

  /// Inicializar sin notificar (para primera carga)
  ///
  /// Similar a init() pero sin llamar notifyListeners(), útil cuando
  /// se necesita validar la sesión sin actualizar la UI
  Future<void> initSilent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(ApiConstants.storageKeyAuthToken);

      if (token != null) {
        try {
          final response = await ApiService.getMe(token);

          if (response['success'] == true) {
            final userData = response['data']['user'] as Map<String, dynamic>;
            _currentUser = _createUserFromServerData(userData);
          } else {
            await _clearSession(prefs);
          }
        } on ApiException {
          await _clearSession(prefs);
        }
      }
    } catch (e) {
      appLogger.error('Error en initSilent', e);
      _errorMessage = 'Error al inicializar sesión';
    }
  }

  /// Registrar nuevo usuario
  ///
  /// Crea una cuenta nueva en el backend y almacena el token JWT.
  /// Las validaciones básicas se hacen en el cliente, pero el backend
  /// también valida por seguridad.
  Future<bool> register({
    required String username,
    String? email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validaciones locales (el backend también validará)
      if (username.isEmpty || password.isEmpty) {
        _errorMessage = 'El nombre de usuario y la contraseña son requeridos';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _errorMessage = 'La contraseña debe tener al menos 6 caracteres';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      appLogger.authEvent('Intentando registro', metadata: {'username': username});

      final response = await ApiService.register(
        username: username,
        email: email,
        password: password,
      );

      if (response['success'] == true) {
        final token = response['data']['token'] as String;
        final userData = response['data']['user'] as Map<String, dynamic>;

        _currentUser = _createUserFromServerData(userData);

        // Guardar token JWT y sesión
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(ApiConstants.storageKeyAuthToken, token);
        await prefs.setInt(ApiConstants.storageKeyUserId, _currentUser!.id!);

        appLogger.authEvent('Registro exitoso', metadata: {'userId': _currentUser!.id});

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Error al registrar usuario';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on ApiException catch (e) {
      // Usar mensaje amigable de la excepción personalizada
      _errorMessage = e.userFriendlyMessage;
      appLogger.error('Error en registro', e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error al registrar usuario';
      appLogger.error('Error inesperado en registro', e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Iniciar sesión
  ///
  /// Autentica al usuario con el backend usando username/email y contraseña.
  /// Si la autenticación es exitosa, almacena el token JWT para futuras peticiones.
  Future<bool> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      appLogger.authEvent('Intentando login', metadata: {'usernameOrEmail': usernameOrEmail});

      final response = await ApiService.login(
        usernameOrEmail: usernameOrEmail,
        password: password,
      );

      if (response['success'] == true) {
        final token = response['data']['token'] as String;
        final userData = response['data']['user'] as Map<String, dynamic>;

        _currentUser = _createUserFromServerData(userData);

        // Guardar token JWT y sesión
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(ApiConstants.storageKeyAuthToken, token);
        await prefs.setInt(ApiConstants.storageKeyUserId, _currentUser!.id!);

        appLogger.authEvent('Login exitoso', metadata: {'userId': _currentUser!.id});

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Error al iniciar sesión';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on ApiException catch (e) {
      _errorMessage = e.userFriendlyMessage;
      appLogger.error('Error en login', e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error al iniciar sesión';
      appLogger.error('Error inesperado en login', e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Continuar como invitado
  Future<bool> continueAsGuest() async {
    // DATABASE DEACTIVATED - Using mock guest user
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Create a mock guest user (database calls deactivated)
      _currentUser = UserModel(
        id: 1,
        username: 'Guest',
        email: null,
        passwordHash: '',
        isGuest: true,
        isPremium: false,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        streakDays: 0,
        cloudId: null,
      );
      
      await _saveSession(_currentUser!.id!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al crear sesión de invitado: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    /* DATABASE DEACTIVATED CODE:
    try {
      final user = await _dbHelper.createGuestUser();
      _currentUser = user;
      await _saveSession(user.id!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al crear sesión de invitado: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
    */
  }

  /// Convertir invitado a usuario registrado
  Future<bool> convertGuestToRegistered({
    required String username,
    String? email,
    required String password,
  }) async {
    // DATABASE DEACTIVATED - Conversion disabled
    if (_currentUser == null || !_currentUser!.isGuest) {
      _errorMessage = 'No hay una sesión de invitado activa';
      return false;
    }

    _isLoading = true;
    _errorMessage = 'La conversión de cuenta está desactivada temporalmente';
    notifyListeners();
    _isLoading = false;
    notifyListeners();
    return false;

    /* DATABASE DEACTIVATED CODE:
    if (_currentUser == null || !_currentUser!.isGuest) {
      _errorMessage = 'No hay una sesión de invitado activa';
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _dbHelper.convertGuestToRegistered(
        guestId: _currentUser!.id!,
        username: username,
        email: email,
        password: password,
      );

      if (user == null) {
        _errorMessage = 'El nombre de usuario ya está en uso';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;
      await _saveSession(user.id!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al convertir cuenta: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
    */
  }

  /// Cerrar sesión
  ///
  /// Limpia la sesión del usuario tanto en el cliente como (opcionalmente)
  /// en el servidor. Con JWT stateless, el logout es principalmente del lado
  /// del cliente al eliminar el token.
  Future<void> logout() async {
    appLogger.authEvent('Cerrando sesión', metadata: {'userId': _currentUser?.id});

    final prefs = await SharedPreferences.getInstance();

    // Intentar hacer logout en el backend (opcional con JWT)
    final token = prefs.getString(ApiConstants.storageKeyAuthToken);
    if (token != null) {
      try {
        await ApiService.logout(token);
      } catch (e) {
        // Ignorar errores de logout del backend ya que es opcional
        appLogger.warning('Error en logout del backend (ignorado)', e);
      }
    }

    // Limpiar sesión local (esto es lo crítico)
    await _clearSession(prefs);
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Guardar sesión en SharedPreferences
  Future<void> _saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_user_id', userId);
  }

  /// Actualizar racha de días
  Future<void> _updateStreak() async {
    // DATABASE DEACTIVATED - Streak update disabled
    return;
    
    /* DATABASE DEACTIVATED CODE:
    if (_currentUser == null) return;

    final now = DateTime.now();
    final lastLogin = _currentUser!.lastLogin;

    // Calcular diferencia en días
    final difference = now.difference(lastLogin).inDays;

    int newStreak = _currentUser!.streakDays;

    if (difference == 0) {
      // Mismo día, no hacer nada
      return;
    } else if (difference == 1) {
      // Día consecutivo, aumentar racha
      newStreak++;
    } else {
      // Racha rota, reiniciar
      newStreak = 1;
    }

    await _dbHelper.updateStreakDays(_currentUser!.id!, newStreak);
    _currentUser = _currentUser!.copyWith(
      streakDays: newStreak,
      lastLogin: now,
    );
    notifyListeners();
    */
  }

  /// Actualizar estado premium (para el futuro)
  Future<void> updatePremiumStatus(bool isPremium) async {
    // DATABASE DEACTIVATED - Premium status update disabled
    return;
    
    /* DATABASE DEACTIVATED CODE:
    if (_currentUser == null) return;

    await _dbHelper.updatePremiumStatus(_currentUser!.id!, isPremium);
    _currentUser = _currentUser!.copyWith(isPremium: isPremium);
    notifyListeners();
    */
  }

  /// Limpiar mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Iniciar sesión con Google
  ///
  /// Implementa OAuth con Google Sign-In. Actualmente crea un usuario local
  /// con los datos de Google. En el futuro, esto debería integrarse con el
  /// backend para validar el token de Google y sincronizar datos.
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      appLogger.authEvent('Intentando login con Google');

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: '575590476395-s3eb8p7g533ichbs81qp8h23el53n1u7.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // El usuario canceló el login
        appLogger.info('Login con Google cancelado por el usuario');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Crear usuario local con datos de Google
      // TODO: En el futuro, validar el ID token con el backend
      _currentUser = UserModel(
        id: googleUser.id.hashCode,
        username: googleUser.displayName ?? 'Usuario Google',
        email: googleUser.email,
        passwordHash: '',
        isGuest: false,
        isPremium: false,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        streakDays: 0,
        cloudId: googleUser.id,
      );

      // Guardar sesión
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(ApiConstants.storageKeyUserId, _currentUser!.id!);
      await prefs.setString(ApiConstants.storageKeyGoogleUserId, googleUser.id);
      await prefs.setString(ApiConstants.storageKeyGoogleUserEmail, googleUser.email);
      await prefs.setString(ApiConstants.storageKeyGoogleUserName, googleUser.displayName ?? '');

      appLogger.authEvent('Login con Google exitoso', metadata: {'userId': _currentUser!.id});

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al iniciar sesión con Google';
      appLogger.error('Error en login con Google', e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cerrar sesión de Google
  Future<void> logoutGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (e) {
      // Ignorar errores de logout de Google
    }
    await logout();
  }
}
