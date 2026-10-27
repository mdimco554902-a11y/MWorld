import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Outfit and aesthetic details for player and companion avatars.
class AvatarModel {
  final String id;
  final String name;
  final String className;
  final Color robeColor;
  final Color trimColor;
  final Color hairColor;
  final bool hasCloak;
  final String headpiece; // 'none', 'circlet', 'cowl', 'hood'
  final String staffType; // 'woodenStaff', 'crystalStaff', 'flowerStaff'

  const AvatarModel({
    required this.id,
    required this.name,
    required this.className,
    required this.robeColor,
    required this.trimColor,
    required this.hairColor,
    required this.hasCloak,
    required this.headpiece,
    required this.staffType,
  });

  AvatarModel copyWith({
    String? id,
    String? name,
    String? className,
    Color? robeColor,
    Color? trimColor,
    Color? hairColor,
    bool? hasCloak,
    String? headpiece,
    String? staffType,
  }) {
    return AvatarModel(
      id: id ?? this.id,
      name: name ?? this.name,
      className: className ?? this.className,
      robeColor: robeColor ?? this.robeColor,
      trimColor: trimColor ?? this.trimColor,
      hairColor: hairColor ?? this.hairColor,
      hasCloak: hasCloak ?? this.hasCloak,
      headpiece: headpiece ?? this.headpiece,
      staffType: staffType ?? this.staffType,
    );
  }

  // --- Fantasy Preset Name Pools ---
  static const List<String> _fantasyNames = [
    'Faelen the Novice',
    'Lyra of the Wood',
    'Soren Rune-weaver',
    'Kenneth Meadow-walker',
    'Elowen Starwhisper',
    'Sylwen Leafbinder',
    'Caelum Dawnmage',
    'Mirelle Riversong',
    'Thalen Windrunner',
    'Seraphina Moonveil',
    'Aelwen Sunweaver',
    'Brannor Forestwalker',
  ];

  static const List<String> _classes = [
    'Apprentice Mage',
    'Forest Elf',
    'Runecaster',
    'Hedge Knight',
  ];

  // 8 Unique Cozy Fantasy Outfit Palettes
  static const List<Color> _robePalettes = [
    Color(0xFF5A7D5A), // Moss
    Color(0xFFB46B38), // Amber
    Color(0xFF7BA4B8), // Sky Blue
    Color(0xFF9E8DB5), // Lavender
    Color(0xFF8A3B45), // Crimson
    Color(0xFF4B3A5A), // Dusk Violet
    Color(0xFF483526), // Forest Bark
    Color(0xFFF5F5FA), // Snow White
  ];

  static const List<Color> _trimColors = [
    Color(0xFFC9A86A), // Antique Gold
    Color(0xFFDFCA9B), // Pale Gold
    Color(0xFFE2E8F0), // Silver White
    Color(0xFF8FBFB5), // Mana Blue-Green
  ];

  static const List<Color> _hairColors = [
    Color(0xFFFDE68A), // Golden Blonde
    Color(0xFFE2E8F0), // Silver White
    Color(0xFFD4A373), // Warm Chestnut
    Color(0xFF33272A), // Midnight
    Color(0xFFE8B4B8), // Rose
  ];

  static const List<String> _headpieces = ['none', 'circlet', 'cowl', 'hood'];
  static const List<String> _staffTypes = ['woodenStaff', 'crystalStaff', 'flowerStaff'];

  /// Generates 8 unique, randomized fantasy traveler presets with guaranteed distinct colors.
  static List<AvatarModel> generatePresets() {
    final random = math.Random();
    final names = List<String>.from(_fantasyNames)..shuffle(random);
    final robes = List<Color>.from(_robePalettes)..shuffle(random);

    return List.generate(8, (index) {
      final name = names[index % names.length];
      final className = _classes[index % _classes.length];
      final robeColor = robes[index % robes.length];
      final trimColor = _trimColors[random.nextInt(_trimColors.length)];
      final hairColor = _hairColors[random.nextInt(_hairColors.length)];
      final hasCloak = random.nextBool();
      final headpiece = _headpieces[random.nextInt(_headpieces.length)];
      final staffType = _staffTypes[random.nextInt(_staffTypes.length)];

      return AvatarModel(
        id: 'avatar_${DateTime.now().microsecondsSinceEpoch}_$index',
        name: name,
        className: className,
        robeColor: robeColor,
        trimColor: trimColor,
        hairColor: hairColor,
        hasCloak: hasCloak,
        headpiece: headpiece,
        staffType: staffType,
      );
    });
  }

  /// Default starting traveler avatar.
  static AvatarModel get defaultAvatar => const AvatarModel(
        id: 'avatar_default',
        name: 'Sylwen Leafbinder',
        className: 'Forest Elf',
        robeColor: Color(0xFF5A7D5A), // Moss green
        trimColor: Color(0xFFC9A86A), // Antique gold
        hairColor: Color(0xFFFDE68A), // Golden blonde
        hasCloak: true,
        headpiece: 'circlet',
        staffType: 'crystalStaff',
      );
}
