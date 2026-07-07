import 'package:flutter/material.dart';

class NarrationService extends ChangeNotifier {
  bool _enabled = true;
  bool _isSpeaking = false;

  bool get enabled => _enabled;
  bool get isSpeaking => _isSpeaking;

  void setEnabled(bool value) {
    _enabled = value;
    notifyListeners();
  }

  Future<void> speak(String text) async {
    if (!_enabled || text.isEmpty) return;
    _isSpeaking = true;
    notifyListeners();
    // TODO: Integrate with flutter_tts or similar
    await Future.delayed(const Duration(milliseconds: text.length * 50));
    _isSpeaking = false;
    notifyListeners();
  }

  void stop() {
    _isSpeaking = false;
    notifyListeners();
  }

  /// Common phrases Buddy uses
  Future<void> sayCorrect() async => speak('Great job!');
  Future<void> sayEncouragement() async => speak('You can do it!');
  Future<void> sayTryAgain() async => speak("Let's try another one!");
  Future<void> sayComplete() async => speak('Amazing, you did it!');
  Future<void> sayWelcome() async => speak('Welcome to Adventure Buddies!');
}