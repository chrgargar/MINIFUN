/// Entidad de dominio para las preferencias del usuario
class UserPreferencesEntity {
  final int? id;
  final int? userId;
  final String theme;
  final String language;
  final String? avatar;
  final bool musicEnabled;
  final bool effectsEnabled;
  final double musicVolume;
  final double effectsVolume;
  final bool isSynced;
  final DateTime? lastSyncedAt;

  const UserPreferencesEntity({
    this.id,
    this.userId,
    this.theme = 'light',
    this.language = 'es',
    this.avatar,
    this.musicEnabled = true,
    this.effectsEnabled = true,
    this.musicVolume = 0.7,
    this.effectsVolume = 1.0,
    this.isSynced = false,
    this.lastSyncedAt,
  });

  /// Crear preferencias por defecto para un usuario
  factory UserPreferencesEntity.defaultFor(int? userId) {
    return UserPreferencesEntity(userId: userId);
  }

  /// Crear copia con modificaciones
  UserPreferencesEntity copyWith({
    int? id,
    int? userId,
    String? theme,
    String? language,
    String? avatar,
    bool? musicEnabled,
    bool? effectsEnabled,
    double? musicVolume,
    double? effectsVolume,
    bool? isSynced,
    DateTime? lastSyncedAt,
  }) {
    return UserPreferencesEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      avatar: avatar ?? this.avatar,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      effectsEnabled: effectsEnabled ?? this.effectsEnabled,
      musicVolume: musicVolume ?? this.musicVolume,
      effectsVolume: effectsVolume ?? this.effectsVolume,
      isSynced: isSynced ?? this.isSynced,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  bool get isDarkMode => theme == 'dark';

  /// Marcar como sincronizado
  UserPreferencesEntity markSynced() {
    return copyWith(
      isSynced: true,
      lastSyncedAt: DateTime.now(),
    );
  }

  /// Marcar como pendiente de sincronizar
  UserPreferencesEntity markPendingSync() {
    return copyWith(isSynced: false);
  }
}
