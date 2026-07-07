class RewardItem {
  final int? id;
  final int profileId;
  final String itemId;
  final String type; // 'sticker', 'badge', 'accessory'
  final String name;
  final String imagePath;
  final String? worldId; // which world earned this from
  final bool isNew;
  final DateTime earnedAt;

  RewardItem({
    this.id,
    required this.profileId,
    required this.itemId,
    required this.type,
    required this.name,
    required this.imagePath,
    this.worldId,
    this.isNew = true,
    DateTime? earnedAt,
  }) : earnedAt = earnedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'profile_id': profileId,
        'item_id': itemId,
        'type': type,
        'name': name,
        'image_path': imagePath,
        'world_id': worldId ?? '',
        'is_new': isNew ? 1 : 0,
        'earned_at': earnedAt.toIso8601String(),
      };

  factory RewardItem.fromMap(Map<String, dynamic> map) => RewardItem(
        id: map['id'] as int?,
        profileId: map['profile_id'] as int,
        itemId: map['item_id'] as String,
        type: map['type'] as String,
        name: map['name'] as String,
        imagePath: map['image_path'] as String,
        worldId: map['world_id'] as String?,
        isNew: (map['is_new'] as int) == 1,
        earnedAt: DateTime.parse(map['earned_at'] as String),
      );
}