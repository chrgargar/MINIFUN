import 'dart:async';
import 'package:flutter/foundation.dart';
import '../network/connectivity_service.dart';
import '../../domain/repositories/game_progress_repository.dart';
import '../../domain/repositories/user_preferences_repository.dart';
import '../../services/app_logger.dart';
import 'sync_status.dart';

/// Servicio de sincronización en background
/// Orquesta la sincronización entre SQLite local y MySQL remoto
class SyncService extends ChangeNotifier {
  final GameProgressRepository _progressRepo;
  final UserPreferencesRepository _prefsRepo;
  final ConnectivityService _connectivity;

  Timer? _syncTimer;
  SyncStatus _status = SyncStatus.synced;
  DateTime? _lastSyncTime;
  String? _token;
  int? _userId;

  // Configuración
  static const Duration _syncInterval = Duration(minutes: 5);
  static const int _maxRetries = 3;

  SyncService(this._progressRepo, this._prefsRepo, this._connectivity);

  // Getters
  SyncStatus get status => _status;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get isAuthenticated => _token != null && _userId != null;

  /// Configurar credenciales de usuario (llamar en login)
  void setCredentials(String token, int userId) {
    _token = token;
    _userId = userId;
    appLogger.info('SyncService: Credenciales configuradas para user $userId');
  }

  /// Limpiar credenciales (llamar en logout)
  void clearCredentials() {
    _token = null;
    _userId = null;
    stopPeriodicSync();
    appLogger.info('SyncService: Credenciales limpiadas');
  }

  /// Iniciar sincronización periódica
  void startPeriodicSync() {
    if (!isAuthenticated) return;

    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (_) => sync());
    appLogger.info('Sincronización periódica iniciada (cada ${_syncInterval.inMinutes} min)');

    // Sincronizar inmediatamente
    sync();
  }

  /// Detener sincronización periódica
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    appLogger.info('Sincronización periódica detenida');
  }

  /// Sincronizar ahora
  Future<SyncResult> sync() async {
    if (!isAuthenticated) {
      return SyncResult.failure('No autenticado');
    }

    // Verificar conexión
    if (!await _connectivity.hasConnection()) {
      _updateStatus(SyncStatus.offline);
      return SyncResult.offline();
    }

    _updateStatus(SyncStatus.syncing);

    try {
      var syncedCount = 0;
      var failedCount = 0;

      // Sincronizar progreso de juegos
      try {
        await _progressRepo.syncWithServer(_token!);
        final unsyncedProgress = await _progressRepo.getUnsyncedProgress();
        syncedCount += unsyncedProgress.isEmpty ? 1 : 0;
      } catch (e) {
        appLogger.error('Error sincronizando progreso', e);
        failedCount++;
      }

      // Sincronizar preferencias
      try {
        await _prefsRepo.syncWithServer(_token!, _userId!);
        syncedCount++;
      } catch (e) {
        appLogger.error('Error sincronizando preferencias', e);
        failedCount++;
      }

      _lastSyncTime = DateTime.now();

      if (failedCount == 0) {
        _updateStatus(SyncStatus.synced);
        return SyncResult.success(syncedCount);
      }

      _updateStatus(SyncStatus.error);
      return SyncResult.failure('Algunos items fallaron', failed: failedCount);
    } catch (e) {
      appLogger.error('Error en sincronización general', e);
      _updateStatus(SyncStatus.error);
      return SyncResult.failure(e.toString());
    }
  }

  /// Sincronizar un tipo específico de datos
  Future<void> syncProgress() async {
    if (!isAuthenticated || !await _connectivity.hasConnection()) return;

    try {
      await _progressRepo.syncWithServer(_token!);
      _checkPendingStatus();
    } catch (e) {
      appLogger.error('Error sincronizando progreso', e);
    }
  }

  /// Sincronizar preferencias
  Future<void> syncPreferences() async {
    if (!isAuthenticated || !await _connectivity.hasConnection()) return;

    try {
      await _prefsRepo.syncWithServer(_token!, _userId!);
      _checkPendingStatus();
    } catch (e) {
      appLogger.error('Error sincronizando preferencias', e);
    }
  }

  /// Verificar si hay cambios pendientes
  Future<bool> hasPendingChanges() async {
    final unsyncedProgress = await _progressRepo.getUnsyncedProgress();
    final unsyncedPrefs = await _prefsRepo.getUnsyncedPreferences();

    return unsyncedProgress.isNotEmpty || unsyncedPrefs != null;
  }

  /// Verificar y actualizar estado
  Future<void> _checkPendingStatus() async {
    final hasPending = await hasPendingChanges();
    _updateStatus(hasPending ? SyncStatus.pending : SyncStatus.synced);
  }

  void _updateStatus(SyncStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners();
    }
  }

  /// Marcar que hay cambios pendientes
  void markPendingChanges() {
    _updateStatus(SyncStatus.pending);
  }

  @override
  void dispose() {
    stopPeriodicSync();
    super.dispose();
  }
}
