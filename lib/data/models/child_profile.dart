class ChildProfile {
  final int? id;
  final String name;
  final String buddyType;
  final String buddyColor;
  final String? buddyHat;
  final String? buddyGlasses;
  final String? buddyAccessory;
  final DateTime createdAt;

  ChildProfile({
    this.id,
    required this.name,
    required this.buddyType,
    required this.buddyColor,
    this.buddyHat,
    this.buddyGlasses,
    this.buddyAccessory,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'buddy_type': buddyType,
        'buddy_color': buddyColor,
        'buddy_hat': buddyHat ?? '',
        'buddy_glasses': buddyGlasses ?? '',
        'buddy_accessory': buddyAccessory ?? '',
        'created_at': createdAt.toIso8601String(),
      };

  factory ChildProfile.fromMap(Map<String, dynamic> map) => ChildProfile(
        id: map['id'] as int?,
        name: map['name'] as String,
        buddyType: map['buddy_type'] as String,
        buddyColor: map['buddy_color'] as String,
        buddyHat: map['buddy_hat'] as String?,
        buddyGlasses: map['buddy_glasses'] as String?,
        buddyAccessory: map['buddy_accessory'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}