import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/reward_item.dart';

class RewardRepository extends ChangeNotifier {
  Future<List<RewardItem>> getRewards(int profileId) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'reward_items',
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'earned_at DESC',
    );
    return maps.map((m) => RewardItem.fromMap(m)).toList();
  }

  Future<List<RewardItem>> getNewRewards(int profileId) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'reward_items',
      where: 'profile_id = ? AND is_new = 1',
      whereArgs: [profileId],
    );
    return maps.map((m) => RewardItem.fromMap(m)).toList();
  }

  Future<void> addReward(RewardItem item) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'reward_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    notifyListeners();
  }

  Future<void> markAsSeen(int profileId, String itemId) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'reward_items',
      {'is_new': 0},
      where: 'profile_id = ? AND item_id = ?',
      whereArgs: [profileId, itemId],
    );
  }

  Future<int> getRewardCount(int profileId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM reward_items WHERE profile_id = ?',
      [profileId],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<void> awardActivityReward(
      int profileId, String worldId, String activityId) async {
    final reward = RewardItem(
      profileId: profileId,
      itemId: '${worldId}_${activityId}_complete',
      type: 'sticker',
      name: '$worldId $activityId Sticker',
      imagePath: 'assets/images/stickers/${worldId}_$activityId.png',
      worldId: worldId,
    );
    await addReward(reward);
  }
}