import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/world_progress.dart';
import '../models/activity_progress.dart';

class ProgressRepository extends ChangeNotifier {
  // World progress
  Future<List<WorldProgress>> getWorldProgress(int profileId) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'world_progress',
      where: 'profile_id = ?',
      whereArgs: [profileId],
    );
    return maps.map((m) => WorldProgress.fromMap(m)).toList();
  }

  Future<WorldProgress?> getWorldProgressById(
      int profileId, String worldId) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'world_progress',
      where: 'profile_id = ? AND world_id = ?',
      whereArgs: [profileId, worldId],
    );
    if (maps.isEmpty) return null;
    return WorldProgress.fromMap(maps.first);
  }

  Future<void> updateWorldProgress(WorldProgress progress) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'world_progress',
      progress.toMap(),
      where: 'profile_id = ? AND world_id = ?',
      whereArgs: [progress.profileId, progress.worldId],
    );
    notifyListeners();
  }

  Future<void> unlockWorld(int profileId, String worldId) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'world_progress',
      {'is_unlocked': 1, 'last_played_at': DateTime.now().toIso8601String()},
      where: 'profile_id = ? AND world_id = ?',
      whereArgs: [profileId, worldId],
    );
    notifyListeners();
  }

  // Activity progress
  Future<List<ActivityProgress>> getActivitiesProgress(
      int profileId, String worldId) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'activity_progress',
      where: 'profile_id = ? AND world_id = ?',
      whereArgs: [profileId, worldId],
    );
    return maps.map((m) => ActivityProgress.fromMap(m)).toList();
  }

  Future<void> saveActivityProgress(ActivityProgress progress) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'activity_progress',
      progress.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    notifyListeners();
  }

  Future<void> recordActivityPlayed(
      int profileId, String worldId, String activityId, int stars) async {
    final db = await DatabaseHelper.instance.database;
    final existing = await db.query(
      'activity_progress',
      where: 'profile_id = ? AND world_id = ? AND activity_id = ?',
      whereArgs: [profileId, worldId, activityId],
    );

    if (existing.isNotEmpty) {
      final current = ActivityProgress.fromMap(existing.first);
      final newStars = stars > current.stars ? stars : current.stars;
      await db.update(
        'activity_progress',
        {
          'stars': newStars,
          'is_completed': 1,
          'times_played': current.timesPlayed + 1,
          'last_played_at': DateTime.now().toIso8601String(),
        },
        where: 'profile_id = ? AND world_id = ? AND activity_id = ?',
        whereArgs: [profileId, worldId, activityId],
      );
    } else {
      await db.insert('activity_progress', {
        'profile_id': profileId,
        'world_id': worldId,
        'activity_id': activityId,
        'stars': stars,
        'is_completed': stars > 0 ? 1 : 0,
        'times_played': 1,
        'last_played_at': DateTime.now().toIso8601String(),
      });
    }

    // Update world progress totals
    final agg = await db.rawQuery('''
      SELECT SUM(stars) as total_stars, COUNT(*) as completed
      FROM activity_progress
      WHERE profile_id = ? AND world_id = ? AND is_completed = 1
    ''', [profileId, worldId]);

    if (agg.isNotEmpty) {
      await db.update(
        'world_progress',
        {
          'total_stars': agg.first['total_stars'] ?? 0,
          'activities_completed': agg.first['completed'] ?? 0,
          'last_played_at': DateTime.now().toIso8601String(),
        },
        where: 'profile_id = ? AND world_id = ?',
        whereArgs: [profileId, worldId],
      );
    }
    notifyListeners();
  }

  // Learning time tracking
  Future<void> startLearningSession(int profileId, String worldId) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('learning_sessions', {
      'profile_id': profileId,
      'start_time': DateTime.now().toIso8601String(),
      'world_id': worldId,
    });
  }

  Future<Map<String, int>> getWeeklyStats(int profileId) async {
    final db = await DatabaseHelper.instance.database;
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final result = await db.rawQuery('''
      SELECT 
        COALESCE(SUM(activities_done), 0) as total_activities,
        COALESCE(SUM(duration_seconds), 0) as total_seconds,
        COUNT(*) as total_sessions
      FROM learning_sessions
      WHERE profile_id = ? AND start_time >= ?
    ''', [profileId, weekAgo.toIso8601String()]);

    if (result.isEmpty) {
      return {'activities': 0, 'minutes': 0, 'sessions': 0};
    }
    return {
      'activities': result.first['total_activities'] as int? ?? 0,
      'minutes': ((result.first['total_seconds'] as int? ?? 0) / 60).round(),
      'sessions': result.first['total_sessions'] as int? ?? 0,
    };
  }
}