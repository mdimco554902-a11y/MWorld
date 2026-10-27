import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/avatar_model.dart';
import '../models/map_model.dart';
import '../models/settings_model.dart';

/// Controller managing global application state, persisted settings, avatar profile,
/// and selected expedition map. Serves as the single source of truth.
class AppStateController extends ChangeNotifier {
  static const String _prefsKeySettings = 'mworld_settings_v1';
  static const String _prefsKeyNickname = 'mworld_nickname_v1';

  SettingsModel _settings = SettingsModel.defaults;
  String _nickname = 'Sylwen Starwhisper';
  AvatarModel _selectedAvatar = AvatarModel.defaultAvatar;
  MapModel _selectedMap = MapModel.defaultMap;

  DateTime? _lastSavedTimestamp;
  bool _isInitialized = false;

  AppStateController({SettingsModel? initialSettings, String? initialNickname}) {
    if (initialSettings != null) _settings = initialSettings;
    if (initialNickname != null) _nickname = initialNickname;
    _loadFromPreferences();
  }

  // Getters
  SettingsModel get settings => _settings;
  double get masterVolume => _settings.masterVolume;
  bool get musicEnabled => _settings.musicEnabled;
  double get musicVolume => _settings.musicVolume;
  bool get sfxEnabled => _settings.sfxEnabled;
  double get sfxVolume => _settings.sfxVolume;
  bool get ambientMelodiesEnabled => _settings.ambientMelodiesEnabled;

  bool get showVirtualJoystick => _settings.showVirtualJoystick;
  double get joystickSize => _settings.joystickSize;
  double get joystickOpacity => _settings.joystickOpacity;
  double get joystickSensitivity => _settings.joystickSensitivity;

  String get nickname => _nickname;
  AvatarModel get selectedAvatar => _selectedAvatar;
  MapModel get selectedMap => _selectedMap;
  DateTime? get lastSavedTimestamp => _lastSavedTimestamp;
  bool get isInitialized => _isInitialized;

  /// Validates if the nickname contains non-empty characters.
  bool get isNicknameValid => _nickname.trim().isNotEmpty;

  /// Loads persisted settings and nickname from device storage.
  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_prefsKeySettings);
      if (settingsJson != null && settingsJson.isNotEmpty) {
        _settings = SettingsModel.fromJson(settingsJson);
      }

      final savedNickname = prefs.getString(_prefsKeyNickname);
      if (savedNickname != null && savedNickname.trim().isNotEmpty) {
        _nickname = savedNickname;
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings from SharedPreferences: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Internal helper to persist settings and update save timestamp.
  Future<void> _saveSettings() async {
    _lastSavedTimestamp = DateTime.now();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKeySettings, _settings.toJson());
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  /// Updates the player's nickname and persists to storage.
  void setNickname(String newNickname) {
    if (_nickname != newNickname) {
      _nickname = newNickname;
      notifyListeners();
      _saveNickname();
    }
  }

  Future<void> _saveNickname() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKeyNickname, _nickname);
    } catch (e) {
      debugPrint('Error saving nickname: $e');
    }
  }

  /// Sets the selected avatar and syncs nickname if appropriate.
  void setAvatar(AvatarModel avatar, {bool updateNickname = true}) {
    _selectedAvatar = avatar;
    if (updateNickname) {
      _nickname = avatar.name;
      _saveNickname();
    }
    notifyListeners();
  }

  /// Sets the selected expedition map.
  void setMap(MapModel map) {
    if (!map.isLocked) {
      _selectedMap = map;
      notifyListeners();
    }
  }

  // --- AUDIO MUTATORS ---

  /// Updates master volume [0.0 - 1.0].
  void setMasterVolume(double value) {
    final clamped = value.clamp(0.0, 1.0);
    if (_settings.masterVolume != clamped) {
      _settings = _settings.copyWith(masterVolume: clamped);
      notifyListeners();
      _saveSettings();
    }
  }

  /// Toggles background music.
  void setMusicEnabled(bool value) {
    if (_settings.musicEnabled != value) {
      _settings = _settings.copyWith(musicEnabled: value);
      notifyListeners();
      _saveSettings();
    }
  }

  /// Updates background music volume [0.0 - 1.0].
  void setMusicVolume(double value) {
    final clamped = value.clamp(0.0, 1.0);
    if (_settings.musicVolume != clamped) {
      _settings = _settings.copyWith(musicVolume: clamped);
      notifyListeners();
      _saveSettings();
    }
  }

  /// Toggles spell sound effects.
  void setSfxEnabled(bool value) {
    if (_settings.sfxEnabled != value) {
      _settings = _settings.copyWith(sfxEnabled: value);
      notifyListeners();
      _saveSettings();
    }
  }

  /// Updates spell sound effects volume [0.0 - 1.0].
  void setSfxVolume(double value) {
    final clamped = value.clamp(0.0, 1.0);
    if (_settings.sfxVolume != clamped) {
      _settings = _settings.copyWith(sfxVolume: clamped);
      notifyListeners();
      _saveSettings();
    }
  }

  /// Toggles ambient forest melodies.
  void setAmbientMelodiesEnabled(bool value) {
    if (_settings.ambientMelodiesEnabled != value) {
      _settings = _settings.copyWith(ambientMelodiesEnabled: value);
      notifyListeners();
      _saveSettings();
    }
  }

  // --- EXPEDITION CONTROLS MUTATORS ---

  /// Toggles visibility of on-screen virtual analog joystick.
  void setShowVirtualJoystick(bool value) {
    if (_settings.showVirtualJoystick != value) {
      _settings = _settings.copyWith(showVirtualJoystick: value);
      notifyListeners();
      _saveSettings();
    }
  }

  /// Updates virtual joystick scale [0.75 - 1.5].
  void setJoystickSize(double value) {
    final clamped = value.clamp(0.75, 1.5);
    if (_settings.joystickSize != clamped) {
      _settings = _settings.copyWith(joystickSize: clamped);
      notifyListeners();
      _saveSettings();
    }
  }

  /// Updates virtual joystick opacity [0.3 - 1.0].
  void setJoystickOpacity(double value) {
    final clamped = value.clamp(0.3, 1.0);
    if (_settings.joystickOpacity != clamped) {
      _settings = _settings.copyWith(joystickOpacity: clamped);
      notifyListeners();
      _saveSettings();
    }
  }

  /// Updates virtual joystick sensitivity [0.5 - 2.0].
  void setJoystickSensitivity(double value) {
    final clamped = value.clamp(0.5, 2.0);
    if (_settings.joystickSensitivity != clamped) {
      _settings = _settings.copyWith(joystickSensitivity: clamped);
      notifyListeners();
      _saveSettings();
    }
  }

  /// Whether master audio or both music and sound effects are currently muted.
  bool get isMutedAll => _settings.masterVolume == 0.0 || (!_settings.musicEnabled && !_settings.sfxEnabled);

  /// Quick toggle to mute or restore all audio output instantly.
  void toggleMuteAll() {
    if (isMutedAll) {
      _settings = _settings.copyWith(
        masterVolume: _settings.masterVolume == 0.0 ? 0.8 : _settings.masterVolume,
        musicEnabled: true,
        sfxEnabled: true,
        ambientMelodiesEnabled: true,
      );
    } else {
      _settings = _settings.copyWith(
        masterVolume: 0.0,
      );
    }
    notifyListeners();
    _saveSettings();
  }

  /// Resets all settings to factory default values and persists them immediately.
  void resetToDefaults() {
    _settings = SettingsModel.defaults;
    notifyListeners();
    _saveSettings();
  }
}
