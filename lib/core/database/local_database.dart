import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../services/app_logger.dart';

/// Base de datos SQLite local - Singleton
/// Maneja todas las operaciones de base de datos local
class LocalDatabase {
  static LocalDatabase? _instance;
  static Database? _database;

  LocalDatabase._();

  static LocalDatabase get instance => _instance ??= LocalDatabase._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'minifun.db');

    appLogger.info('Inicializando base de datos en: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Tabla de progreso de juegos
    await db.execute('''
      CREATE TABLE game_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        game_type TEXT NOT NULL,
        current_level INTEGER DEFAULT 1,
        highest_level INTEGER DEFAULT 1,
        total_games_played INTEGER DEFAULT 0,
        last_played_at TEXT NOT NULL,
        custom_data TEXT,
        is_synced INTEGER DEFAULT 0,
        last_synced_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(user_id, game_type)
      )
    ''');

    // Tabla de preferencias de usuario
    await db.execute('''
      CREATE TABLE user_preferences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER UNIQUE,
        theme TEXT DEFAULT 'light',
        language TEXT DEFAULT 'es',
        avatar TEXT,
        music_enabled INTEGER DEFAULT 1,
        effects_enabled INTEGER DEFAULT 1,
        music_volume REAL DEFAULT 0.7,
        effects_volume REAL DEFAULT 1.0,
        is_synced INTEGER DEFAULT 0,
        last_synced_at TEXT,
        updated_at TEXT NOT NULL
      )
    ''');

    // Cola de sincronización
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id INTEGER NOT NULL,
        action TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        last_error TEXT
      )
    ''');

    // Índices para optimización
    await db.execute(
        'CREATE INDEX idx_progress_user ON game_progress(user_id)');
    await db.execute(
        'CREATE INDEX idx_progress_sync ON game_progress(is_synced)');
    await db.execute(
        'CREATE INDEX idx_sync_queue_table ON sync_queue(table_name)');

    appLogger.info('Tablas de base de datos creadas');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    appLogger.info('Actualizando DB de v$oldVersion a v$newVersion');
    // Migraciones futuras aquí
  }

  /// Cerrar la base de datos
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Limpiar todos los datos (para logout completo)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('game_progress');
    await db.delete('user_preferences');
    await db.delete('sync_queue');
    appLogger.info('Base de datos limpiada');
  }

  /// Limpiar datos de un usuario específico
  Future<void> clearUserData(int userId) async {
    final db = await database;
    await db.delete('game_progress', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('user_preferences', where: 'user_id = ?', whereArgs: [userId]);
    appLogger.info('Datos del usuario $userId eliminados');
  }
}
