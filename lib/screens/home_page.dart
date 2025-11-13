import 'package:flutter/material.dart';
import '../widgets/game_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
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
          IconButton(
            onPressed: () {},
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF7B3FF2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9C4),
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
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: [
                GameCard(title: 'Snake', imagePath: 'assets/imagenes/sssnake.png'),
                GameCard(title: 'WaterSort', imagePath: 'assets/imagenes/watersort.png'),
                GameCard(title: 'Sopa de Letras', imagePath: 'assets/imagenes/sopadeletras.png'),
                GameCard(title: 'Ahorcado', imagePath: 'assets/imagenes/cuandovoyaclase.png'),
                GameCard(title: 'Buscaminas', imagePath: 'assets/imagenes/buscamainas.png'),
                GameCard(title: 'Sudoku', imagePath: 'assets/imagenes/sudoku.png'),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
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
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey[300]!, width: 2),
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
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
