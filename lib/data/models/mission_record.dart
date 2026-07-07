class MissionRecord {
  final int? id;
  final int profileId;
  final String missionId;
  final String title;
  final bool isCompleted;
  final DateTime assignedAt;
  final DateTime? completedAt;

  MissionRecord({
    this.id,
    required this.profileId,
    required this.missionId,
    required this.title,
    this.isCompleted = false,
    DateTime? assignedAt,
    this.completedAt,
  }) : assignedAt = assignedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'profile_id': profileId,
        'mission_id': missionId,
        'title': title,
        'is_completed': isCompleted ? 1 : 0,
        'assigned_at': assignedAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
      };

  factory MissionRecord.fromMap(Map<String, dynamic> map) => MissionRecord(
        id: map['id'] as int?,
        profileId: map['profile_id'] as int,
        missionId: map['mission_id'] as String,
        title: map['title'] as String,
        isCompleted: (map['is_completed'] as int) == 1,
        assignedAt: DateTime.parse(map['assigned_at'] as String),
        completedAt: map['completed_at'] != null
            ? DateTime.parse(map['completed_at'] as String)
            : null,
      );
}