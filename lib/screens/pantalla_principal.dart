import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 500),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título con animación
                Text(
                  AppStrings.get('daily_missions', currentLang),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: -0.2, end: 0),
                const SizedBox(height: 8),

                // Racha de días
                if (missionProvider.streak > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B3FF2).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department, color: Color(0xFF7B3FF2), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '${missionProvider.streak} ${AppStrings.get('days', currentLang)}',
                          style: const TextStyle(
                            color: Color(0xFF7B3FF2),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),

                // Lista de misiones
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: missionProvider.dailyMissions.map((mission) {
                        final progress = mission.progress / mission.goal;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              // Icono en contenedor estilo app
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: mission.isCompleted
                                      ? const Color(0xFF7B3FF2)
                                      : const Color(0xFF7B3FF2).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  mission.isCompleted ? Icons.check : _getGameIcon(mission.gameType),
                                  color: mission.isCompleted ? Colors.white : const Color(0xFF7B3FF2),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Título y barra de progreso
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.get(mission.titleKey, currentLang),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : Colors.black,
                                        decoration: mission.isCompleted ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Barra de progreso
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: const Color(0xFF7B3FF2).withValues(alpha: 0.2),
                                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7B3FF2)),
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Contador
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7B3FF2).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${mission.progress}/${mission.goal}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7B3FF2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Botón cerrar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B3FF2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      AppStrings.get('close', currentLang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 300.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 200.ms);
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

  void _showProBenefitsDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.star, color: Color(0xFFFFD700), size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.get('pro_benefits_title', currentLang),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.get('pro_benefits_intro', currentLang),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              _buildBenefitItem('🐍', AppStrings.get('pro_benefit_snake', currentLang), isDark),
              _buildBenefitItem('🧪', AppStrings.get('pro_benefit_watersort', currentLang), isDark),
              _buildBenefitItem('🔤', AppStrings.get('pro_benefit_wordsearch', currentLang), isDark),
              _buildBenefitItem('💀', AppStrings.get('pro_benefit_hangman', currentLang), isDark),
              _buildBenefitItem('💣', AppStrings.get('pro_benefit_minesweeper_expert', currentLang), isDark),
              _buildBenefitItem('🏳️', AppStrings.get('pro_benefit_minesweeper_noflags', currentLang), isDark),
              _buildBenefitItem('🔢', AppStrings.get('pro_benefit_sudoku', currentLang), isDark),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppStrings.get('close', currentLang),
                style: const TextStyle(color: Color(0xFF7B3FF2)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Aquí se implementaría la lógica de compra
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B3FF2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                AppStrings.get('pro_price', currentLang),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBenefitItem(String emoji, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLang = Provider.of<LanguageProvider>(context).currentLanguage;

    return PopScope(
      canPop: false, // No permitir volver atrás (evita swipe a login)
      child: Scaffold(
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
                      // Banner MINIFUN PRO (oculto para admins, premium e invitados)
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          if (authProvider.isAdmin || authProvider.isPremium || authProvider.isGuest) {
                            return const SizedBox.shrink();
                          }
                          return SizedBox(
                            height: bannerHeight,
                            child: GestureDetector(
                              onTap: () => _showProBenefitsDialog(context),
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
                            ),
                          );
                        },
                      ),

                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          if (authProvider.isAdmin || authProvider.isPremium || authProvider.isGuest) {
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
                            TarjetasJuegos(title: AppStrings.get('game_snake', currentLang), gameKey: 'Snake', imagePath: 'assets/imagenes/sssnake.png')
                                .animate().fadeIn(delay: 100.ms, duration: 400.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                            TarjetasJuegos(title: AppStrings.get('game_watersort', currentLang), gameKey: 'WaterSort', imagePath: 'assets/imagenes/watersort.png')
                                .animate().fadeIn(delay: 150.ms, duration: 400.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                            TarjetasJuegos(title: AppStrings.get('game_word_search', currentLang), gameKey: 'Sopa de Letras', imagePath: 'assets/imagenes/sopadeletras.png')
                                .animate().fadeIn(delay: 200.ms, duration: 400.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                            TarjetasJuegos(title: AppStrings.get('game_hangman', currentLang), gameKey: 'Ahorcado', imagePath: 'assets/imagenes/ahorcado.png')
                                .animate().fadeIn(delay: 250.ms, duration: 400.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                            TarjetasJuegos(title: AppStrings.get('game_minesweeper', currentLang), gameKey: 'Buscaminas', imagePath: 'assets/imagenes/buscaminas.png')
                                .animate().fadeIn(delay: 300.ms, duration: 400.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                            TarjetasJuegos(title: AppStrings.get('game_sudoku', currentLang), gameKey: 'Sudoku', imagePath: 'assets/imagenes/sudoku.png')
                                .animate().fadeIn(delay: 350.ms, duration: 400.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                          ],
                        ),
                      ),

                      SizedBox(height: cellSpacing),

                      // Espacio extra abajo para centrar cuando no hay banner
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          if (authProvider.isAdmin || authProvider.isPremium || authProvider.isGuest) {
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
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _showMissionsDialog(context, missionProvider),
                              child: Column(
                                children: [
                                  // Título MISIONES
                                  Container(
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
                                ],
                              ),
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
      ),
    );
  }
}
