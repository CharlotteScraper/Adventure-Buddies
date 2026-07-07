import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/child_profile.dart';

class ProfileRepository extends ChangeNotifier {
  ChildProfile? _activeProfile;

  ChildProfile? get activeProfile => _activeProfile;

  Future<void> loadProfile(int id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'child_profiles',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      _activeProfile = ChildProfile.fromMap(maps.first);
      notifyListeners();
    }
  }

  Future<ChildProfile> createProfile({
    required String name,
    required String buddyType,
    required String buddyColor,
    String? buddyHat,
    String? buddyGlasses,
    String? buddyAccessory,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final profile = ChildProfile(
      name: name,
      buddyType: buddyType,
      buddyColor: buddyColor,
      buddyHat: buddyHat,
      buddyGlasses: buddyGlasses,
      buddyAccessory: buddyAccessory,
    );
    final id = await db.insert('child_profiles', profile.toMap());
    _activeProfile = ChildProfile(
      id: id,
      name: name,
      buddyType: buddyType,
      buddyColor: buddyColor,
      buddyHat: buddyHat,
      buddyGlasses: buddyGlasses,
      buddyAccessory: buddyAccessory,
    );
    notifyListeners();
    return _activeProfile!;
  }

  Future<void> updateProfile(ChildProfile profile) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'child_profiles',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
    _activeProfile = profile;
    notifyListeners();
  }

  Future<List<ChildProfile>> getAllProfiles() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('child_profiles', orderBy: 'created_at DESC');
    return maps.map((m) => ChildProfile.fromMap(m)).toList();
  }

  Future<void> deleteProfile(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('child_profiles', where: 'id = ?', whereArgs: [id]);
    if (_activeProfile?.id == id) {
      _activeProfile = null;
      notifyListeners();
    }
  }

  bool hasActiveProfile() => _activeProfile != null;
}