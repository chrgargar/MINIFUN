import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'screens/pantalla_login.dart';
import 'tema/selectorTema.dart';
import 'tema/audio_settings.dart';
import 'providers/auth_provider.dart';

// Función principal que se ejecuta al iniciar la app
void main() async {
  // Asegurar que los widgets de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar sqflite
  await databaseFactory.setDatabasesPath(await getDatabasesPath());

  runApp(
    // MultiProvider permite compartir múltiples estados en toda la app
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SelectorTema()),
        ChangeNotifierProvider(create: (context) => AudioSettings()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
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
