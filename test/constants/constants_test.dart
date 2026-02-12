import 'package:flutter_test/flutter_test.dart';
import 'package:MINIFUN/constants/api_constants.dart';

void main() {
  group('ApiConstants Tests', () {
    test('URLs base deben estar definidas correctamente', () {
      expect(ApiConstants.baseUrl, isNotEmpty);
      expect(ApiConstants.baseUrl, contains('api'));
    });

    test('Endpoints de autenticación deben estar definidos', () {
      expect(ApiConstants.authRegister, '/auth/register');
      expect(ApiConstants.authLogin, '/auth/login');
      expect(ApiConstants.authMe, '/auth/me');
      expect(ApiConstants.authLogout, '/auth/logout');
    });

    test('Timeouts deben tener valores razonables', () {
      expect(ApiConstants.requestTimeout, greaterThan(0));
      expect(ApiConstants.authTimeout, greaterThan(0));
      expect(ApiConstants.uploadTimeout, greaterThan(ApiConstants.requestTimeout));
    });

    test('bearerToken debe formatear correctamente', () {
      final token = 'test_token_123';
      final bearerToken = ApiConstants.bearerToken(token);
      
      expect(bearerToken, 'Bearer test_token_123');
      expect(bearerToken, startsWith('Bearer '));
    });

    test('Códigos HTTP deben estar correctamente definidos', () {
      expect(ApiConstants.httpOk, 200);
      expect(ApiConstants.httpCreated, 201);
      expect(ApiConstants.httpBadRequest, 400);
      expect(ApiConstants.httpUnauthorized, 401);
      expect(ApiConstants.httpInternalError, 500);
    });
  });
}
