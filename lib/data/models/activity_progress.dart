class ActivityProgress {
  final int? id;
  final int profileId;
  final String worldId;
  final String activityId;
  final int stars; // 0-3
  final bool isCompleted;
  final int timesPlayed;
  final DateTime lastPlayedAt;

  ActivityProgress({
    this.id,
    required this.profileId,
    required this.worldId,
    required this.activityId,
    this.stars = 0,
    this.isCompleted = false,
    this.timesPlayed = 0,
    DateTime? lastPlayedAt,
  }) : lastPlayedAt = lastPlayedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'profile_id': profileId,
        'world_id': worldId,
        'activity_id': activityId,
        'stars': stars,
        'is_completed': isCompleted ? 1 : 0,
        'times_played': timesPlayed,
        'last_played_at': lastPlayedAt.toIso8601String(),
      };

  factory ActivityProgress.fromMap(Map<String, dynamic> map) =>
      ActivityProgress(
        id: map['id'] as int?,
        profileId: map['profile_id'] as int,
        worldId: map['world_id'] as String,
        activityId: map['activity_id'] as String,
        stars: map['stars'] as int? ?? 0,
        isCompleted: (map['is_completed'] as int) == 1,
        timesPlayed: map['times_played'] as int? ?? 0,
        lastPlayedAt: DateTime.parse(map['last_played_at'] as String),
      );
}