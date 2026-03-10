import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_logger.dart';
import '../widgets/tarjetas_juegos.dart';
import '../widgets/boton_ajustes.dart';
import '../config/language_provider.dart';
import '../config/audio_settings.dart';
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
    appLogger.setCurrentScreen('PantallaPrincipal');
    _startBackgroundMusic();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AudioSettings>(context, listen: false).addListener(_onAudioSettingsChanged);

      // Inicializar misiones si el usuario está autenticado
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        Provider.of<MissionProvider>(context, listen: false).init(authProvider.currentUser!.id);
      }
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

  void _showMissionsDialog(BuildContext context, MissionProvider missionProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Título con racha
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.get('daily_missions', currentLang),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  if (missionProvider.streak > 0) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${missionProvider.streak} ${AppStrings.get('days', currentLang)}',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),

              // Lista de misiones
              ...missionProvider.dailyMissions.map((mission) {
                final progress = mission.progress / mission.goal;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: mission.isCompleted
                        ? Colors.green.withOpacity(0.1)
                        : (isDark ? Colors.grey[800] : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: mission.isCompleted ? Colors.green : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icono de estado
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: mission.isCompleted
                              ? Colors.green
                              : const Color(0xFF7B3FF2).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          mission.isCompleted ? Icons.check : _getGameIcon(mission.gameType),
                          color: mission.isCompleted ? Colors.white : const Color(0xFF7B3FF2),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Título y progreso
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.get(mission.titleKey, currentLang),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : Colors.black,
                                decoration: mission.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Barra de progreso pequeña
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  mission.isCompleted ? Colors.green : const Color(0xFF7B3FF2),
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Contador
                      Text(
                        '${mission.progress}/${mission.goal}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: mission.isCompleted ? Colors.green : const Color(0xFF7B3FF2),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  IconData _getGameIcon(String gameType) {
    switch (gameType) {
      case 'snake':
        return Icons.pest_control;
      case 'watersort':
        return Icons.water_drop;
      case 'sudoku':
        return Icons.grid_3x3;
      case 'ahorcado':
        return Icons.text_fields;
      case 'buscaminas':
        return Icons.flag;
      case 'sopadeletras':
        return Icons.abc;
      case 'any':
        return Icons.games;
      default:
        return Icons.star;
    }
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
                double bannerHeight = availableHeight * 0.07; // 7% para banner PRO
                double gridHeight = availableHeight * 0.68; // 68% para grid de juegos
                double missionsHeight = availableHeight * 0.15; // 15% para misiones

                // Calcular tamaño de cada celda del grid (2x3 = 6 juegos)
                double gridPadding = constraints.maxWidth * 0.04;
                double cellSpacing = gridHeight * 0.025;
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
                        child: Consumer<MissionProvider>(
                          builder: (context, missionProvider, child) {
                            return Column(
                              children: [
                                // Título MISIONES
                                GestureDetector(
                                  onTap: () => _showMissionsDialog(context, missionProvider),
                                  child: Container(
                                    width: double.infinity,
                                    height: missionsHeight * 0.45,
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
                                          fontSize: (missionsHeight * 0.18).clamp(14.0, 18.0),
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: missionsHeight * 0.1),

                                // Barra de progreso
                                GestureDetector(
                                  onTap: () => _showMissionsDialog(context, missionProvider),
                                  child: Container(
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
                                        FractionallySizedBox(
                                          widthFactor: missionProvider.isLoading ? 0 : missionProvider.progressPercentage,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF7B3FF2),
                                              borderRadius: BorderRadius.circular(23),
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: missionProvider.isLoading
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(strokeWidth: 2),
                                                )
                                              : Text(
                                                  '${missionProvider.completedMissionsCount}/${missionProvider.totalMissionsCount}',
                                                  style: TextStyle(
                                                    color: missionProvider.progressPercentage > 0.5
                                                        ? Colors.white
                                                        : const Color(0xFF7B3FF2),
                                                    fontSize: (missionsHeight * 0.2).clamp(16.0, 20.0),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                        ),
                                      ],
                                    ),
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
