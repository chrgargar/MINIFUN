import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';

/// Servicio para gestionar la base de datos SQLite local
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    try {
      _database = await _initDB('minifun.db');
      return _database!;
    } catch (e) {
      print('Error inicializando base de datos: $e');
      rethrow;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabla de usuarios
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        email TEXT,
        password_hash TEXT NOT NULL,
        is_guest INTEGER NOT NULL DEFAULT 0,
        is_premium INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        last_login TEXT NOT NULL,
        streak_days INTEGER NOT NULL DEFAULT 0,
        cloud_id TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        last_sync_at TEXT
      )
    ''');

    // Índices para mejorar el rendimiento
    await db.execute('CREATE INDEX idx_username ON users(username)');
    await db.execute('CREATE INDEX idx_email ON users(email)');
    await db.execute('CREATE INDEX idx_cloud_id ON users(cloud_id)');

    // Tabla de puntuaciones (para el futuro)
    await db.execute('''
      CREATE TABLE scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        game_name TEXT NOT NULL,
        score INTEGER NOT NULL,
        game_mode TEXT,
        created_at TEXT NOT NULL,
        cloud_id TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_user_scores ON scores(user_id)');
  }

  /// Hash de contraseña usando SHA-256
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Crear un nuevo usuario
  Future<UserModel> createUser({
    required String username,
    String? email,
    required String password,
    bool isGuest = false,
  }) async {
    final db = await database;
    final now = DateTime.now();

    final user = UserModel(
      username: username,
      email: email,
      passwordHash: hashPassword(password),
      isGuest: isGuest,
      createdAt: now,
      lastLogin: now,
    );

    final id = await db.insert('users', user.toMap());
    return user.copyWith(id: id);
  }

  /// Crear usuario invitado
  Future<UserModel> createGuestUser() async {
    final db = await database;

    final user = UserModel.guest();
    final id = await db.insert('users', user.toMap());

    return user.copyWith(id: id);
  }

  /// Obtener usuario por nombre de usuario
  Future<UserModel?> getUserByUsername(String username) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  /// Obtener usuario por email
  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  /// Autenticar usuario
  Future<UserModel?> authenticateUser(String usernameOrEmail, String password) async {
    final db = await database;
    final passwordHash = hashPassword(password);

    final maps = await db.query(
      'users',
      where: '(username = ? OR email = ?) AND password_hash = ? AND is_guest = 0',
      whereArgs: [usernameOrEmail, usernameOrEmail, passwordHash],
    );

    if (maps.isEmpty) return null;

    final user = UserModel.fromMap(maps.first);

    // Actualizar último login
    await updateLastLogin(user.id!);

    return user.copyWith(lastLogin: DateTime.now());
  }

  /// Actualizar último login
  Future<void> updateLastLogin(int userId) async {
    final db = await database;
    await db.update(
      'users',
      {'last_login': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Actualizar racha de días
  Future<void> updateStreakDays(int userId, int streakDays) async {
    final db = await database;
    await db.update(
      'users',
      {'streak_days': streakDays},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Actualizar premium status
  Future<void> updatePremiumStatus(int userId, bool isPremium) async {
    final db = await database;
    await db.update(
      'users',
      {'is_premium': isPremium ? 1 : 0},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Convertir usuario invitado a cuenta registrada
  Future<UserModel?> convertGuestToRegistered({
    required int guestId,
    required String username,
    String? email,
    required String password,
  }) async {
    final db = await database;

    // Verificar que el usuario existe y es invitado
    final maps = await db.query(
      'users',
      where: 'id = ? AND is_guest = 1',
      whereArgs: [guestId],
    );

    if (maps.isEmpty) return null;

    // Verificar que el username no esté en uso
    final existingUser = await getUserByUsername(username);
    if (existingUser != null) return null;

    // Actualizar el usuario
    await db.update(
      'users',
      {
        'username': username,
        'email': email,
        'password_hash': hashPassword(password),
        'is_guest': 0,
      },
      where: 'id = ?',
      whereArgs: [guestId],
    );

    return getUserByUsername(username);
  }

  /// Eliminar usuario
  Future<int> deleteUser(int userId) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Obtener todos los usuarios (para debugging)
  Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('users');
    return maps.map((map) => UserModel.fromMap(map)).toList();
  }

  /// Cerrar la base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
