import 'package:flutter/material.dart';

/// Provider para gestionar la configuración de audio de la aplicación
class AudioSettings extends ChangeNotifier {
  double _musicVolume = 0.5; // Volumen de música de fondo (0.0 - 1.0)
  double _sfxVolume = 0.7; // Volumen de efectos de sonido (0.0 - 1.0)
  bool _isMuted = false; // Si el audio está silenciado completamente

  double get musicVolume => _isMuted ? 0.0 : _musicVolume;
  double get sfxVolume => _isMuted ? 0.0 : _sfxVolume;
  bool get isMuted => _isMuted;

  // Obtener valores reales sin considerar el mute (para los sliders)
  double get rawMusicVolume => _musicVolume;
  double get rawSfxVolume => _sfxVolume;

  /// Establecer volumen de música (0.0 - 1.0)
  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Establecer volumen de efectos de sonido (0.0 - 1.0)
  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Alternar silenciado global
  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }

  /// Establecer silenciado global
  void setMuted(bool muted) {
    _isMuted = muted;
    notifyListeners();
  }
}
