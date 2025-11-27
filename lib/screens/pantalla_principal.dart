import 'package:flutter/material.dart';
import '../widgets/tarjetas_juegos.dart';
import '../widgets/boton_ajustes.dart';

class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: const Text(
          'MINIFUN',
          style: TextStyle(
            color: Color(0xFF7B3FF2),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: const BotonAjustes(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.15 : 0.5,
              child: Image.asset(
                'assets/imagenes/fondo.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Banner
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
                            color: Colors.black,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7B3FF2),
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
                  const SizedBox(height: 24),

                  // Grid de juegos
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    children: [
                      TarjetasJuegos(
                        title: 'Snake',
                        imagePath: 'assets/imagenes/sssnake.png',
                        onTap: () => Navigator.pushNamed(context, '/snake'),
                      ),
                      TarjetasJuegos(title: 'WaterSort', imagePath: 'assets/imagenes/watersort.png'),
                      TarjetasJuegos(title: 'Sopa de Letras', imagePath: 'assets/imagenes/sopadeletras.png'),
                      TarjetasJuegos(title: 'Ahorcado', imagePath: 'assets/imagenes/ahorcado.png'),
                      TarjetasJuegos(title: 'Buscaminas', imagePath: 'assets/imagenes/buscaminas.png'),
                      TarjetasJuegos(title: 'Sudoku', imagePath: 'assets/imagenes/sudoku.png'),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Misiones
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2D1B3D) : const Color(0xFFF3E5F5),
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
                  const SizedBox(height: 16),

                  // Barra de progreso
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
                        FractionallySizedBox(
                          widthFactor: 0.75,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF7B3FF2),
                              borderRadius: BorderRadius.circular(23),
                            ),
                          ),
                        ),
                        const Center(
                          child: Text(
                            '3/4',
                            style: TextStyle(
                              color: Color(0xFF7B3FF2),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

