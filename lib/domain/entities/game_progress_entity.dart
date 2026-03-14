/// Entidad de dominio para el progreso de un juego
/// Independiente de la infraestructura (DB, API)
class GameProgressEntity {
  final int? id;
  final int? userId;
  final String gameType;
  final int currentLevel;
  final int highestLevel;
  final int totalGamesPlayed;
  final DateTime lastPlayedAt;
  final Map<String, dynamic> customData;
  final bool isSynced;
  final DateTime? lastSyncedAt;

  const GameProgressEntity({
    this.id,
    this.userId,
    required this.gameType,
    this.currentLevel = 1,
    this.highestLevel = 1,
    this.totalGamesPlayed = 0,
    required this.lastPlayedAt,
    this.customData = const {},
    this.isSynced = false,
    this.lastSyncedAt,
  });

  /// Crear copia con modificaciones
  GameProgressEntity copyWith({
    int? id,
    int? userId,
    String? gameType,
    int? currentLevel,
    int? highestLevel,
    int? totalGamesPlayed,
    DateTime? lastPlayedAt,
    Map<String, dynamic>? customData,
    bool? isSynced,
    DateTime? lastSyncedAt,
  }) {
    return GameProgressEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gameType: gameType ?? this.gameType,
      currentLevel: currentLevel ?? this.currentLevel,
      highestLevel: highestLevel ?? this.highestLevel,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      customData: customData ?? this.customData,
      isSynced: isSynced ?? this.isSynced,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  /// Actualizar después de completar un nivel
  GameProgressEntity withCompletedLevel(int completedLevel) {
    final newHighest = completedLevel >= highestLevel
        ? completedLevel + 1
        : highestLevel;

    return copyWith(
      currentLevel: completedLevel + 1,
      highestLevel: newHighest,
      totalGamesPlayed: totalGamesPlayed + 1,
      lastPlayedAt: DateTime.now(),
      isSynced: false,
    );
  }

  /// Marcar como sincronizado
  GameProgressEntity markSynced() {
    return copyWith(
      isSynced: true,
      lastSyncedAt: DateTime.now(),
    );
  }

  @override
  String toString() =>
      'GameProgress($gameType: level $currentLevel, highest $highestLevel)';
}
