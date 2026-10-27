import 'dart:convert';

/// Model representing app-wide audio, music, and gameplay control preferences.
class SettingsModel {
  // Audio Preferences
  final double masterVolume;
  final bool musicEnabled;
  final double musicVolume;
  final bool sfxEnabled;
  final double sfxVolume;
  final bool ambientMelodiesEnabled;

  // Expedition Control Preferences
  final bool showVirtualJoystick;
  final double joystickSize;
  final double joystickOpacity;
  final double joystickSensitivity;

  const SettingsModel({
    this.masterVolume = 0.8,
    this.musicEnabled = true,
    this.musicVolume = 0.6,
    this.sfxEnabled = true,
    this.sfxVolume = 0.7,
    this.ambientMelodiesEnabled = true,
    this.showVirtualJoystick = true,
    this.joystickSize = 1.0,
    this.joystickOpacity = 0.85,
    this.joystickSensitivity = 1.0,
  });

  static const SettingsModel defaults = SettingsModel();

  SettingsModel copyWith({
    double? masterVolume,
    bool? musicEnabled,
    double? musicVolume,
    bool? sfxEnabled,
    double? sfxVolume,
    bool? ambientMelodiesEnabled,
    bool? showVirtualJoystick,
    double? joystickSize,
    double? joystickOpacity,
    double? joystickSensitivity,
  }) {
    return SettingsModel(
      masterVolume: masterVolume ?? this.masterVolume,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      musicVolume: musicVolume ?? this.musicVolume,
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      ambientMelodiesEnabled: ambientMelodiesEnabled ?? this.ambientMelodiesEnabled,
      showVirtualJoystick: showVirtualJoystick ?? this.showVirtualJoystick,
      joystickSize: joystickSize ?? this.joystickSize,
      joystickOpacity: joystickOpacity ?? this.joystickOpacity,
      joystickSensitivity: joystickSensitivity ?? this.joystickSensitivity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'masterVolume': masterVolume,
      'musicEnabled': musicEnabled,
      'musicVolume': musicVolume,
      'sfxEnabled': sfxEnabled,
      'sfxVolume': sfxVolume,
      'ambientMelodiesEnabled': ambientMelodiesEnabled,
      'showVirtualJoystick': showVirtualJoystick,
      'joystickSize': joystickSize,
      'joystickOpacity': joystickOpacity,
      'joystickSensitivity': joystickSensitivity,
    };
  }

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      masterVolume: (map['masterVolume'] as num?)?.toDouble() ?? 0.8,
      musicEnabled: map['musicEnabled'] as bool? ?? true,
      musicVolume: (map['musicVolume'] as num?)?.toDouble() ?? 0.6,
      sfxEnabled: map['sfxEnabled'] as bool? ?? true,
      sfxVolume: (map['sfxVolume'] as num?)?.toDouble() ?? 0.7,
      ambientMelodiesEnabled: map['ambientMelodiesEnabled'] as bool? ?? true,
      showVirtualJoystick: map['showVirtualJoystick'] as bool? ?? true,
      joystickSize: (map['joystickSize'] as num?)?.toDouble() ?? 1.0,
      joystickOpacity: (map['joystickOpacity'] as num?)?.toDouble() ?? 0.85,
      joystickSensitivity: (map['joystickSensitivity'] as num?)?.toDouble() ?? 1.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory SettingsModel.fromJson(String source) =>
      SettingsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SettingsModel(master: $masterVolume, music: $musicEnabled ($musicVolume), sfx: $sfxEnabled ($sfxVolume), ambient: $ambientMelodiesEnabled, joystick: $showVirtualJoystick, size: $joystickSize, opacity: $joystickOpacity, sens: $joystickSensitivity)';
  }
}
