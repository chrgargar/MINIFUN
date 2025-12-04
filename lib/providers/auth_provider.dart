import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../database/database_helper.dart';

/// Provider para gestionar el estado de autenticación
class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isGuest => _currentUser?.isGuest ?? false;
  bool get isPremium => _currentUser?.isPremium ?? false;

  /// Inicializar y verificar si hay una sesión guardada
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('current_user_id');

      if (userId != null) {
        // Cargar el usuario desde la base de datos
        final users = await _dbHelper.getAllUsers();
        final user = users.where((u) => u.id == userId).firstOrNull;

        if (user != null) {
          _currentUser = user;
          await _dbHelper.updateLastLogin(userId);
          await _updateStreak();
        } else {
          // Usuario no encontrado, limpiar sesión
          await prefs.remove('current_user_id');
        }
      }
    } catch (e) {
      _errorMessage = 'Error al inicializar sesión: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Inicializar sin notificar (para primera carga)
  Future<void> initSilent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('current_user_id');

      if (userId != null) {
        // Cargar el usuario desde la base de datos
        final users = await _dbHelper.getAllUsers();
        final user = users.where((u) => u.id == userId).firstOrNull;

        if (user != null) {
          _currentUser = user;
          await _dbHelper.updateLastLogin(userId);
          // No llamar a _updateStreak() aquí para evitar notifyListeners
        } else {
          // Usuario no encontrado, limpiar sesión
          await prefs.remove('current_user_id');
        }
      }
    } catch (e) {
      _errorMessage = 'Error al inicializar sesión: $e';
    }
  }

  /// Registrar nuevo usuario
  Future<bool> register({
    required String username,
    String? email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validaciones
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

      // Verificar si el usuario ya existe
      final existingUser = await _dbHelper.getUserByUsername(username);
      if (existingUser != null) {
        _errorMessage = 'El nombre de usuario ya está en uso';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Verificar si el email ya existe (si se proporcionó)
      if (email != null && email.isNotEmpty) {
        final existingEmail = await _dbHelper.getUserByEmail(email);
        if (existingEmail != null) {
          _errorMessage = 'El email ya está en uso';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      // Crear el usuario
      final user = await _dbHelper.createUser(
        username: username,
        email: email,
        password: password,
      );

      _currentUser = user;
      await _saveSession(user.id!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al registrar usuario: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Iniciar sesión
  Future<bool> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _dbHelper.authenticateUser(usernameOrEmail, password);

      if (user == null) {
        _errorMessage = 'Usuario o contraseña incorrectos';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;
      await _saveSession(user.id!);
      await _updateStreak();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al iniciar sesión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Continuar como invitado
  Future<bool> continueAsGuest() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

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
  }

  /// Convertir invitado a usuario registrado
  Future<bool> convertGuestToRegistered({
    required String username,
    String? email,
    required String password,
  }) async {
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
  }

  /// Cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
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
  }

  /// Actualizar estado premium (para el futuro)
  Future<void> updatePremiumStatus(bool isPremium) async {
    if (_currentUser == null) return;

    await _dbHelper.updatePremiumStatus(_currentUser!.id!, isPremium);
    _currentUser = _currentUser!.copyWith(isPremium: isPremium);
    notifyListeners();
  }

  /// Limpiar mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
