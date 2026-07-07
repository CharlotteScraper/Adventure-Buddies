import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/mission_record.dart';

class MissionRepository extends ChangeNotifier {
  static const List<Map<String, String>> _missions = [
    {'id': 'hop_frog', 'title': 'Hop like a frog 5 times!'},
    {'id': 'stomp_feet', 'title': 'Stomp your feet 10 times!'},
    {'id': 'touch_toes', 'title': 'Touch your toes 3 times!'},
    {'id': 'spin_around', 'title': 'Spin around once!'},
    {'id': 'high_knees', 'title': 'Do 5 high knees!'},
    {'id': 'wiggle_fingers', 'title': 'Wiggle all your fingers!'},
    {'id': 'clap_hands', 'title': 'Clap your hands 5 times!'},
    {'id': 'stretch_arms', 'title': "Stretch your arms up high!"},
    {'id': 'balance_one_foot', 'title': 'Stand on one foot for 3 seconds!'},
    {'id': 'jumping_jacks', 'title': 'Do 3 jumping jacks!'},
  ];

  List<Map<String, String>> get allMissions =>
      List.unmodifiable(_missions);

  Future<MissionRecord> assignMission(int profileId) async {
    final db = await DatabaseHelper.instance.database;

    // Check for active incomplete mission
    final active = await db.query(
      'mission_records',
      where: 'profile_id = ? AND is_completed = 0',
      whereArgs: [profileId],
    );

    if (active.isNotEmpty) {
      return MissionRecord.fromMap(active.first);
    }

    // Pick a random mission not recently done
    final recent = await db.query(
      'mission_records',
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'assigned_at DESC',
      limit: 3,
    );
    final recentIds = recent.map((m) => m['mission_id'] as String).toSet();

    final available =
        _missions.where((m) => !recentIds.contains(m['id'])).toList();
    final pool = available.isNotEmpty ? available : _missions;
    final chosen = (pool..shuffle()).first;

    final mission = MissionRecord(
      profileId: profileId,
      missionId: chosen['id']!,
      title: chosen['title']!,
    );
    final id = await db.insert('mission_records', mission.toMap());
    final saved = MissionRecord(
      id: id,
      profileId: profileId,
      missionId: chosen['id']!,
      title: chosen['title']!,
    );
    notifyListeners();
    return saved;
  }

  Future<void> completeMission(int missionId) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'mission_records',
      {
        'is_completed': 1,
        'completed_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [missionId],
    );
    notifyListeners();
  }

  Future<List<MissionRecord>> getMissionHistory(int profileId) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'mission_records',
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'assigned_at DESC',
    );
    return maps.map((m) => MissionRecord.fromMap(m)).toList();
  }

  Future<double> getCompletionRate(int profileId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) as completed
      FROM mission_records
      WHERE profile_id = ?
    ''', [profileId]);

    if (result.isEmpty) return 0.0;
    final total = (result.first['total'] as int?) ?? 0;
    if (total == 0) return 0.0;
    final completed = (result.first['completed'] as int?) ?? 0;
    return completed / total;
  }
}