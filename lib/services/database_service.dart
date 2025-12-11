import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';

/// Servicio para gestionar la base de datos SQLite local
/// NOTA: Base de datos deshabilitada - devuelve datos simulados
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    try {
      // DESHABILITADO: Base de datos no se inicializa
      // _database = await _initDB('minifun.db');
      print('DatabaseService: Base de datos deshabilitada (modo offline)');
      return _database!;
    } catch (e) {
      print('Error inicializando base de datos: $e');
      rethrow;
    }
  }

  /// Hash de contraseña usando SHA-256
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Crear un nuevo usuario (SIMULADO)
  Future<UserModel> createUser({
    required String username,
    String? email,
    required String password,
    bool isGuest = false,
  }) async {
    final now = DateTime.now();

    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      username: username,
      email: email,
      passwordHash: hashPassword(password),
      isGuest: isGuest,
      createdAt: now,
      lastLogin: now,
    );

    print('DatabaseService.createUser: SIMULADO - Usuario no guardado en BD');
    return user;
  }

  /// Crear usuario invitado (SIMULADO)
  Future<UserModel> createGuestUser() async {
    final now = DateTime.now();

    final user = UserModel.guest().copyWith(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      createdAt: now,
      lastLogin: now,
    );

    print('DatabaseService.createGuestUser: SIMULADO - Usuario invitado no guardado en BD');
    return user;
  }

  /// Obtener usuario por nombre de usuario (SIMULADO)
  Future<UserModel?> getUserByUsername(String username) async {
    print('DatabaseService.getUserByUsername: SIMULADO - No se consulta BD');
    return null;
  }

  /// Obtener usuario por email (SIMULADO)
  Future<UserModel?> getUserByEmail(String email) async {
    print('DatabaseService.getUserByEmail: SIMULADO - No se consulta BD');
    return null;
  }

  /// Autenticar usuario (SIMULADO)
  Future<UserModel?> authenticateUser(String usernameOrEmail, String password) async {
    print('DatabaseService.authenticateUser: SIMULADO - Autenticación deshabilitada');
    return null;
  }

  /// Actualizar último login (SIMULADO)
  Future<void> updateLastLogin(int userId) async {
    print('DatabaseService.updateLastLogin: SIMULADO - No se actualiza BD');
  }

  /// Actualizar racha de días (SIMULADO)
  Future<void> updateStreakDays(int userId, int streakDays) async {
    print('DatabaseService.updateStreakDays: SIMULADO - No se actualiza BD');
  }

  /// Actualizar premium status (SIMULADO)
  Future<void> updatePremiumStatus(int userId, bool isPremium) async {
    print('DatabaseService.updatePremiumStatus: SIMULADO - No se actualiza BD');
  }

  /// Convertir usuario invitado a cuenta registrada (SIMULADO)
  Future<UserModel?> convertGuestToRegistered({
    required int guestId,
    required String username,
    String? email,
    required String password,
  }) async {
    print('DatabaseService.convertGuestToRegistered: SIMULADO - No se actualiza BD');
    return null;
  }

  /// Eliminar usuario (SIMULADO)
  Future<int> deleteUser(int userId) async {
    print('DatabaseService.deleteUser: SIMULADO - No se elimina de BD');
    return 0;
  }

  /// Obtener todos los usuarios (SIMULADO)
  Future<List<UserModel>> getAllUsers() async {
    print('DatabaseService.getAllUsers: SIMULADO - No se consulta BD');
    return [];
  }

  /// Cerrar la base de datos (SIMULADO)
  Future<void> close() async {
    print('DatabaseService.close: SIMULADO - No se cierra BD');
  }
}
