import 'package:flutter_test/flutter_test.dart';
import 'package:MINIFUN/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    group('validateUsername', () {
      test('Debe retornar null para username válido', () {
        expect(Validators.validateUsername('usuario123'), null);
        expect(Validators.validateUsername('abc'), null);
      });

      test('Debe retornar error si username es null o vacío', () {
        expect(Validators.validateUsername(null), isNotNull);
        expect(Validators.validateUsername(''), isNotNull);
      });

      test('Debe retornar error si username es muy corto', () {
        expect(Validators.validateUsername('ab'), isNotNull);
        expect(Validators.validateUsername('a'), isNotNull);
      });
    });

    group('validateEmail', () {
      test('Debe retornar null para email válido', () {
        expect(Validators.validateEmail('test@example.com'), null);
        expect(Validators.validateEmail('user.name@domain.co'), null);
      });

      test('Debe retornar error para email inválido', () {
        expect(Validators.validateEmail('invalidemail'), isNotNull);
        expect(Validators.validateEmail('test@'), isNotNull);
        expect(Validators.validateEmail('@example.com'), isNotNull);
      });

      test('Debe retornar error si email es null o vacío', () {
        expect(Validators.validateEmail(null), isNotNull);
        expect(Validators.validateEmail(''), isNotNull);
      });
    });

    group('validatePassword', () {
      test('Debe retornar null para password válido', () {
        expect(Validators.validatePassword('password123'), null);
        expect(Validators.validatePassword('123456'), null);
      });

      test('Debe retornar error si password es muy corto', () {
        expect(Validators.validatePassword('12345'), isNotNull);
        expect(Validators.validatePassword('abc'), isNotNull);
      });

      test('Debe retornar error si password es null o vacío', () {
        expect(Validators.validatePassword(null), isNotNull);
        expect(Validators.validatePassword(''), isNotNull);
      });
    });

    group('validatePasswordMatch', () {
      test('Debe retornar null si las contraseñas coinciden', () {
        expect(Validators.validatePasswordMatch('password123', 'password123'), null);
      });

      test('Debe retornar error si las contraseñas no coinciden', () {
        expect(Validators.validatePasswordMatch('password123', 'different'), isNotNull);
      });
    });
  });
}
