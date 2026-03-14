import 'package:flutter/foundation.dart';
import '../core/di/service_locator.dart';
import '../core/sync/sync_service.dart';
import '../domain/entities/game_progress_entity.dart';
import '../domain/repositories/game_progress_repository.dart';
import '../services/app_logger.dart';

/// Provider para el progreso de juegos
/// Expone los datos del repositorio a la UI con notificaciones
class GameProgressProvider extends ChangeNotifier {
  final GameProgressRepository _repository;
  final SyncService _syncService;

  int? _currentUserId;
  bool _isGuest = true;

  GameProgressProvider()
      : _repository = sl.progressRepository,
        _syncService = sl.syncService;

  // Estado
  int? get currentUserId => _currentUserId;
  bool get isGuest => _isGuest;

  /// Configurar usuario actual
  void setUser(int? userId, {bool isGuest = false}) {
    _currentUserId = userId;
    _isGuest = isGuest;
    notifyListeners();
  }

  /// Limpiar usuario (logout)
  void clearUser() {
    _currentUserId = null;
    _isGuest = true;
    notifyListeners();
  }

  /// Obtener progreso de un juego
  Future<GameProgressEntity?> getProgress(String gameType) async {
    return await _repository.getProgress(
      gameType,
      userId: _isGuest ? null : _currentUserId,
    );
  }

  /// Obtener nivel más alto
  Future<int> getHighestLevel(String gameType) async {
    return await _repository.getHighestLevel(
      gameType,
      userId: _isGuest ? null : _currentUserId,
    );
  }

  /// Actualizar nivel completado
  Future<void> updateLevelCompleted(
    String gameType,
    int completedLevel,
  ) async {
    await _repository.updateLevelCompleted(
      gameType,
      completedLevel,
      userId: _isGuest ? null : _currentUserId,
    );

    // Marcar que hay cambios pendientes de sync
    if (!_isGuest) {
      _syncService.markPendingChanges();
    }

    notifyListeners();
    appLogger.info('Nivel $completedLevel completado en $gameType');
  }

  /// Obtener todos los progresos
  Future<List<GameProgressEntity>> getAllProgress() async {
    return await _repository.getAllProgress(
      userId: _isGuest ? null : _currentUserId,
    );
  }

  /// Eliminar progreso de un juego
  Future<void> deleteProgress(String gameType) async {
    await _repository.deleteProgress(
      gameType,
      userId: _isGuest ? null : _currentUserId,
    );
    notifyListeners();
  }

  /// Forzar sincronización
  Future<void> forceSync() async {
    if (_isGuest) return;
    await _syncService.syncProgress();
    notifyListeners();
  }
}
