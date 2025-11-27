import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/pantalla_login.dart';
import 'screens/pantalla_principal.dart';
import 'juegos/snake.dart';
import 'tema/selectorTema.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => SelectorTema(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectorTema>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'MINIFUN',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.purple,
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.purple,
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
            ),
          ),
          themeMode: themeProvider.themeMode,

          routes: {
            '/': (context) => const PantallaLogin(),
            '/principal': (context) => const PantallaPrincipal(),
            '/snake': (context) => const SnakeGame(), // 👈 Ruta al juego
          },
          initialRoute: '/',
        );
      },
    );
  }
}
