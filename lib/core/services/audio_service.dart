import 'package:flutter/material.dart';

class AudioService extends ChangeNotifier {
  bool _isMuted = false;
  double _volume = 0.8;

  bool get isMuted => _isMuted;
  double get volume => _volume;

  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }

  void setVolume(double vol) {
    _volume = vol.clamp(0.0, 1.0);
    notifyListeners();
  }

  Future<void> playButtonPress() async {
    // TODO: Implement with audioplayers package
  }

  Future<void> playCorrectAction() async {
    // TODO: Implement with audioplayers package
  }

  Future<void> playGentleError() async {
    // TODO: Implement with audioplayers package
  }

  Future<void> playRewardJingle() async {
    // TODO: Implement with audioplayers package
  }

  Future<void> playWorldMusic(String worldId) async {
    // TODO: Implement world-specific BGM
  }

  void stopAll() {
    // TODO: Stop all audio
  }
}