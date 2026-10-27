import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/app_state_controller.dart';
import '../../core/theme.dart';
import '../widgets/game_button.dart';

/// Settings screen restyled as an ancient Grimoire Tome with parchment cards and gold filigree.
/// Full live two-way synchronization, persisted via device storage, and responsive without overflow.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateController>(context);

    return Scaffold(
      backgroundColor: AppTheme.parchmentBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.mossGreen),
          tooltip: 'Back to Clearing',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SETTINGS',
          style: GoogleFonts.cinzel(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 3.0,
            color: AppTheme.textOlive,
          ),
        ),
        centerTitle: true,
        actions: [
          // Live "Saved to Grimoire" Status Pill
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.mossGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.antiqueGold.withValues(alpha: 0.6),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 13,
                      color: AppTheme.mossGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'SAVED',
                      style: GoogleFonts.cinzel(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.mossGreen,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SECTION 1: AUDIO HARMONIES
                  const _GrimoireSectionHeader(
                    title: 'AUDIO HARMONIES',
                    icon: Icons.music_note_rounded,
                  ),
                  const SizedBox(height: 12),

                  // Master Melodies Slider Card
                  _buildSliderCard(
                    icon: Icons.volume_up_rounded,
                    title: 'Master Melodies',
                    subtitle: 'Overall audio harmony across the clearing',
                    value: appState.masterVolume,
                    valueLabel: '${(appState.masterVolume * 100).toInt()}%',
                    onChanged: (val) => appState.setMasterVolume(val),
                  ),
                  const SizedBox(height: 12),

                  // Forest Wind & Music Toggle & Slider Card
                  _buildToggleWithSliderCard(
                    icon: Icons.auto_stories_rounded,
                    title: 'Forest Wind & Music',
                    subtitle: 'Ambient journey melodies and clearing songs',
                    isEnabled: appState.musicEnabled,
                    onToggle: (val) => appState.setMusicEnabled(val),
                    sliderValue: appState.musicVolume,
                    sliderValueLabel: '${(appState.musicVolume * 100).toInt()}%',
                    onSliderChanged: (val) => appState.setMusicVolume(val),
                  ),
                  const SizedBox(height: 12),

                  // Spell Sound Effects Toggle & Slider Card
                  _buildToggleWithSliderCard(
                    icon: Icons.flare_rounded,
                    title: 'Spell Sound Effects',
                    subtitle: 'Weapon slashes, starlight arrows, and bomb detonations',
                    isEnabled: appState.sfxEnabled,
                    onToggle: (val) => appState.setSfxEnabled(val),
                    sliderValue: appState.sfxVolume,
                    sliderValueLabel: '${(appState.sfxVolume * 100).toInt()}%',
                    onSliderChanged: (val) => appState.setSfxVolume(val),
                  ),
                  const SizedBox(height: 12),

                  // Ambient Forest Melodies Switch Card
                  _buildToggleCard(
                    icon: Icons.forest_rounded,
                    title: 'Ambient Melodies',
                    subtitle: 'Gentle rustling leaves and stream acoustics',
                    value: appState.ambientMelodiesEnabled,
                    onChanged: (val) => appState.setAmbientMelodiesEnabled(val),
                  ),
                  const SizedBox(height: 24),

                  // SECTION 2: EXPEDITION CONTROLS
                  const _GrimoireSectionHeader(
                    title: 'EXPEDITION CONTROLS',
                    icon: Icons.explore_rounded,
                  ),
                  const SizedBox(height: 12),

                  // Virtual Joystick Toggle Card (Fixed: No horizontal overflow)
                  _buildToggleCard(
                    icon: Icons.radio_button_checked_rounded,
                    title: 'Virtual Traveler Compass',
                    subtitle: appState.showVirtualJoystick
                        ? 'On-screen analog joystick enabled'
                        : 'Keyboard [WASD] / direct movement only',
                    value: appState.showVirtualJoystick,
                    onChanged: (val) => appState.setShowVirtualJoystick(val),
                  ),
                  const SizedBox(height: 12),

                  // Compass Size Slider Card (Active only if joystick is enabled)
                  if (appState.showVirtualJoystick) ...[
                    _buildSliderCard(
                      icon: Icons.aspect_ratio_rounded,
                      title: 'Compass Scale',
                      subtitle: 'Size of on-screen joystick touch target',
                      value: (appState.joystickSize - 0.75) / (1.5 - 0.75),
                      valueLabel: '${(appState.joystickSize * 100).toInt()}%',
                      onChanged: (normalized) {
                        final actual = 0.75 + (normalized * (1.5 - 0.75));
                        appState.setJoystickSize(actual);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Compass Opacity Slider Card
                    _buildSliderCard(
                      icon: Icons.opacity_rounded,
                      title: 'Compass Opacity',
                      subtitle: 'Transparency level during combat exploration',
                      value: (appState.joystickOpacity - 0.3) / (1.0 - 0.3),
                      valueLabel: '${(appState.joystickOpacity * 100).toInt()}%',
                      onChanged: (normalized) {
                        final actual = 0.3 + (normalized * (1.0 - 0.3));
                        appState.setJoystickOpacity(actual);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Compass Sensitivity Slider Card
                    _buildSliderCard(
                      icon: Icons.speed_rounded,
                      title: 'Compass Sensitivity',
                      subtitle: 'Analog response multiplier for movement',
                      value: (appState.joystickSensitivity - 0.5) / (2.0 - 0.5),
                      valueLabel: '${(appState.joystickSensitivity * 100).toInt()}%',
                      onChanged: (normalized) {
                        final actual = 0.5 + (normalized * (2.0 - 0.5));
                        appState.setJoystickSensitivity(actual);
                      },
                    ),
                    const SizedBox(height: 12),
                  ],

                  const SizedBox(height: 20),

                  // RESET TO DEFAULTS BUTTON
                  OutlinedButton.icon(
                    onPressed: () {
                      appState.resetToDefaults();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'All settings restored to factory defaults.',
                            style: GoogleFonts.nunito(
                              color: AppTheme.parchmentBackground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          backgroundColor: const Color(0xFF2E2429),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppTheme.antiqueGold, width: 1.0),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18, color: AppTheme.mossGreen),
                    label: Text(
                      'RESET TO DEFAULTS',
                      style: GoogleFonts.cinzel(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppTheme.mossGreen,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.antiqueGold, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppTheme.parchmentCard,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // RETURN TO CLEARING BUTTON
                  GameButton(
                    label: 'RETURN TO CLEARING',
                    icon: Icons.arrow_back_rounded,
                    isPrimary: true,
                    height: 52,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Card with an isolated slider and percentage chip.
  Widget _buildSliderCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required String valueLabel,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: AppTheme.parchmentCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.antiqueGold.withValues(alpha: 0.65),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.antiqueGold.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.mossGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cinzel(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textOlive,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.mossGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.antiqueGold.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  valueLabel,
                  style: GoogleFonts.cinzel(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.mossGreenDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textOliveMuted,
            ),
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.mossGreen,
              inactiveTrackColor: AppTheme.antiqueGold.withValues(alpha: 0.25),
              thumbColor: AppTheme.antiqueGold,
              overlayColor: AppTheme.mossGreen.withValues(alpha: 0.15),
              trackHeight: 4.0,
            ),
            child: Slider(
              value: value.clamp(0.0, 1.0),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  /// Card with a toggle switch and an attached volume slider (e.g. for music and sfx).
  Widget _buildToggleWithSliderCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isEnabled,
    required ValueChanged<bool> onToggle,
    required double sliderValue,
    required String sliderValueLabel,
    required ValueChanged<double> onSliderChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: AppTheme.parchmentCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.antiqueGold.withValues(alpha: 0.65),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.antiqueGold.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.mossGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cinzel(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textOlive,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textOliveMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                activeThumbColor: AppTheme.antiqueGold,
                activeTrackColor: AppTheme.mossGreen.withValues(alpha: 0.45),
                inactiveTrackColor: Colors.black12,
                inactiveThumbColor: AppTheme.textOliveMuted,
                onChanged: onToggle,
              ),
            ],
          ),
          if (isEnabled) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppTheme.mossGreen,
                      inactiveTrackColor: AppTheme.antiqueGold.withValues(alpha: 0.25),
                      thumbColor: AppTheme.antiqueGold,
                      overlayColor: AppTheme.mossGreen.withValues(alpha: 0.15),
                      trackHeight: 4.0,
                    ),
                    child: Slider(
                      value: sliderValue.clamp(0.0, 1.0),
                      onChanged: onSliderChanged,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.mossGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.antiqueGold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    sliderValueLabel,
                    style: GoogleFonts.cinzel(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.mossGreenDark,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Card with a safe toggle switch and flexible text layout to eliminate overflow.
  Widget _buildToggleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: AppTheme.parchmentCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.antiqueGold.withValues(alpha: 0.65),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.antiqueGold.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.mossGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cinzel(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textOlive,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textOliveMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            activeThumbColor: AppTheme.antiqueGold,
            activeTrackColor: AppTheme.mossGreen.withValues(alpha: 0.45),
            inactiveTrackColor: Colors.black12,
            inactiveThumbColor: AppTheme.textOliveMuted,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _GrimoireSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _GrimoireSectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.antiqueGold),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.cinzel(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            color: AppTheme.mossGreen,
          ),
        ),
      ],
    );
  }
}
