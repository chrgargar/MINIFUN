import 'package:flutter/material.dart';

/// Provider para gestionar la configuración de audio de la aplicación
/// Solo maneja música de fondo (sin efectos de sonido)
class AudioSettings extends ChangeNotifier {
  // Configuración de volumen (0.0 - 1.0)
  double _musicVolume = 0.5; // Volumen de música de fondo
  bool _isMuted = false; // Estado de silenciado global

  // Getters que consideran el estado de mute
  double get musicVolume => _isMuted ? 0.0 : _musicVolume;
  bool get isMuted => _isMuted;

  // Getter de valor real sin considerar el mute (para el slider de UI)
  double get rawMusicVolume => _musicVolume;

  /// Establecer volumen de música (0.0 - 1.0)
  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
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
