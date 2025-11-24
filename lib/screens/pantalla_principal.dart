import 'package:flutter/material.dart';
import '../widgets/tarjetas_juegos.dart';
import '../widgets/boton_ajustes.dart';

// Pantalla principal
class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true, // Extender el body detrás del AppBar
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white, // Color de fondo base

      // Barra superior de la app
      appBar: AppBar(
        elevation: 0, // Sin sombra
        automaticallyImplyLeading: false, // Sin botón de retroceso
        backgroundColor: Colors.transparent, // Fondo transparente para ver la imagen

        // Título de la app
        title: const Text(
          'MINIFUN',
          style: TextStyle(
            color: Color(0xFF7B3FF2), // Color morado
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2, // Espaciado entre letras del titulo
          ),
        ),
        centerTitle: true, // Para centrarlo

        // Botón de configuración de la esquina superior derecha
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: const BotonAjustes(),
          ),
        ],
      ),

      // Contenido principal con imagen de fondo
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.15 : 0.5, // Filtro medio en modo claro, filtro suave en modo oscuro
              child: Image.asset(
                'assets/imagenes/fondo.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Contenido sobre la imagen
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
          children: [
            // Banner para adquirir minifun pro
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 239, 98),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Adquiere MINIFUN PRO por',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black, // Siempre negro
                    ),
                  ),
                  //Botón con el precio
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B3FF2), // Morado
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '€4.99',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24), // Altura

            // Grid para la cuadricula de los juego
            GridView.count(
              shrinkWrap: true, // Se ajusta al contenido
              physics: const NeverScrollableScrollPhysics(), // Sin scroll propio
              crossAxisCount: 2, // 2 columnas
              mainAxisSpacing: 20, // Espacio vertical entre tarjetas
              crossAxisSpacing: 20, // Espacio horizontal entre tarjetas
              children: [
                TarjetasJuegos(title: 'Snake', imagePath: 'assets/imagenes/sssnake.png'),
                TarjetasJuegos(title: 'WaterSort', imagePath: 'assets/imagenes/watersort.png'),
                TarjetasJuegos(title: 'Sopa de Letras', imagePath: 'assets/imagenes/sopadeletras.png'),
                TarjetasJuegos(title: 'Ahorcado', imagePath: 'assets/imagenes/ahorcado.png'),
                TarjetasJuegos(title: 'Buscaminas', imagePath: 'assets/imagenes/buscaminas.png'),
                TarjetasJuegos(title: 'Sudoku', imagePath: 'assets/imagenes/sudoku.png'),
              ],
            ),

            const SizedBox(height: 30), // Espacio vertical

            // Sección de misiones - Título
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2D1B3D)
                    : const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'MISIONES',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF7B3FF2),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),

            const SizedBox(height: 16), // Espacio vertical

            // Barra de progreso de misiones (3 de 4 completadas)
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  // Relleno de la barra (75% = 3/4)
                  FractionallySizedBox(
                    widthFactor: 0.75, // 75% del ancho
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B3FF2), // Morado
                        borderRadius: BorderRadius.circular(23),
                      ),
                    ),
                  ),
                  // Texto centrado sobre la barra
                  Center(
                    child: Text(
                      '3/4',
                      style: TextStyle(
                        color: const Color(0xFF7B3FF2),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30), // Espacio final
          ],
        ),
            ),
          ),
        ],
      ),
    );
  }
}
