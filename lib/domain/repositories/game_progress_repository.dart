import '../entities/game_progress_entity.dart';

/// Interfaz del repositorio de progreso de juegos
/// Define el contrato que deben cumplir las implementaciones
abstract class GameProgressRepository {
  /// Obtener progreso de un juego específico
  Future<GameProgressEntity?> getProgress(String gameType, {int? userId});

  /// Obtener todos los progresos de un usuario
  Future<List<GameProgressEntity>> getAllProgress({int? userId});

  /// Guardar o actualizar progreso
  Future<void> saveProgress(GameProgressEntity progress);

  /// Actualizar nivel completado
  Future<GameProgressEntity> updateLevelCompleted(
    String gameType,
    int completedLevel, {
    int? userId,
  });

  /// Obtener nivel más alto alcanzado
  Future<int> getHighestLevel(String gameType, {int? userId});

  /// Eliminar progreso de un juego
  Future<void> deleteProgress(String gameType, {int? userId});

  /// Obtener progresos pendientes de sincronizar
  Future<List<GameProgressEntity>> getUnsyncedProgress();

  /// Marcar progreso como sincronizado
  Future<void> markAsSynced(int id);

  /// Sincronizar con el servidor (para usuarios con cuenta)
  Future<void> syncWithServer(String token);

  /// Combinar progreso local con el del servidor
  Future<GameProgressEntity> mergeProgress(
    GameProgressEntity local,
    GameProgressEntity remote,
  );
}
