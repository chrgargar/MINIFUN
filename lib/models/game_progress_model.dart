import 'dart:convert';

/// Modelo para guardar el progreso de un juego
class GameProgress {
  final String gameType;
  final int currentLevel;
  final int highestLevel;
  final int totalGamesPlayed;
  final DateTime lastPlayedAt;
  final Map<String, dynamic> customData;
  final bool isSynced;
  final DateTime? lastSyncedAt;

  GameProgress({
    required this.gameType,
    this.currentLevel = 1,
    this.highestLevel = 1,
    this.totalGamesPlayed = 0,
    required this.lastPlayedAt,
    this.customData = const {},
    this.isSynced = false,
    this.lastSyncedAt,
  });

  /// Crear copia con cambios
  GameProgress copyWith({
    String? gameType,
    int? currentLevel,
    int? highestLevel,
    int? totalGamesPlayed,
    DateTime? lastPlayedAt,
    Map<String, dynamic>? customData,
    bool? isSynced,
    DateTime? lastSyncedAt,
  }) {
    return GameProgress(
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

  /// Convertir a Map para guardar
  Map<String, dynamic> toMap() {
    return {
      'gameType': gameType,
      'currentLevel': currentLevel,
      'highestLevel': highestLevel,
      'totalGamesPlayed': totalGamesPlayed,
      'lastPlayedAt': lastPlayedAt.toIso8601String(),
      'customData': jsonEncode(customData),
      'isSynced': isSynced ? 1 : 0,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }

  /// Crear desde Map
  factory GameProgress.fromMap(Map<String, dynamic> map) {
    return GameProgress(
      gameType: map['gameType'] as String,
      currentLevel: map['currentLevel'] as int? ?? 1,
      highestLevel: map['highestLevel'] as int? ?? 1,
      totalGamesPlayed: map['totalGamesPlayed'] as int? ?? 0,
      lastPlayedAt: DateTime.parse(map['lastPlayedAt'] as String),
      customData: map['customData'] != null
          ? jsonDecode(map['customData'] as String) as Map<String, dynamic>
          : {},
      isSynced: map['isSynced'] == 1,
      lastSyncedAt: map['lastSyncedAt'] != null
          ? DateTime.parse(map['lastSyncedAt'] as String)
          : null,
    );
  }

  /// Convertir a JSON string
  String toJson() => jsonEncode(toMap());

  /// Crear desde JSON string
  factory GameProgress.fromJson(String json) {
    return GameProgress.fromMap(jsonDecode(json) as Map<String, dynamic>);
  }
}
