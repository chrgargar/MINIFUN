import '../database/local_database.dart';
import '../network/connectivity_service.dart';
import '../sync/sync_service.dart';
import '../../data/datasources/local/game_progress_local_datasource.dart';
import '../../data/datasources/local/user_preferences_local_datasource.dart';
import '../../data/datasources/remote/game_progress_remote_datasource.dart';
import '../../data/datasources/remote/user_preferences_remote_datasource.dart';
import '../../data/repositories/game_progress_repository_impl.dart';
import '../../data/repositories/user_preferences_repository_impl.dart';
import '../../domain/repositories/game_progress_repository.dart';
import '../../domain/repositories/user_preferences_repository.dart';
import '../../services/app_logger.dart';

/// Localizador de servicios - Singleton simple para DI
/// Maneja la inicialización y acceso a todas las dependencias
class ServiceLocator {
  static ServiceLocator? _instance;
  static ServiceLocator get instance => _instance ??= ServiceLocator._();

  ServiceLocator._();

  // Core
  late final LocalDatabase _localDatabase;
  late final ConnectivityService _connectivity;

  // Datasources
  late final GameProgressLocalDatasource _progressLocalDs;
  late final GameProgressRemoteDatasource _progressRemoteDs;
  late final UserPreferencesLocalDatasource _prefsLocalDs;
  late final UserPreferencesRemoteDatasource _prefsRemoteDs;

  // Repositories
  late final GameProgressRepository _progressRepo;
  late final UserPreferencesRepository _prefsRepo;

  // Services
  late final SyncService _syncService;

  bool _initialized = false;

  /// Inicializar todas las dependencias
  Future<void> initialize() async {
    if (_initialized) return;

    appLogger.info('Inicializando ServiceLocator...');

    // Core
    _localDatabase = LocalDatabase.instance;
    _connectivity = ConnectivityService.instance;

    // Inicializar base de datos
    await _localDatabase.database;

    // Datasources
    _progressLocalDs = GameProgressLocalDatasource(_localDatabase);
    _progressRemoteDs = GameProgressRemoteDatasource();
    _prefsLocalDs = UserPreferencesLocalDatasource(_localDatabase);
    _prefsRemoteDs = UserPreferencesRemoteDatasource();

    // Repositories
    _progressRepo = GameProgressRepositoryImpl(
      _progressLocalDs,
      _progressRemoteDs,
      _connectivity,
    );

    _prefsRepo = UserPreferencesRepositoryImpl(
      _prefsLocalDs,
      _prefsRemoteDs,
      _connectivity,
    );

    // Services
    _syncService = SyncService(_progressRepo, _prefsRepo, _connectivity);

    _initialized = true;
    appLogger.info('ServiceLocator inicializado correctamente');
  }

  // Getters públicos
  LocalDatabase get localDatabase => _localDatabase;
  ConnectivityService get connectivity => _connectivity;
  GameProgressRepository get progressRepository => _progressRepo;
  UserPreferencesRepository get preferencesRepository => _prefsRepo;
  SyncService get syncService => _syncService;

  /// Limpiar todo (para tests o logout completo)
  Future<void> reset() async {
    _syncService.dispose();
    await _localDatabase.close();
    _initialized = false;
  }
}

/// Acceso global al ServiceLocator
ServiceLocator get sl => ServiceLocator.instance;
