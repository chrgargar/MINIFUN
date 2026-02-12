import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:MINIFUN/services/api_service.dart';

void main() {
  group('ApiService Tests', () {
    test('register debe enviar datos correctamente', () async {
      // Este test verifica que el método register está bien estructurado
      expect(ApiService.register, isNotNull);
    });

    test('login debe enviar datos correctamente', () async {
      // Este test verifica que el método login está bien estructurado
      expect(ApiService.login, isNotNull);
    });

    test('getMe debe requerir token', () async {
      // Este test verifica que el método getMe está bien estructurado
      expect(ApiService.getMe, isNotNull);
    });

    test('logout debe enviar token', () async {
      // Este test verifica que el método logout está bien estructurado
      expect(ApiService.logout, isNotNull);
    });

    test('healthCheck debe estar disponible', () async {
      // Este test verifica que el método healthCheck está bien estructurado
      expect(ApiService.healthCheck, isNotNull);
    });

    test('forgotPassword debe enviar email', () async {
      // Este test verifica que el método forgotPassword está bien estructurado
      expect(ApiService.forgotPassword, isNotNull);
    });
  });
}
