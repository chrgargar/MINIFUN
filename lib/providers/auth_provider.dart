import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

/// Provider para gestionar el estado de autenticación
class AuthProvider extends ChangeNotifier {
  // Estado del usuario actual
  UserModel? _currentUser;

  // Estados de UI
  bool _isLoading = false;
  String? _errorMessage;

  // Servicio de base de datos
  final DatabaseService _dbHelper = DatabaseService.instance;

  // Getters para acceder al estado
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
        // NOTA: Base de datos deshabilitada - no se carga usuario
        print('AuthProvider.init: Base de datos deshabilitada (modo offline)');
        await _dbHelper.updateLastLogin(userId);
        await _updateStreak();
      }
    } catch (e) {
      print('Error al inicializar sesión: $e');
      _errorMessage = null; // No mostrar error en offline
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
        // NOTA: Base de datos deshabilitada - no se carga usuario
        print('AuthProvider.initSilent: Base de datos deshabilitada (modo offline)');
        await _dbHelper.updateLastLogin(userId);
      }
    } catch (e) {
      print('Error al inicializar sesión: $e');
    }
  }

  /// Registrar nuevo usuario (DESHABILITADO EN MODO OFFLINE)
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

      // NOTA: Base de datos deshabilitada - registro no disponible
      print('AuthProvider.register: Registro deshabilitado (modo offline)');
      _errorMessage = 'El registro no está disponible en modo offline';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error al registrar usuario: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Iniciar sesión (DESHABILITADO EN MODO OFFLINE)
  Future<bool> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // NOTA: Base de datos deshabilitada - autenticación no disponible
      print('AuthProvider.login: Autenticación deshabilitada (modo offline)');
      _errorMessage = 'El inicio de sesión no está disponible en modo offline';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error al iniciar sesión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Continuar como invitado (FUNCIONA EN MODO OFFLINE)
  Future<bool> continueAsGuest() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // NOTA: Crear usuario invitado simulado (sin acceso a BD)
      final user = await _dbHelper.createGuestUser();
      _currentUser = user;
      await _saveSession(user.id!);
      print('AuthProvider.continueAsGuest: Sesión invitada creada (modo offline)');

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

  /// Convertir invitado a usuario registrado (DESHABILITADO EN MODO OFFLINE)
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
      // NOTA: Base de datos deshabilitada - conversión no disponible
      print('AuthProvider.convertGuestToRegistered: Conversión deshabilitada (modo offline)');
      _errorMessage = 'La conversión de cuenta no está disponible en modo offline';
      _isLoading = false;
      notifyListeners();
      return false;
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

  /// Actualizar racha de días (DESHABILITADO EN MODO OFFLINE)
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

    // NOTA: Base de datos deshabilitada - racha no se actualiza
    print('AuthProvider._updateStreak: Racha simulada (modo offline)');
    _currentUser = _currentUser!.copyWith(
      streakDays: newStreak,
      lastLogin: now,
    );
    // notifyListeners() no se llama para evitar notificaciones
  }

  /// Actualizar estado premium (DESHABILITADO EN MODO OFFLINE)
  Future<void> updatePremiumStatus(bool isPremium) async {
    if (_currentUser == null) return;

    // NOTA: Base de datos deshabilitada - premium status no se actualiza
    print('AuthProvider.updatePremiumStatus: Estado premium no se actualiza (modo offline)');
    _currentUser = _currentUser!.copyWith(isPremium: isPremium);
    notifyListeners();
  }

  /// Limpiar mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
