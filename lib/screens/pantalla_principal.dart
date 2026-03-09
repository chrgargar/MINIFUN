import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_logger.dart';
import '../widgets/tarjetas_juegos.dart';
import '../widgets/boton_ajustes.dart';
import '../tema/language_provider.dart';
import '../tema/audio_settings.dart';
import '../constants/app_strings.dart';
import '../services/audio_service.dart';
import '../providers/auth_provider.dart';
import 'pantalla_perfil.dart';

// Pantalla principal
class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  @override
  void initState() {
    super.initState();
    appLogger.setCurrentScreen('PantallaPrincipal');
    _startBackgroundMusic();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AudioSettings>(context, listen: false).addListener(_onAudioSettingsChanged);
    });
  }

  @override
  void dispose() {
    try {
      Provider.of<AudioSettings>(context, listen: false).removeListener(_onAudioSettingsChanged);
    } catch (e) {}
    super.dispose();
  }

  void _onAudioSettingsChanged() {
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    AudioService.setLoopVolume(audioSettings.musicVolume);
  }

  void _startBackgroundMusic() {
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    AudioService.playLoop('Sonidos/music_menu.mp3', audioSettings.musicVolume);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLang = Provider.of<LanguageProvider>(context).currentLanguage;

    return Scaffold(
      extendBodyBehindAppBar: true, // Extender el body detrás del AppBar
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white, // Color de fondo base

      // Barra superior de la app
      appBar: AppBar(
        elevation: 0, // Sin sombra
        automaticallyImplyLeading: false, // Sin botón de retroceso
        backgroundColor: Colors.transparent, // Fondo transparente para ver la imagen
        toolbarHeight: 72,

        // Avatar del usuario en la esquina superior izquierda
        leading: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.currentUser;
            return GestureDetector(
              onTap: () {
                if (user != null && !user.isGuest) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PantallaPerfil()),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF7B3FF2).withValues(alpha: 0.2),
                  backgroundImage: user?.avatarBase64 != null
                      ? MemoryImage(base64Decode(user!.avatarBase64!.split(',').last))
                      : null,
                  child: user?.avatarBase64 == null
                      ? const Icon(Icons.person, color: Color(0xFF7B3FF2), size: 20)
                      : null,
                ),
              ),
            );
          },
        ),

        // Título con nombre del usuario
        title: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final username = authProvider.currentUser?.username;
            final isAdmin = authProvider.isAdmin;
            final isPremium = authProvider.isPremium;

            // Color del nombre según rol
            Color usernameColor;
            if (isAdmin) {
              usernameColor = const Color(0xFFFF5555); // Rojo admin
            } else if (isPremium) {
              usernameColor = const Color(0xFFDDD605); // Amarillo premium
            } else {
              usernameColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'MINIFUN',
                  style: TextStyle(
                    color: Color(0xFF7B3FF2),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                if (username != null)
                  Text(
                    username,
                    style: TextStyle(
                      color: usernameColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            );
          },
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
              opacity: isDark ? 0.15 : 0.5,
              child: Image.asset(
                'assets/imagenes/fondo.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Contenido sobre la imagen
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Distribución porcentual de la altura
                double availableHeight = constraints.maxHeight;
                double bannerHeight = availableHeight * 0.08; // 8% para banner PRO
                double gridHeight = availableHeight * 0.70; // 70% para grid de juegos
                double missionsHeight = availableHeight * 0.18; // 18% para misiones

                // Calcular tamaño de cada celda del grid (2x3 = 6 juegos)
                double gridPadding = constraints.maxWidth * 0.04;
                double cellSpacing = gridHeight * 0.03;
                double cellHeight = (gridHeight - (cellSpacing * 4)) / 3; // 3 filas

                return Padding(
                  padding: EdgeInsets.all(gridPadding),
                  child: Column(
                    children: [
                      // Banner MINIFUN PRO (oculto para admins y premium)
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          if (authProvider.isAdmin || authProvider.isPremium) {
                            return const SizedBox.shrink();
                          }
                          return SizedBox(
                            height: bannerHeight,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: constraints.maxWidth * 0.04,
                                vertical: bannerHeight * 0.15,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color.fromARGB(255, 180, 169, 69) // Amarillo oscurecido
                                    : const Color.fromARGB(255, 255, 239, 98),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      AppStrings.get('get_pro', currentLang),
                                      style: TextStyle(
                                        fontSize: (bannerHeight * 0.25).clamp(12.0, 14.0),
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: bannerHeight * 0.2,
                                      vertical: bannerHeight * 0.1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF7B3FF2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      AppStrings.get('pro_price', currentLang),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: (bannerHeight * 0.25).clamp(12.0, 14.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          if (authProvider.isAdmin || authProvider.isPremium) {
                            // Mitad del espacio arriba para centrar
                            return SizedBox(height: (bannerHeight + cellSpacing) / 2);
                          }
                          return SizedBox(height: cellSpacing);
                        },
                      ),

                      // Grid de juegos
                      SizedBox(
                        height: gridHeight,
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: cellSpacing,
                          crossAxisSpacing: cellSpacing,
                          childAspectRatio: (constraints.maxWidth / 2 - gridPadding) / cellHeight,
                          children: [
                            TarjetasJuegos(title: AppStrings.get('game_snake', currentLang), gameKey: 'Snake', imagePath: 'assets/imagenes/sssnake.png'),
                            TarjetasJuegos(title: AppStrings.get('game_watersort', currentLang), gameKey: 'WaterSort', imagePath: 'assets/imagenes/watersort.png'),
                            TarjetasJuegos(title: AppStrings.get('game_word_search', currentLang), gameKey: 'Sopa de Letras', imagePath: 'assets/imagenes/sopadeletras.png'),
                            TarjetasJuegos(title: AppStrings.get('game_hangman', currentLang), gameKey: 'Ahorcado', imagePath: 'assets/imagenes/ahorcado.png'),
                            TarjetasJuegos(title: AppStrings.get('game_minesweeper', currentLang), gameKey: 'Buscaminas', imagePath: 'assets/imagenes/buscaminas.png'),
                            TarjetasJuegos(title: AppStrings.get('game_sudoku', currentLang), gameKey: 'Sudoku', imagePath: 'assets/imagenes/sudoku.png'),
                          ],
                        ),
                      ),

                      SizedBox(height: cellSpacing),

                      // Espacio extra abajo para centrar cuando no hay banner
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          if (authProvider.isAdmin || authProvider.isPremium) {
                            return SizedBox(height: (bannerHeight + cellSpacing) / 2);
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // Sección de misiones
                      SizedBox(
                        height: missionsHeight,
                        child: Column(
                          children: [
                            // Título MISIONES
                            Container(
                              width: double.infinity,
                              height: missionsHeight * 0.4,
                              padding: EdgeInsets.all(missionsHeight * 0.08),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF2D1B3D)
                                    : const Color(0xFFF3E5F5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  AppStrings.get('missions', currentLang),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFF7B3FF2),
                                    fontSize: (missionsHeight * 0.15).clamp(14.0, 18.0),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: missionsHeight * 0.12),

                            // Barra de progreso
                            Container(
                              width: double.infinity,
                              height: missionsHeight * 0.35,
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
                                  Center(
                                    child: Text(
                                      '3/4',
                                      style: TextStyle(
                                        color: const Color(0xFF7B3FF2),
                                        fontSize: (missionsHeight * 0.18).clamp(16.0, 20.0),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
