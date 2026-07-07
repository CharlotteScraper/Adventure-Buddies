import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends ChangeNotifier {
  static StorageService? _instance;
  late SharedPreferences _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // Sound settings
  Future<void> setSoundEnabled(bool enabled) =>
      _prefs.setBool('sound_enabled', enabled);
  bool getSoundEnabled() => _prefs.getBool('sound_enabled') ?? true;

  // Volume
  Future<void> setVolume(double volume) =>
      _prefs.setDouble('volume', volume);
  double getVolume() => _prefs.getDouble('volume') ?? 0.8;

  // Haptic feedback
  Future<void> setHapticEnabled(bool enabled) =>
      _prefs.setBool('haptic_enabled', enabled);
  bool getHapticEnabled() => _prefs.getBool('haptic_enabled') ?? true;

  // Narration
  Future<void> setNarrationEnabled(bool enabled) =>
      _prefs.setBool('narration_enabled', enabled);
  bool getNarrationEnabled() => _prefs.getBool('narration_enabled') ?? true;

  // Screen time limit (in minutes)
  Future<void> setScreenTimeLimit(int minutes) =>
      _prefs.setInt('screen_time_limit', minutes);
  int getScreenTimeLimit() => _prefs.getInt('screen_time_limit') ?? 0;

  // Onboarding completed
  Future<void> setOnboardingCompleted(bool completed) =>
      _prefs.setBool('onboarding_completed', completed);
  bool getOnboardingCompleted() =>
      _prefs.getBool('onboarding_completed') ?? false;

  // Active child profile ID
  Future<void> setActiveProfileId(int id) =>
      _prefs.setInt('active_profile_id', id);
  int? getActiveProfileId() => _prefs.getInt('active_profile_id');

  // Clear all settings
  Future<void> clearAll() async {
    await _prefs.clear();
    notifyListeners();
  }
}