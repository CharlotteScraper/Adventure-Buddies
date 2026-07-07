class Sticker {
  final String id;
  final String name;
  final String imagePath;
  final String? worldId;

  const Sticker({
    required this.id,
    required this.name,
    required this.imagePath,
    this.worldId,
  });
}

class Badge {
  final String id;
  final String name;
  final String description;
  final String imagePath;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
  });
}

class Accessory {
  final String id;
  final String name;
  final String slot; // hat, glasses, etc.
  final String imagePath;

  const Accessory({
    required this.id,
    required this.name,
    required this.slot,
    required this.imagePath,
  });
}