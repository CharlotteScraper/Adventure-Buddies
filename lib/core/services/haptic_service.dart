import 'package:flutter/material.dart';

class HapticService extends ChangeNotifier {
  bool _enabled = true;

  bool get enabled => _enabled;

  void setEnabled(bool value) {
    _enabled = value;
    notifyListeners();
  }

  void lightTap() {
    if (!_enabled) return;
    // TODO: HapticFeedback.lightImpact();
  }

  void mediumTap() {
    if (!_enabled) return;
    // TODO: HapticFeedback.mediumImpact();
  }

  void successFeedback() {
    if (!_enabled) return;
    // TODO: HapticFeedback.heavyImpact();
  }

  void warningFeedback() {
    if (!_enabled) return;
    // TODO: HapticFeedback.heavyImpact();
  }
}