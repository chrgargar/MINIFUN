// Test básico para verificar que la aplicación se puede crear

import 'package:flutter_test/flutter_test.dart';
import 'package:MINIFUN/main.dart';

void main() {
  testWidgets('La aplicación MINIFUN se puede crear', (WidgetTester tester) async {
    // Verificar que MyApp se puede instanciar
    const app = MyApp();
    expect(app, isNotNull);
  });
}
