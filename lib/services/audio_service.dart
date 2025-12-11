import 'package:audioplayers/audioplayers.dart';

/// Servicio centralizado de Audio para toda la aplicación
/// Maneja efectos de sonido y música de fondo en loop
class AudioService {
  // Reproductor para música de fondo en loop
  static AudioPlayer? _loopPlayer;
  static String? _loopSrc;

  /// Reproducir música de fondo en loop continuo
  /// [src] - Ruta del archivo de audio (ej: 'sonidos/music.mp3')
  /// [volume] - Volumen de reproducción (0.0 - 1.0)
  static Future<void> playLoop(String src, double volume) async {
    _loopSrc = src;

    // Si ya existe un reproductor, detenerlo
    if (_loopPlayer != null) {
      await _loopPlayer!.stop();
      await _loopPlayer!.dispose();
    }

    // Crear nuevo reproductor para el loop
    _loopPlayer = AudioPlayer();
    await _loopPlayer!.setVolume(volume);

    // Escuchar el estado del reproductor para reiniciar cuando termine
    _loopPlayer!.onPlayerStateChanged.listen((PlayerState state) async {
      if (state == PlayerState.completed) {
        // Reiniciar inmediatamente cuando termina
        if (_loopPlayer != null && _loopSrc != null) {
          await _loopPlayer!.play(AssetSource(_loopSrc!));
        }
      }
    });

    // Iniciar reproducción
    await _loopPlayer!.play(AssetSource(src));
  }

  /// Detener música de fondo en loop
  static Future<void> stopLoop() async {
    if (_loopPlayer != null) {
      await _loopPlayer!.stop();
      await _loopPlayer!.dispose();
      _loopPlayer = null;
      _loopSrc = null;
    }
  }

  /// Pausar música de fondo en loop
  static Future<void> pauseLoop() async {
    if (_loopPlayer != null) {
      await _loopPlayer!.pause();
    }
  }

  /// Reanudar música de fondo en loop
  static Future<void> resumeLoop() async {
    if (_loopPlayer != null) {
      await _loopPlayer!.resume();
    }
  }

  /// Cambiar volumen de la música de fondo en loop
  /// [volume] - Nuevo volumen (0.0 - 1.0)
  static void setLoopVolume(double volume) {
    if (_loopPlayer != null) {
      _loopPlayer!.setVolume(volume);
    }
  }

  /// Reproducir un efecto de sonido de una sola vez
  /// [src] - Ruta del archivo de audio (ej: 'sonidos/food.mp3')
  /// [volume] - Volumen de reproducción (0.0 - 1.0)
  static Future<void> playSound(String src, double volume) async {
    final player = AudioPlayer();
    await player.setVolume(volume);
    await player.play(AssetSource(src));
  }
}
