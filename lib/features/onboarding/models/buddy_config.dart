class BuddyConfig {
  final String type; // fox, bear, bunny, cat
  final String colorHex;
  final String hat;
  final String glasses;
  final String accessory;

  const BuddyConfig({
    this.type = 'fox',
    this.colorHex = '#F0C080',
    this.hat = 'none',
    this.glasses = '',
    this.accessory = '',
  });

  static const List<String> availableTypes = ['fox', 'bear', 'bunny', 'cat'];
  static const List<String> availableHats =
      ['none', 'crown', 'party', 'captain'];

  BuddyConfig copyWith({
    String? type,
    String? colorHex,
    String? hat,
    String? glasses,
    String? accessory,
  }) {
    return BuddyConfig(
      type: type ?? this.type,
      colorHex: colorHex ?? this.colorHex,
      hat: hat ?? this.hat,
      glasses: glasses ?? this.glasses,
      accessory: accessory ?? this.accessory,
    );
  }
}