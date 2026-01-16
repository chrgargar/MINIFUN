import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tema/selectorTema.dart';
import '../tema/audio_settings.dart';
import '../tema/language_provider.dart';
import '../providers/auth_provider.dart';
import '../screens/pantalla_login.dart';
import '../constants/app_strings.dart';

// Widget reutilizable para mostrar el diálogo de ajustes
class VentanaAjustes {
  // Mostrar diálogo de ajustes
  static void show(BuildContext context) {
    final themeProvider = Provider.of<SelectorTema>(context, listen: false);
    final audioSettings = Provider.of<AudioSettings>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Consumer<LanguageProvider>(
          builder: (context, lang, child) {
            final currentLang = lang.currentLanguage;
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 600),
                padding: const EdgeInsets.all(24),
                child: ScrollbarTheme(
                  data: const ScrollbarThemeData(
                    minThumbLength: 20,
                    mainAxisMargin: 50,
                    crossAxisMargin: -10,
                  ),
                  child: Scrollbar(
                    thumbVisibility: true,
                    thickness: 6,
                    radius: const Radius.circular(10),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                      // Título del diálogo
                      Text(
                        AppStrings.get('settings', currentLang),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(dialogContext).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Opción: Tema oscuro/claro con switch
                      _buildThemeOption(
                        context: dialogContext,
                        themeProvider: themeProvider,
                        currentLang: currentLang,
                      ),

                      const Divider(height: 32),

                      // Opción: Selector de idioma
                      _buildLanguageOption(
                        context: dialogContext,
                        languageProvider: languageProvider,
                      ),

                      const Divider(height: 32),

                      // Opción: Control de volumen de música
                      _buildMusicVolumeSlider(
                        context: dialogContext,
                        audioSettings: audioSettings,
                        title: AppStrings.get('music_volume', currentLang),
                      ),

                      const Divider(height: 32),

                      // Opción: Silenciar todo
                      _buildMuteOption(
                        context: dialogContext,
                        audioSettings: audioSettings,
                        currentLang: currentLang,
                      ),

                      const Divider(height: 32),

                      // Opción: Racha de días
                      _buildStreakOption(
                        context: dialogContext,
                        streakDays: 0, // Placeholder
                        currentLang: currentLang,
                      ),

                      const Divider(height: 32),

                      // Opción: Jugar como invitado
                      _buildSettingOption(
                        context: dialogContext,
                        icon: Icons.person_outline,
                        title: AppStrings.get('play_as_guest', currentLang),
                        subtitle: AppStrings.get('continue_without_account', currentLang),
                        onTap: () async {
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);

                          // Cerrar sesión actual
                          await authProvider.logout();

                          // Crear sesión de invitado
                          final success = await authProvider.continueAsGuest();

                          if (success && dialogContext.mounted) {
                            // Cerrar el diálogo
                            Navigator.pop(dialogContext);

                            // Mostrar confirmación
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppStrings.get('now_playing_as_guest', currentLang)),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else if (dialogContext.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(authProvider.errorMessage ?? AppStrings.get('error_guest_mode', currentLang)),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),

                      const Divider(height: 32),

                      // Opción: Cambiar de cuenta
                      _buildSettingOption(
                        context: dialogContext,
                        icon: Icons.swap_horiz,
                        title: AppStrings.get('switch_account', currentLang),
                        subtitle: AppStrings.get('login_other_account', currentLang),
                        onTap: () async {
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);

                          // Cerrar sesión
                          await authProvider.logout();

                          if (dialogContext.mounted) {
                            // Cerrar el diálogo
                            Navigator.pop(dialogContext);

                            // Navegar a la pantalla de login
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const PantallaLogin()),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 24),

                      // Botón cerrar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext); // Cerrar el diálogo
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
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
    );
  }

  // Widget para la opción de tema con switch toggle
  static Widget _buildThemeOption({
    required BuildContext context,
    required SelectorTema themeProvider,
    required String currentLang,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Ícono
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF7B3FF2).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.brightness_6,
              color: Color(0xFF7B3FF2),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('dark_theme', currentLang),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  themeProvider.isDarkMode
                      ? AppStrings.get('activated', currentLang)
                      : AppStrings.get('deactivated', currentLang),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Switch toggle
          Switch(
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.cambiarTema();
            },
            thumbColor: const WidgetStatePropertyAll(Color(0xFF7B3FF2)),
            trackColor: WidgetStatePropertyAll(
              themeProvider.isDarkMode
                  ? const Color(0xFF7B3FF2).withValues(alpha: 0.5)
                  : Colors.grey.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para selector de idioma
  static Widget _buildLanguageOption({
    required BuildContext context,
    required LanguageProvider languageProvider,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<LanguageProvider>(
      builder: (context, langProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // Ícono
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B3FF2).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.language,
                  color: Color(0xFF7B3FF2),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get('language', langProvider.currentLanguage),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      langProvider.currentLanguageName,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Dropdown de idiomas
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B3FF2).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: langProvider.currentLanguage,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF7B3FF2)),
                  dropdownColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                  items: LanguageProvider.availableLanguages.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      langProvider.setLanguage(newValue);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget para mostrar la racha de días
  static Widget _buildStreakOption({
    required BuildContext context,
    required int streakDays,
    required String currentLang,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Ícono
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF7B3FF2).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Color(0xFF7B3FF2),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('streak', currentLang),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.get('consecutive_days', currentLang),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Contador de días
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF7B3FF2).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$streakDays ${AppStrings.get('days', currentLang)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B3FF2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para control de volumen de música con slider
  static Widget _buildMusicVolumeSlider({
    required BuildContext context,
    required AudioSettings audioSettings,
    required String title,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<AudioSettings>(
      builder: (context, audio, child) {
        final currentVolume = audio.rawMusicVolume;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Row(
                children: [
                  // Ícono
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B3FF2).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.music_note,
                      color: Color(0xFF7B3FF2),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Texto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(currentVolume * 100).round()}%',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Slider
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: const Color(0xFF7B3FF2),
                  inactiveTrackColor: const Color(0xFF7B3FF2).withValues(alpha: 0.2),
                  thumbColor: const Color(0xFF7B3FF2),
                  overlayColor: const Color(0xFF7B3FF2).withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: currentVolume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 20,
                  onChanged: (value) {
                    audio.setMusicVolume(value);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget para silenciar todo
  static Widget _buildMuteOption({
    required BuildContext context,
    required AudioSettings audioSettings,
    required String currentLang,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<AudioSettings>(
      builder: (context, audio, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // Ícono
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B3FF2).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  audio.isMuted ? Icons.volume_off : Icons.volume_up,
                  color: const Color(0xFF7B3FF2),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get('mute_all', currentLang),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      audio.isMuted
                          ? AppStrings.get('muted', currentLang)
                          : AppStrings.get('with_sound', currentLang),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Switch toggle
              Switch(
                value: audio.isMuted,
                onChanged: (value) {
                  audio.toggleMute();
                },
                thumbColor: const WidgetStatePropertyAll(Color(0xFF7B3FF2)),
                trackColor: WidgetStatePropertyAll(
                  audio.isMuted
                      ? const Color(0xFF7B3FF2).withValues(alpha: 0.5)
                      : Colors.grey.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget helper para las opciones de ajustes
  static Widget _buildSettingOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Ícono
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF7B3FF2).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF7B3FF2),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Flecha
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
