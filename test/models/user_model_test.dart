import 'package:flutter_test/flutter_test.dart';
import 'package:MINIFUN/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('Crear usuario con todos los campos', () {
      final now = DateTime.now();
      final user = UserModel(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        passwordHash: 'hashedpassword',
        isGuest: false,
        isPremium: true,
        createdAt: now,
        lastLogin: now,
        streakDays: 5,
        cloudId: 'cloud123',
        isSynced: true,
        lastSyncAt: now,
      );

      expect(user.id, 1);
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
      expect(user.isPremium, true);
      expect(user.streakDays, 5);
    });

    test('Convertir UserModel a Map correctamente', () {
      final now = DateTime.now();
      final user = UserModel(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        passwordHash: 'hashedpassword',
        isGuest: false,
        isPremium: true,
        createdAt: now,
        lastLogin: now,
      );

      final map = user.toMap();

      expect(map['id'], 1);
      expect(map['username'], 'testuser');
      expect(map['email'], 'test@example.com');
      expect(map['is_premium'], 1);
      expect(map['is_guest'], 0);
    });

    test('Convertir Map a UserModel correctamente', () {
      final now = DateTime.now();
      final map = {
        'id': 1,
        'username': 'testuser',
        'email': 'test@example.com',
        'password_hash': 'hashedpassword',
        'is_guest': 0,
        'is_premium': 1,
        'created_at': now.toIso8601String(),
        'last_login': now.toIso8601String(),
        'streak_days': 5,
        'cloud_id': 'cloud123',
        'is_synced': 1,
        'last_sync_at': now.toIso8601String(),
      };

      final user = UserModel.fromMap(map);

      expect(user.id, 1);
      expect(user.username, 'testuser');
      expect(user.isPremium, true);
      expect(user.isGuest, false);
      expect(user.streakDays, 5);
    });

    test('Crear usuario invitado con factory guest()', () {
      final guestUser = UserModel.guest();

      expect(guestUser.isGuest, true);
      expect(guestUser.username, contains('Invitado_'));
      expect(guestUser.passwordHash, '');
      expect(guestUser.isPremium, false);
    });

    test('CopyWith debe crear una copia con campos modificados', () {
      final now = DateTime.now();
      final user = UserModel(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        passwordHash: 'hashedpassword',
        createdAt: now,
        lastLogin: now,
      );

      final updatedUser = user.copyWith(
        username: 'newusername',
        isPremium: true,
      );

      expect(updatedUser.username, 'newusername');
      expect(updatedUser.isPremium, true);
      expect(updatedUser.id, 1); // Los demás campos se mantienen
      expect(updatedUser.email, 'test@example.com');
    });
  });
}
