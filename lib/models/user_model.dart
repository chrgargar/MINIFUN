/// Modelo de usuario para la base de datos local
class UserModel {
  final int? id;
  final String username;
  final String? email;
  final String passwordHash;
  final bool isGuest;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime lastLogin;
  final int streakDays;

  // Para sincronización futura con la nube
  final String? cloudId;
  final bool isSynced;
  final DateTime? lastSyncAt;

  UserModel({
    this.id,
    required this.username,
    this.email,
    required this.passwordHash,
    this.isGuest = false,
    this.isPremium = false,
    required this.createdAt,
    required this.lastLogin,
    this.streakDays = 0,
    this.cloudId,
    this.isSynced = false,
    this.lastSyncAt,
  });

  /// Convertir de Map (base de datos) a UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      email: map['email'] as String?,
      passwordHash: map['password_hash'] as String,
      isGuest: map['is_guest'] == 1,
      isPremium: map['is_premium'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastLogin: DateTime.parse(map['last_login'] as String),
      streakDays: map['streak_days'] as int? ?? 0,
      cloudId: map['cloud_id'] as String?,
      isSynced: map['is_synced'] == 1,
      lastSyncAt: map['last_sync_at'] != null
          ? DateTime.parse(map['last_sync_at'] as String)
          : null,
    );
  }

  /// Convertir de UserModel a Map (base de datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password_hash': passwordHash,
      'is_guest': isGuest ? 1 : 0,
      'is_premium': isPremium ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin.toIso8601String(),
      'streak_days': streakDays,
      'cloud_id': cloudId,
      'is_synced': isSynced ? 1 : 0,
      'last_sync_at': lastSyncAt?.toIso8601String(),
    };
  }

  /// Crear una copia del usuario con campos modificados
  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? passwordHash,
    bool? isGuest,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? lastLogin,
    int? streakDays,
    String? cloudId,
    bool? isSynced,
    DateTime? lastSyncAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      isGuest: isGuest ?? this.isGuest,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      streakDays: streakDays ?? this.streakDays,
      cloudId: cloudId ?? this.cloudId,
      isSynced: isSynced ?? this.isSynced,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  /// Crear un usuario invitado
  factory UserModel.guest() {
    final now = DateTime.now();
    return UserModel(
      username: 'Invitado_${now.millisecondsSinceEpoch}',
      passwordHash: '',
      isGuest: true,
      createdAt: now,
      lastLogin: now,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email, isGuest: $isGuest, isPremium: $isPremium)';
  }
}
