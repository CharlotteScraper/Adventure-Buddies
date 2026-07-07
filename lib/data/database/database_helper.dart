import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart' as constants;

class DatabaseHelper extends ChangeNotifier {
  static DatabaseHelper? _instance;
  Database? _database;

  DatabaseHelper._();

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, constants.AppConstants.databaseName);

    return await openDatabase(
      path,
      version: constants.AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Child profiles
    await db.execute('''
      CREATE TABLE child_profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        buddy_type TEXT NOT NULL DEFAULT 'fox',
        buddy_color TEXT NOT NULL DEFAULT '#F0C080',
        buddy_hat TEXT DEFAULT '',
        buddy_glasses TEXT DEFAULT '',
        buddy_accessory TEXT DEFAULT '',
        created_at TEXT NOT NULL
      )
    ''');

    // World progress
    await db.execute('''
      CREATE TABLE world_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        world_id TEXT NOT NULL,
        is_unlocked INTEGER DEFAULT 0,
        total_stars INTEGER DEFAULT 0,
        activities_completed INTEGER DEFAULT 0,
        last_played_at TEXT NOT NULL,
        FOREIGN KEY (profile_id) REFERENCES child_profiles(id) ON DELETE CASCADE,
        UNIQUE(profile_id, world_id)
      )
    ''');

    // Activity progress
    await db.execute('''
      CREATE TABLE activity_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        world_id TEXT NOT NULL,
        activity_id TEXT NOT NULL,
        stars INTEGER DEFAULT 0,
        is_completed INTEGER DEFAULT 0,
        times_played INTEGER DEFAULT 0,
        last_played_at TEXT NOT NULL,
        FOREIGN KEY (profile_id) REFERENCES child_profiles(id) ON DELETE CASCADE,
        UNIQUE(profile_id, world_id, activity_id)
      )
    ''');

    // Mission records
    await db.execute('''
      CREATE TABLE mission_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        mission_id TEXT NOT NULL,
        title TEXT NOT NULL,
        is_completed INTEGER DEFAULT 0,
        assigned_at TEXT NOT NULL,
        completed_at TEXT,
        FOREIGN KEY (profile_id) REFERENCES child_profiles(id) ON DELETE CASCADE
      )
    ''');

    // Reward inventory
    await db.execute('''
      CREATE TABLE reward_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        item_id TEXT NOT NULL,
        type TEXT NOT NULL,
        name TEXT NOT NULL,
        image_path TEXT DEFAULT '',
        world_id TEXT DEFAULT '',
        is_new INTEGER DEFAULT 1,
        earned_at TEXT NOT NULL,
        FOREIGN KEY (profile_id) REFERENCES child_profiles(id) ON DELETE CASCADE,
        UNIQUE(profile_id, item_id)
      )
    ''');

    // Learning time tracking
    await db.execute('''
      CREATE TABLE learning_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT,
        duration_seconds INTEGER DEFAULT 0,
        world_id TEXT DEFAULT '',
        activities_done INTEGER DEFAULT 0,
        FOREIGN KEY (profile_id) REFERENCES child_profiles(id) ON DELETE CASCADE
      )
    ''');

    // Insert default worlds for future profiles
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS init_worlds
      AFTER INSERT ON child_profiles
      BEGIN
        INSERT INTO world_progress (profile_id, world_id, is_unlocked, total_stars, activities_completed, last_played_at)
        VALUES (NEW.id, 'forest_letters', 1, 0, 0, datetime('now'));
        INSERT INTO world_progress (profile_id, world_id, is_unlocked, total_stars, activities_completed, last_played_at)
        VALUES (NEW.id, 'number_beach', 0, 0, 0, datetime('now'));
        INSERT INTO world_progress (profile_id, world_id, is_unlocked, total_stars, activities_completed, last_played_at)
        VALUES (NEW.id, 'shape_city', 0, 0, 0, datetime('now'));
        INSERT INTO world_progress (profile_id, world_id, is_unlocked, total_stars, activities_completed, last_played_at)
        VALUES (NEW.id, 'feelings_garden', 0, 0, 0, datetime('now'));
      END;
    ''');

    // Migration tracking table for future DLC
    await db.execute('''
      CREATE TABLE schema_migrations (
        version INTEGER PRIMARY KEY,
        applied_at TEXT NOT NULL
      )
    ''');

    await db.insert('schema_migrations', {
      'version': 1,
      'applied_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (int v = oldVersion + 1; v <= newVersion; v++) {
      switch (v) {
        case 2:
          // Example DLC migration:
          // await db.execute('ALTER TABLE world_progress ADD COLUMN dlc_flag INTEGER DEFAULT 0');
          break;
        case 3:
          // Future migration
          break;
      }
      await db.insert('schema_migrations', {
        'version': v,
        'applied_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> resetDatabase() async {
    final db = await database;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, constants.AppConstants.databaseName);
    await db.close();
    _database = null;
    await deleteDatabase(path);
    _database = await _initDatabase();
    notifyListeners();
  }
}