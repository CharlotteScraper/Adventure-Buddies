class WorldProgress {
  final int? id;
  final int profileId;
  final String worldId; // 'forest_letters', 'number_beach', 'shape_city', 'feelings_garden'
  final bool isUnlocked;
  final int totalStars;
  final int activitiesCompleted;
  final DateTime lastPlayedAt;

  WorldProgress({
    this.id,
    required this.profileId,
    required this.worldId,
    this.isUnlocked = false,
    this.totalStars = 0,
    this.activitiesCompleted = 0,
    DateTime? lastPlayedAt,
  }) : lastPlayedAt = lastPlayedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'profile_id': profileId,
        'world_id': worldId,
        'is_unlocked': isUnlocked ? 1 : 0,
        'total_stars': totalStars,
        'activities_completed': activitiesCompleted,
        'last_played_at': lastPlayedAt.toIso8601String(),
      };

  factory WorldProgress.fromMap(Map<String, dynamic> map) => WorldProgress(
        id: map['id'] as int?,
        profileId: map['profile_id'] as int,
        worldId: map['world_id'] as String,
        isUnlocked: (map['is_unlocked'] as int) == 1,
        totalStars: map['total_stars'] as int? ?? 0,
        activitiesCompleted: map['activities_completed'] as int? ?? 0,
        lastPlayedAt: DateTime.parse(map['last_played_at'] as String),
      );
}