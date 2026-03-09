import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/pantalla_login.dart';
import 'tema/selectorTema.dart';
import 'tema/audio_settings.dart';
import 'tema/language_provider.dart';
import 'providers/auth_provider.dart';
import 'utils/app_logger.dart';
import 'constants/api_constants.dart';

// Función principal que se ejecuta al iniciar la app
void main() async {
  // Asegurar que los widgets de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Bloquear orientación a vertical (portrait)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Ocultar barra de estado y barra de navegación (pantalla completa)
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Inicializar el logger
  await appLogger.initialize(isDevelopment: ApiConstants.isDevelopment);

  // Inicializar sqflite solo para desktop (Windows, macOS, Linux)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Configurar captura de errores de Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    // Capturar error en el logger
    appLogger.captureFlutterError(details);
    // También mostrar en consola en modo debug
    FlutterError.presentError(details);
  };

  // Ejecutar la app dentro de una zona que captura errores no manejados
  runZonedGuarded(
    () {
      runApp(
        // MultiProvider permite compartir múltiples estados en toda la app
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => SelectorTema()),
            ChangeNotifierProvider(create: (context) => AudioSettings()),
            ChangeNotifierProvider(create: (context) => LanguageProvider()),
            ChangeNotifierProvider(create: (context) => AuthProvider()),
          ],
          child: const MyApp(),
        ),
      );
    },
    (error, stackTrace) {
      // Capturar cualquier error de Dart no manejado
      appLogger.captureDartError(error, stackTrace);
    },
  );
}

// Widget principal de la aplicación
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectorTema>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'MINIFUN', // Nombre de la app
          debugShowCheckedModeBanner: false, // Oculta el banner de "DEBUG" en la esquina

          // Observer para rastrear navegación automáticamente
          navigatorObservers: [LoggerNavigatorObserver()],

          // Tema claro
          theme: ThemeData(
            primarySwatch: Colors.purple, // Color principal de la app (morado)
            useMaterial3: true, // Usa el nuevo diseño Material 3
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),

          // Tema oscuro
          darkTheme: ThemeData(
            primarySwatch: Colors.purple, // Color principal de la app (morado)
            useMaterial3: true, // Usa el nuevo diseño Material 3
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
            ),
          ),

          themeMode: themeProvider.themeMode, // Tema actual (claro/oscuro)
          home: const PantallaLogin(), // Primera pantalla que se muestra al abrir la app
        );
      },
    );
  }
}
