import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/tarjetas_juegos.dart';
import '../widgets/boton_ajustes.dart';
import '../tema/language_provider.dart';
import '../tema/audio_settings.dart';
import '../constants/app_strings.dart';
import '../services/audio_service.dart';
import '../providers/auth_provider.dart';
import '../providers/mission_provider.dart';
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
    _startBackgroundMusic();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null && !authProvider.isGuest) {
        Provider.of<MissionProvider>(context, listen: false).init(authProvider.currentUser!.id);
      }
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
    AudioService.playLoop('Sonidos/music.mp3', audioSettings.musicVolume);
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

        // Título con nombre del usuario y racha
        title: Consumer2<AuthProvider, MissionProvider>(
          builder: (context, authProvider, missionProvider, child) {
            final user = authProvider.currentUser;
            final username = user?.username;
            final isGuest = authProvider.isGuest;
            
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
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
                    if (!isGuest && missionProvider.streak > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 2),
                            Text(
                              '${missionProvider.streak}',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                if (username != null)
                  Text(
                    username,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
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
                      // Banner MINIFUN PRO
                      SizedBox(
                        height: bannerHeight,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: constraints.maxWidth * 0.04,
                            vertical: bannerHeight * 0.15,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 239, 98),
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
                                    color: Colors.black,
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
                                  '€4.99',
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
                      ),

                      SizedBox(height: cellSpacing),

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
                          children: const [
                            TarjetasJuegos(title: 'Snake', imagePath: 'assets/imagenes/sssnake.png'),
                            TarjetasJuegos(title: 'WaterSort', imagePath: 'assets/imagenes/watersort.png'),
                            TarjetasJuegos(title: 'Sopa de Letras', imagePath: 'assets/imagenes/sopadeletras.png'),
                            TarjetasJuegos(title: 'Ahorcado', imagePath: 'assets/imagenes/ahorcado.png'),
                            TarjetasJuegos(title: 'Buscaminas', imagePath: 'assets/imagenes/buscaminas.png'),
                            TarjetasJuegos(title: 'Sudoku', imagePath: 'assets/imagenes/sudoku.png'),
                          ],
                        ),
                      ),

                      SizedBox(height: cellSpacing),

                      // Sección de misiones
                      SizedBox(
                        height: missionsHeight,
                        child: Consumer2<AuthProvider, MissionProvider>(
                          builder: (context, auth, missionProv, child) {
                            if (auth.isGuest) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF2D1B3D) : const Color(0xFFF3E5F5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.lock, color: Color(0xFF7B3FF2), size: 24),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Inicia sesión para jugar misiones y ganar rachas',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(0xFF7B3FF2),
                                        fontSize: (missionsHeight * 0.12).clamp(12.0, 14.0),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            final completed = missionProv.completedMissionsCount;
                            final total = missionProv.dailyMissions.length;
                            final percentage = missionProv.progressPercentage;

                            return Column(
                              children: [
                                // Título MISIONES
                                Container(
                                  width: double.infinity,
                                  height: missionsHeight * 0.45,
                                  padding: EdgeInsets.symmetric(horizontal: missionsHeight * 0.1, vertical: missionsHeight * 0.05),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF2D1B3D) : const Color(0xFFF3E5F5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppStrings.get('missions', currentLang),
                                        style: TextStyle(
                                          color: const Color(0xFF7B3FF2),
                                          fontSize: (missionsHeight * 0.12).clamp(14.0, 16.0),
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      if (total > 0)
                                        Text(
                                          missionProv.dailyMissions.firstWhere((m) => !m.isCompleted, orElse: () => missionProv.dailyMissions.last).title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                                            fontSize: (missionsHeight * 0.1).clamp(10.0, 12.0),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: missionsHeight * 0.1),

                                // Barra de progreso
                                Container(
                                  width: double.infinity,
                                  height: missionsHeight * 0.4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          return AnimatedContainer(
                                            duration: const Duration(milliseconds: 500),
                                            width: constraints.maxWidth * percentage,
                                            decoration: BoxDecoration(
                                              color: percentage == 1.0 ? Colors.green : const Color(0xFF7B3FF2),
                                              borderRadius: BorderRadius.circular(23),
                                            ),
                                          );
                                        },
                                      ),
                                      Center(
                                        child: Text(
                                          '$completed/$total',
                                          style: TextStyle(
                                            color: percentage > 0.5 ? Colors.white : const Color(0xFF7B3FF2),
                                            fontSize: (missionsHeight * 0.18).clamp(16.0, 20.0),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
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
