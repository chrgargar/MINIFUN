import 'package:flutter_test/flutter_test.dart';
import 'package:MINIFUN/providers/auth_provider.dart';

void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    test('Estado inicial debe ser correcto', () {
      expect(authProvider.currentUser, isNull);
      expect(authProvider.isLoggedIn, false);
      expect(authProvider.isLoading, false);
      expect(authProvider.errorMessage, isNull);
    });

    test('isGuest debe retornar false cuando no hay usuario', () {
      expect(authProvider.isGuest, false);
    });

    test('isPremium debe retornar false cuando no hay usuario', () {
      expect(authProvider.isPremium, false);
    });

    test('clearError debe limpiar el mensaje de error', () {
      authProvider.clearError();
      expect(authProvider.errorMessage, isNull);
    });

    test('AuthProvider debe ser un ChangeNotifier', () {
      expect(authProvider, isA<AuthProvider>());
    });
  });
}
