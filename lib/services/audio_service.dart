import 'package:audioplayers/audioplayers.dart';

/// Servicio centralizado de Audio para toda la aplicación
/// Maneja efectos de sonido y música de fondo en loop
///
/// IMPORTANTE: Este servicio usa un pool de reproductores para sonidos precargados.
/// Cuando un juego llama a preloadSounds(), se crean 3 reproductores por sonido.
/// Al reproducir, se usa play() en lugar de seek()+resume() porque resume()
/// no funciona correctamente después de que un sonido termina (estado completed).
///
/// Para añadir sonidos a un juego:
/// 1. Añadir el archivo de sonido a assets/Sonidos/
/// 2. Descomentar o añadir la línea en preloadSounds() del juego
/// 3. Llamar AudioService.playSound('Sonidos/archivo.ogg', volume)
class AudioService {
  // Reproductor para música de fondo en loop
  static AudioPlayer? _loopPlayer;
  static String? _loopSrc;

  // Pool de reproductores precargados para sonidos frecuentes
  static final Map<String, List<AudioPlayer>> _soundPool = {};
  static const int _poolSize = 3; // Número de reproductores por sonido

  /// Precargar sonidos frecuentes para reproducción instantánea
  /// Llamar al inicio de la app o al entrar a un juego
  static Future<void> preloadSounds(List<String> sounds) async {
    for (final src in sounds) {
      if (!_soundPool.containsKey(src)) {
        _soundPool[src] = [];
        for (int i = 0; i < _poolSize; i++) {
          final player = AudioPlayer();
          await player.setSource(AssetSource(src));
          _soundPool[src]!.add(player);
        }
      }
    }
  }

  /// Reproducir sonido precargado (instantáneo)
  static Future<void> _playPreloaded(String src, double volume) async {
    final pool = _soundPool[src];
    if (pool == null || pool.isEmpty) {
      // Fallback a reproducción normal si no está precargado
      await playSound(src, volume);
      return;
    }

    // Buscar un reproductor disponible (no está reproduciendo)
    AudioPlayer? availablePlayer;
    for (final player in pool) {
      final state = player.state;
      if (state != PlayerState.playing) {
        availablePlayer = player;
        break;
      }
    }

    // Si no hay disponible, detener el primero y reutilizarlo
    final player = availablePlayer ?? pool.first;
    if (availablePlayer == null) {
      // Todos están ocupados, detener el primero para reutilizarlo
      await player.stop();
    }

    // Configurar volumen y reproducir desde el inicio
    // Usar play() en lugar de seek+resume porque resume no funciona
    // correctamente después de que el sonido termina (estado completed)
    await player.setVolume(volume);
    await player.play(AssetSource(src));
  }

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
  /// Si el sonido está precargado, se reproduce instantáneamente
  static Future<void> playSound(String src, double volume) async {
    // Si el volumen es 0, no reproducir
    if (volume <= 0) return;

    // Si está precargado, usar el pool para reproducción instantánea
    if (_soundPool.containsKey(src)) {
      await _playPreloaded(src, volume);
      return;
    }

    try {
      final player = AudioPlayer();
      await player.setVolume(volume);
      await player.play(AssetSource(src));

      // Liberar recursos cuando termine de reproducir
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (e) {
      // Ignorar errores de audio silenciosamente
    }
  }

  /// Liberar todos los sonidos precargados
  static Future<void> disposeSounds() async {
    for (final pool in _soundPool.values) {
      for (final player in pool) {
        await player.dispose();
      }
    }
    _soundPool.clear();
  }
}
