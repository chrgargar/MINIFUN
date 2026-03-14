import '../../core/network/connectivity_service.dart';
import '../../domain/entities/game_progress_entity.dart';
import '../../domain/repositories/game_progress_repository.dart';
import '../../services/app_logger.dart';
import '../datasources/local/game_progress_local_datasource.dart';
import '../datasources/remote/game_progress_remote_datasource.dart';

/// Implementación del repositorio de progreso de juegos
/// Sigue el patrón Offline-First: siempre local primero, sync en background
class GameProgressRepositoryImpl implements GameProgressRepository {
  final GameProgressLocalDatasource _localDs;
  final GameProgressRemoteDatasource _remoteDs;
  final ConnectivityService _connectivity;

  GameProgressRepositoryImpl(
    this._localDs,
    this._remoteDs,
    this._connectivity,
  );

  @override
  Future<GameProgressEntity?> getProgress(
    String gameType, {
    int? userId,
  }) async {
    // Siempre devolver desde local (instantáneo)
    return await _localDs.getProgress(gameType, userId: userId);
  }

  @override
  Future<List<GameProgressEntity>> getAllProgress({int? userId}) async {
    return await _localDs.getAllProgress(userId: userId);
  }

  @override
  Future<void> saveProgress(GameProgressEntity progress) async {
    await _localDs.saveProgress(progress);
  }

  @override
  Future<GameProgressEntity> updateLevelCompleted(
    String gameType,
    int completedLevel, {
    int? userId,
  }) async {
    // Obtener progreso existente o crear nuevo
    var progress = await _localDs.getProgress(gameType, userId: userId);

    if (progress == null) {
      progress = GameProgressEntity(
        userId: userId,
        gameType: gameType,
        currentLevel: completedLevel + 1,
        highestLevel: completedLevel + 1,
        totalGamesPlayed: 1,
        lastPlayedAt: DateTime.now(),
      );
    } else {
      progress = progress.withCompletedLevel(completedLevel);
    }

    await _localDs.saveProgress(progress);
    appLogger.info('Nivel $completedLevel completado en $gameType');

    return progress;
  }

  @override
  Future<int> getHighestLevel(String gameType, {int? userId}) async {
    final progress = await _localDs.getProgress(gameType, userId: userId);
    return progress?.highestLevel ?? 1;
  }

  @override
  Future<void> deleteProgress(String gameType, {int? userId}) async {
    await _localDs.deleteProgress(gameType, userId: userId);
  }

  @override
  Future<List<GameProgressEntity>> getUnsyncedProgress() async {
    return await _localDs.getUnsyncedProgress();
  }

  @override
  Future<void> markAsSynced(int id) async {
    await _localDs.markAsSynced(id);
  }

  @override
  Future<void> syncWithServer(String token) async {
    if (!await _connectivity.hasConnection()) {
      appLogger.info('Sin conexión - sincronización pospuesta');
      return;
    }

    // 1. Subir cambios locales no sincronizados
    final unsynced = await _localDs.getUnsyncedProgress();
    for (final progress in unsynced) {
      final success = await _remoteDs.saveProgress(progress, token);
      if (success && progress.id != null) {
        await _localDs.markAsSynced(progress.id!);
      }
    }

    // 2. Descargar cambios del servidor
    final serverProgress = await _remoteDs.getAllProgress(token);
    for (final remote in serverProgress) {
      final local = await _localDs.getProgress(
        remote.gameType,
        userId: remote.userId,
      );

      if (local == null) {
        // No existe localmente, guardar del servidor
        await _localDs.saveProgress(remote);
      } else {
        // Existe, combinar (el mayor gana)
        final merged = await mergeProgress(local, remote);
        await _localDs.saveProgress(merged);
      }
    }

    appLogger.info('Sincronización de progreso completada');
  }

  @override
  Future<GameProgressEntity> mergeProgress(
    GameProgressEntity local,
    GameProgressEntity remote,
  ) async {
    // Estrategia: el nivel más alto gana
    if (remote.highestLevel > local.highestLevel) {
      return remote.copyWith(id: local.id);
    }

    if (local.highestLevel > remote.highestLevel) {
      return local.copyWith(isSynced: false);
    }

    // Mismo nivel: combinar estadísticas
    return local.copyWith(
      totalGamesPlayed: local.totalGamesPlayed > remote.totalGamesPlayed
          ? local.totalGamesPlayed
          : remote.totalGamesPlayed,
      lastPlayedAt: local.lastPlayedAt.isAfter(remote.lastPlayedAt)
          ? local.lastPlayedAt
          : remote.lastPlayedAt,
      isSynced: true,
      lastSyncedAt: DateTime.now(),
    );
  }
}
