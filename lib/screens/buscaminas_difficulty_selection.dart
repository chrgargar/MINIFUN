import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../juegos/buscaminas.dart';
import '../widgets/boton_ajustes.dart';
import '../tema/language_provider.dart';

class BuscaminasDifficultySelection extends StatelessWidget {
  const BuscaminasDifficultySelection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLang = Provider.of<LanguageProvider>(context).currentLanguage;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double availableHeight = constraints.maxHeight;
            double headerHeight = availableHeight * 0.08;
            double titleHeight = availableHeight * 0.12;
            double buttonsAreaHeight = availableHeight * 0.70;

            // 3 difficulty buttons + spacing
            double totalSpacing = buttonsAreaHeight * 0.15;
            double spacing = totalSpacing / 4;
            double buttonHeight = (buttonsAreaHeight - totalSpacing) / 3;
            buttonHeight = buttonHeight.clamp(60.0, 80.0);

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth * 0.06,
                vertical: availableHeight * 0.015,
              ),
              child: Column(
                children: [
                  // Header
                  SizedBox(
                    height: headerHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios, size: 24),
                        ),
                        const BotonAjustes(),
                      ],
                    ),
                  ),

                  // Title
                  SizedBox(
                    height: titleHeight,
                    child: Center(
                      child: Text(
                        'Selecciona Dificultad',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: (titleHeight * 0.35).clamp(20.0, 28.0),
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: spacing),

                  // Difficulty Buttons
                  Expanded(
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        // Fácil Button
                        _buildDifficultyButton(
                          height: buttonHeight,
                          icon: '😊',
                          text: 'Fácil',
                          description: '10x10 - 15 minas',
                          color: const Color(0xFF7B3FF2),
                          textColor: Colors.white,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BuscaminasGame.facil,
                              ),
                            );
                          },
                        ),

                        SizedBox(height: spacing),

                        // Medio Button
                        _buildDifficultyButton(
                          height: buttonHeight,
                          icon: '🎯',
                          text: 'Medio',
                          description: '16x16 - 40 minas',
                          color: const Color(0xFF7B3FF2),
                          textColor: Colors.white,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BuscaminasGame.medio,
                              ),
                            );
                          },
                        ),

                        SizedBox(height: spacing),

                        // Difícil Button
                        _buildDifficultyButton(
                          height: buttonHeight,
                          icon: '🔥',
                          text: 'Difícil',
                          description: '24x24 - 99 minas',
                          color: const Color(0xFF7B3FF2),
                          textColor: Colors.white,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BuscaminasGame.dificil,
                              ),
                            );
                          },
                        ),

                        SizedBox(height: spacing),

                        // Extremo Button
                        _buildDifficultyButton(
                          height: buttonHeight,
                          icon: '👑',
                          text: 'Extremo',
                          description: '35x35 - 300 minas',
                          color: const Color(0xFF7B3FF2),
                          textColor: Colors.white,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BuscaminasGame.extremo,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: spacing),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDifficultyButton({
    required double height,
    required String icon,
    required String text,
    required String description,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                icon,
                style: TextStyle(fontSize: height * 0.35),
              ),
              SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: height * 0.28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: height * 0.18,
                      color: textColor.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
