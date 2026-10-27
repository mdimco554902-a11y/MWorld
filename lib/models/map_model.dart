import 'package:flutter/material.dart';

/// Data class representing an exploration arena map with pastoral colors and themes.
class MapModel {
  final String id;
  final String name;
  final String description;
  final String coverTag;
  final bool isLocked;
  final String? lockedHint;

  // Visual Palette Tokens for the Arena Viewport
  final Color groundBaseColor;
  final Color pathColor;
  final Color ringColor;
  final Color runeColor;
  final Color obstaclePrimaryColor;
  final Color obstacleAccentColor;

  const MapModel({
    required this.id,
    required this.name,
    required this.description,
    required this.coverTag,
    this.isLocked = false,
    this.lockedHint,
    required this.groundBaseColor,
    required this.pathColor,
    required this.ringColor,
    required this.runeColor,
    required this.obstaclePrimaryColor,
    required this.obstacleAccentColor,
  });

  /// All 7 expedition maps (5 unlocked, 2 locked & sealed with ImageFiltered blur).
  static List<MapModel> get allMaps => [
        // 1. Whispering Clearing
        const MapModel(
          id: 'whispering_clearing',
          name: 'Whispering Clearing',
          description: 'A tranquil glade surrounded by ancient elder pines and mossy fallen logs.',
          coverTag: 'Balanced Glade',
          isLocked: false,
          groundBaseColor: Color(0xFF1B2C20),
          pathColor: Color(0xFF263A2B),
          ringColor: Color(0xFF3B523F),
          runeColor: Color(0xFFC9A86A),
          obstaclePrimaryColor: Color(0xFF483526),
          obstacleAccentColor: Color(0xFF4E7A52),
        ),

        // 2. Sunlit Ruins
        const MapModel(
          id: 'sunlit_ruins',
          name: 'Sunlit Ruins',
          description: 'Crumbling limestone pillars and sun-drenched courtyards bathed in golden morning warmth.',
          coverTag: 'Open Sightlines',
          isLocked: false,
          groundBaseColor: Color(0xFF2D2E24),
          pathColor: Color(0xFF3D3C2E),
          ringColor: Color(0xFF524F3A),
          runeColor: Color(0xFFD4B26F),
          obstaclePrimaryColor: Color(0xFF5C5441),
          obstacleAccentColor: Color(0xFF8F9E75),
        ),

        // 3. Ancient Grove
        const MapModel(
          id: 'ancient_grove',
          name: 'Ancient Grove',
          description: 'Towering ancestral roots, thick moss canopies, and dense tactical timber barriers.',
          coverTag: 'Dense Cover',
          isLocked: false,
          groundBaseColor: Color(0xFF14241B),
          pathColor: Color(0xFF1E3326),
          ringColor: Color(0xFF2B4735),
          runeColor: Color(0xFF8FBFB5),
          obstaclePrimaryColor: Color(0xFF3B2A1E),
          obstacleAccentColor: Color(0xFF456B48),
        ),

        // 4. Mossy Sanctuary
        const MapModel(
          id: 'mossy_sanctuary',
          name: 'Mossy Sanctuary',
          description: 'Gentle stone altars wrapped in ivy and perennial chamomile with winding walkways.',
          coverTag: 'Winding Paths',
          isLocked: false,
          groundBaseColor: Color(0xFF1C2B22),
          pathColor: Color(0xFF273D30),
          ringColor: Color(0xFF385744),
          runeColor: Color(0xFFA5C49F),
          obstaclePrimaryColor: Color(0xFF424A3D),
          obstacleAccentColor: Color(0xFF6B8A68),
        ),

        // 5. Twilight Hollow
        const MapModel(
          id: 'twilight_hollow',
          name: 'Twilight Hollow',
          description: 'Soft twilight glimmers illuminating sleeping crystal deposits and misty woodland creeks.',
          coverTag: 'Misty Perimeter',
          isLocked: false,
          groundBaseColor: Color(0xFF18222A),
          pathColor: Color(0xFF22313D),
          ringColor: Color(0xFF314554),
          runeColor: Color(0xFF82A6B3),
          obstaclePrimaryColor: Color(0xFF2F3842),
          obstacleAccentColor: Color(0xFF5A7587),
        ),

        // 6. Frostfall Shrine (Locked)
        const MapModel(
          id: 'frostfall_shrine',
          name: 'Frostfall Shrine',
          description: 'Glacial sanctuary veiled in eternal snowflakes and enchanted rime.',
          coverTag: 'Discovered at Lv. 10',
          isLocked: true,
          lockedHint: 'Discovered at Lv. 10 — Frostfall Shrine is protected by frost enchantments.',
          groundBaseColor: Color(0xFF1C242C),
          pathColor: Color(0xFF25333F),
          ringColor: Color(0xFF384C5E),
          runeColor: Color(0xFFA6CBE8),
          obstaclePrimaryColor: Color(0xFF3B4854),
          obstacleAccentColor: Color(0xFF7BA4B8),
        ),

        // 7. Dragon\'s Spire (Locked)
        const MapModel(
          id: 'dragons_spire',
          name: "Dragon's Spire",
          description: 'High crag summit where ancient elder drakes once watched over the realm.',
          coverTag: 'Discovered at Lv. 20',
          isLocked: true,
          lockedHint: "Discovered at Lv. 20 — Dragon's Spire is sealed behind high-peak storms.",
          groundBaseColor: Color(0xFF291E20),
          pathColor: Color(0xFF38292C),
          ringColor: Color(0xFF4D383C),
          runeColor: Color(0xFFD48B6A),
          obstaclePrimaryColor: Color(0xFF4A3438),
          obstacleAccentColor: Color(0xFF8C5350),
        ),
      ];

  static MapModel get defaultMap => allMaps.first;
}
