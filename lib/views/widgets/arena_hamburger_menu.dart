import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/app_state_controller.dart';
import '../../controllers/game_controller.dart';
import '../../core/theme.dart';
import '../../models/player_model.dart';
import '../../utils/responsive.dart';
import '../widgets/game_button.dart';

/// In-match pause drawer menu sliding in from the right edge with M-World branding,
/// expedition snapshot, instant persistent quick settings, lore info, restart, and exit actions.
class ArenaHamburgerMenu extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final VoidCallback onOpenFullSettings;
  final VoidCallback onRestartMatch;
  final VoidCallback onQuitMatch;

  const ArenaHamburgerMenu({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.onOpenFullSettings,
    required this.onRestartMatch,
    required this.onQuitMatch,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = Responsive.isMobile(context);
    final isLandscape = Responsive.isLandscape(context);
    final isPortrait = !isLandscape;

    // Responsive width rules:
    // - Mobile portrait: about 85% of screen width (clamped min 300, max 420)
    // - Mobile landscape / tablet / desktop: 380 - 420px
    final double menuWidth = (isMobile && isPortrait)
        ? (screenWidth * 0.85).clamp(300.0, 420.0)
        : math.min(screenWidth * 0.45, 420.0).clamp(380.0, 420.0);

    return Stack(
      children: [
        // 1. Scrim (Dimmed background behind menu with tap-to-close)
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !isOpen,
            child: AnimatedOpacity(
              opacity: isOpen ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: GestureDetector(
                onTap: onClose,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.65),
                ),
              ),
            ),
          ),
        ),

        // 2. Sliding Drawer Panel
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          top: 0,
          bottom: 0,
          right: isOpen ? 0 : -menuWidth - 40,
          width: menuWidth,
          child: RepaintBoundary(
            child: _buildDrawerSurface(context),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerSurface(BuildContext context) {
    final appState = Provider.of<AppStateController>(context);
    final gameController = Provider.of<GameController>(context);
    final player = gameController.player;

    return Material(
      color: Colors.transparent,
      elevation: 16,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.forestSurface,
          border: Border(
            left: BorderSide(
              color: AppTheme.antiqueGold.withValues(alpha: 0.85),
              width: 1.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 24,
              offset: const Offset(-4, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Title Bar & Close Button
              _buildTopHeader(context),
              const Divider(height: 1, color: AppTheme.antiqueGoldLight),

              // Scrollable Menu Sections
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Expedition Snapshot Card (Read-only)
                      _buildExpeditionSnapshotCard(gameController, player),
                      const SizedBox(height: 16),

                      // 2. Resume Expedition (Primary Action)
                      GameButton(
                        label: 'RESUME EXPEDITION',
                        icon: Icons.play_arrow_rounded,
                        isPrimary: true,
                        height: 52,
                        onPressed: onClose,
                      ),
                      const SizedBox(height: 16),

                      // 3. Quick Settings (Instant & Persisted)
                      _buildQuickSettingsCard(context, appState),
                      const SizedBox(height: 16),

                      // 4. Controls / How to Play
                      _buildControlsCard(),
                      const SizedBox(height: 16),

                      // 5. Expedition Objective & Info
                      _buildExpeditionInfoCard(gameController),
                      const SizedBox(height: 16),

                      // 6. About M-World Lore Card
                      _buildAboutMWorldCard(),
                      const SizedBox(height: 20),

                      // 7. Restart Expedition Button
                      _buildRestartButton(context, gameController, appState.nickname),
                      const SizedBox(height: 12),

                      // 8. Exit to Landing Button
                      _buildExitButton(context),
                      const SizedBox(height: 24),

                      // 9. Read-only Lore Footer
                      const _MenuFooter(),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // SECTION 1: HEADER & EXPEDITION SNAPSHOT
  // =========================================================================

  Widget _buildTopHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Branding Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppTheme.mossGreen.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.antiqueGold.withValues(alpha: 0.8),
                          width: 1.0,
                        ),
                      ),
                      child: const Icon(
                        Icons.spa_rounded,
                        size: 14,
                        color: AppTheme.antiqueGold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'M-WORLD',
                        style: GoogleFonts.cinzel(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.4,
                          color: AppTheme.textForestLight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'MYTHRIL WORLD • BRAWL ARENA',
                  style: GoogleFonts.cinzel(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: AppTheme.antiqueGold,
                  ),
                ),
              ],
            ),
          ),

          // Close 'X' Button (Min 48px touch target)
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppTheme.antiqueGold),
            iconSize: 22,
            tooltip: 'Close Menu & Resume (Esc)',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            splashRadius: 24,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildExpeditionSnapshotCard(GameController controller, PlayerModel? player) {
    final healthRatio = ((player?.health ?? 100) / (player?.maxHealth ?? 100)).clamp(0.0, 1.0);
    final avatar = player?.avatar;

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppTheme.forestCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.antiqueGold.withValues(alpha: 0.6), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Avatar, Name & Class
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (avatar?.robeColor ?? AppTheme.mossGreen).withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: avatar?.trimColor ?? AppTheme.antiqueGold,
                    width: 1.4,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: avatar?.trimColor ?? AppTheme.antiqueGold,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player?.name ?? 'Traveler',
                      style: GoogleFonts.cinzel(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textForestLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      avatar?.className ?? 'Enchanted Traveler',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.antiqueGoldLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Trial Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.mossGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.mossGreen, width: 0.8),
                ),
                child: Text(
                  'PAUSED',
                  style: GoogleFonts.cinzel(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: AppTheme.pastoralHealthGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // HP Bar with values
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'VITALITY (HP)',
                    style: GoogleFonts.cinzel(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textForestMuted,
                    ),
                  ),
                  Text(
                    '${player?.health.toInt() ?? 100} / ${player?.maxHealth.toInt() ?? 100} HP',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: (player?.health ?? 100) > 30
                          ? AppTheme.pastoralHealthGreen
                          : AppTheme.softDamageRed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.antiqueGold.withValues(alpha: 0.4), width: 0.8),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: healthRatio,
                  child: Container(
                    decoration: BoxDecoration(
                      color: (player?.health ?? 100) > 30
                          ? AppTheme.pastoralHealthGreen
                          : AppTheme.softDamageRed,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Colors.white12),
          const SizedBox(height: 10),

          // 4-cell Snapshot Grid (Artifact, Difficulty, Harmonies, Realm Map)
          Row(
            children: [
              Expanded(
                child: _buildSnapshotItem(
                  icon: _getWeaponIcon(controller.selectedWeapon),
                  label: 'ARTIFACT',
                  value: controller.selectedWeapon.displayName,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSnapshotItem(
                  icon: Icons.shield_outlined,
                  label: 'DIFFICULTY',
                  value: controller.botDifficulty.displayName,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSnapshotItem(
                  icon: Icons.auto_awesome_rounded,
                  label: 'HARMONIES',
                  value: '${player?.kills ?? 0} Overcome',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSnapshotItem(
                  icon: Icons.map_rounded,
                  label: 'REALM MAP',
                  value: controller.currentMap.name,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSnapshotItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.antiqueGold.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.antiqueGold),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cinzel(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppTheme.textForestMuted,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.cinzel(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textForestLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // SECTION 3: QUICK SETTINGS (INSTANT & PERSISTED)
  // =========================================================================

  Widget _buildQuickSettingsCard(BuildContext context, AppStateController appState) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.forestCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.antiqueGold.withValues(alpha: 0.5), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: AppTheme.antiqueGold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'QUICK EXPEDITION SETTINGS',
                  style: GoogleFonts.cinzel(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppTheme.antiqueGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Applies live in match and persists to device storage',
            style: GoogleFonts.nunito(
              fontSize: 11,
              color: AppTheme.textForestMuted,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Colors.white12),
          const SizedBox(height: 8),

          // 1. Mute All Quick Toggle
          _buildSwitchRow(
            title: 'Mute All Audio',
            subtitle: 'Quick silence across master, music & spell SFX',
            value: appState.isMutedAll,
            icon: appState.isMutedAll ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            onChanged: (_) => appState.toggleMuteAll(),
          ),
          const SizedBox(height: 8),

          // 2. Master Volume Slider
          _buildSliderRow(
            title: 'Master Melodies',
            value: appState.masterVolume,
            valueLabel: '${(appState.masterVolume * 100).toInt()}%',
            icon: Icons.music_note_rounded,
            min: 0.0,
            max: 1.0,
            onChanged: appState.setMasterVolume,
          ),
          const SizedBox(height: 6),

          // 3. Music On/Off
          _buildSwitchRow(
            title: 'Forest Wind & Music',
            subtitle: 'Enchanted pastoral orchestral harmonies',
            value: appState.musicEnabled,
            icon: Icons.library_music_rounded,
            onChanged: appState.setMusicEnabled,
          ),
          const SizedBox(height: 6),

          // 4. Sound Effects On/Off
          _buildSwitchRow(
            title: 'Spell Sound Effects',
            subtitle: 'Slash arcs, starlight arrows & bomb blasts',
            value: appState.sfxEnabled,
            icon: Icons.auto_fix_high_rounded,
            onChanged: appState.setSfxEnabled,
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Colors.white12),
          const SizedBox(height: 8),

          // 5. Virtual Joystick Visibility
          _buildSwitchRow(
            title: 'Traveler Compass (Joystick)',
            subtitle: 'On-screen virtual analog steering control',
            value: appState.showVirtualJoystick,
            icon: Icons.explore_rounded,
            onChanged: appState.setShowVirtualJoystick,
          ),
          const SizedBox(height: 6),

          // 6. Joystick Size Slider
          if (appState.showVirtualJoystick) ...[
            _buildSliderRow(
              title: 'Compass Scale',
              value: appState.joystickSize,
              valueLabel: '${appState.joystickSize.toStringAsFixed(2)}x',
              icon: Icons.aspect_ratio_rounded,
              min: 0.75,
              max: 1.5,
              onChanged: appState.setJoystickSize,
            ),
            const SizedBox(height: 6),

            // 7. Joystick Sensitivity Slider
            _buildSliderRow(
              title: 'Compass Sensitivity',
              value: appState.joystickSensitivity,
              valueLabel: '${appState.joystickSensitivity.toStringAsFixed(2)}x',
              icon: Icons.speed_rounded,
              min: 0.5,
              max: 2.0,
              onChanged: appState.setJoystickSensitivity,
            ),
            const SizedBox(height: 10),
          ],

          // 8. Open Full Settings Link (Min 48px touch target)
          Center(
            child: OutlinedButton.icon(
              onPressed: onOpenFullSettings,
              icon: const Icon(Icons.settings_suggest_rounded, size: 18, color: AppTheme.antiqueGold),
              label: Text(
                'OPEN FULL SETTINGS',
                style: GoogleFonts.cinzel(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppTheme.antiqueGold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: BorderSide(color: AppTheme.antiqueGold.withValues(alpha: 0.6), width: 1.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.black26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.antiqueGold),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cinzel(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textForestLight,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    color: AppTheme.textForestMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppTheme.pastoralHealthGreen,
            activeTrackColor: AppTheme.mossGreen.withValues(alpha: 0.4),
            inactiveThumbColor: AppTheme.textForestMuted,
            inactiveTrackColor: Colors.black38,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required String title,
    required double value,
    required String valueLabel,
    required IconData icon,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: AppTheme.antiqueGold),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.cinzel(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textForestLight,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.mossGreen.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.antiqueGold.withValues(alpha: 0.4)),
                ),
                child: Text(
                  valueLabel,
                  style: GoogleFonts.cinzel(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.antiqueGoldLight,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.pastoralHealthGreen,
              inactiveTrackColor: Colors.black38,
              thumbColor: AppTheme.antiqueGold,
              overlayColor: AppTheme.antiqueGold.withValues(alpha: 0.2),
              trackHeight: 3.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // SECTION 4: CONTROLS & HOW TO PLAY
  // =========================================================================

  Widget _buildControlsCard() {
    final controls = [
      (
        Icons.explore_rounded,
        'Move & Stride',
        'Steer with virtual joystick or WASD / Arrow keys.',
      ),
      (
        Icons.auto_fix_high_rounded,
        'Release Spell',
        'Tap the attack Glyph button or tap [SPACEBAR].',
      ),
      (
        Icons.shield_rounded,
        'Tactical Cover',
        'Dodge behind mossy logs, stone pillars, and oak barrels to block flying arrows and blasts.',
      ),
      (
        Icons.emoji_events_rounded,
        'Expedition Victory',
        'Outmaneuver and defeat all companion bots in the clearing to complete the trial.',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppTheme.forestCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.antiqueGold.withValues(alpha: 0.4), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_esports_rounded, color: AppTheme.antiqueGold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'CONTROLS & HOW TO PLAY',
                    style: GoogleFonts.cinzel(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppTheme.antiqueGold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...controls.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item.$1, size: 15, color: AppTheme.pastoralHealthGreen),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$2,
                          style: GoogleFonts.cinzel(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textForestLight,
                          ),
                        ),
                        Text(
                          item.$3,
                          style: GoogleFonts.nunito(
                            fontSize: 10.5,
                            height: 1.35,
                            color: AppTheme.textForestMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // =========================================================================
  // SECTION 5: EXPEDITION INFO & ARTIFACT STATS
  // =========================================================================

  Widget _buildExpeditionInfoCard(GameController controller) {
    final weapon = controller.selectedWeapon;
    final map = controller.currentMap;

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppTheme.forestCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.antiqueGold.withValues(alpha: 0.4), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.explore_rounded, color: AppTheme.antiqueGold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'EXPEDITION OBJECTIVE & STATS',
                    style: GoogleFonts.cinzel(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppTheme.antiqueGold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Current Objective
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.mossGreen.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.flag_rounded, size: 18, color: AppTheme.pastoralHealthGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Objective: Outmaneuver all companion bots in the clearing to complete the trial.',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textForestLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Realm Map Info
          Text(
            'REALM GLADE: ${map.name.toUpperCase()}',
            style: GoogleFonts.cinzel(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.antiqueGold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            map.description,
            style: GoogleFonts.nunito(
              fontSize: 11,
              color: AppTheme.textForestMuted,
            ),
          ),
          const SizedBox(height: 10),

          // Equipped Artifact Stats (Read-only)
          Text(
            'EQUIPPED ARTIFACT: ${weapon.displayName.toUpperCase()}',
            style: GoogleFonts.cinzel(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.antiqueGold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Base Strike: ${weapon.baseDamage.toInt()} dmg • Stride Speed: ${weapon.moveSpeed.toInt()} px/s • Range: ${weapon.attackRange.toInt()}px • Cooldown: ${weapon.attackCooldown}s. (Artifact cannot be changed mid-match).',
            style: GoogleFonts.nunito(
              fontSize: 11,
              color: AppTheme.textForestMuted,
            ),
          ),
          const SizedBox(height: 10),

          // Lore Connection Line
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.mossGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.antiqueGold.withValues(alpha: 0.3)),
            ),
            child: Text(
              '✦ This trial takes place in Mythril World, the indestructible training crucible, so catastrophic spells are safe to unleash here.',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 12.5,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: AppTheme.antiqueGoldLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // SECTION 6: ABOUT M-WORLD (MYTHRIL WORLD LORE)
  // =========================================================================

  Widget _buildAboutMWorldCard() {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppTheme.forestCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.antiqueGold.withValues(alpha: 0.6), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_rounded, color: AppTheme.antiqueGold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'ABOUT M-WORLD',
                    style: GoogleFonts.cinzel(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppTheme.antiqueGold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"Mythril World is an indestructible, high-altitude training crucible where mages and warriors can unleash catastrophic spells without wrecking the fragile mortal realm."',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 13.5,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w700,
              height: 1.4,
              color: AppTheme.textForestLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Brawl Arena is a friendly trial inside Mythril World where mages and warriors train. Because the realm cannot be destroyed and the mortal plane is shielded from harm, companions clash freely with sweeping swords, starlight arrows, and rune detonations in safety.',
            style: GoogleFonts.nunito(
              fontSize: 11,
              height: 1.4,
              color: AppTheme.textForestMuted,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // SECTION 7 & 8: RESTART & EXIT CONFIRMATION ACTIONS
  // =========================================================================

  Widget _buildRestartButton(BuildContext context, GameController controller, String nickname) {
    return OutlinedButton.icon(
      onPressed: () => _showRestartConfirmDialog(context, controller, nickname),
      icon: const Icon(Icons.refresh_rounded, size: 18, color: AppTheme.antiqueGoldLight),
      label: Text(
        'RESTART EXPEDITION',
        style: GoogleFonts.cinzel(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: AppTheme.antiqueGoldLight,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        side: const BorderSide(color: AppTheme.antiqueGold, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: AppTheme.forestCard,
      ),
    );
  }

  void _showRestartConfirmDialog(BuildContext context, GameController controller, String nickname) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.forestSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppTheme.antiqueGold, width: 1.2),
          ),
          title: Row(
            children: [
              const Icon(Icons.refresh_rounded, color: AppTheme.antiqueGold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Restart Expedition?',
                  style: GoogleFonts.cinzel(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textForestLight,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'This will reset your vitality, Harmonies, companion bots, and position in ${controller.currentMap.name}. All current match progress will be restarted.',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: AppTheme.textForestMuted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'CANCEL',
                style: GoogleFonts.cinzel(color: AppTheme.textForestMuted, fontWeight: FontWeight.w700),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
                onClose(); // Close drawer menu
                onRestartMatch(); // Restart match logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.mossGreen,
                foregroundColor: AppTheme.parchmentBackground,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'RESTART',
                style: GoogleFonts.cinzel(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExitButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showExitConfirmDialog(context),
      icon: const Icon(Icons.logout_rounded, size: 18, color: AppTheme.softDamageRed),
      label: Text(
        'EXIT TO LANDING',
        style: GoogleFonts.cinzel(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: AppTheme.softDamageRed,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        side: BorderSide(color: AppTheme.softDamageRed.withValues(alpha: 0.8), width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: Colors.black26,
      ),
    );
  }

  void _showExitConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.forestSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: AppTheme.softDamageRed.withValues(alpha: 0.8), width: 1.2),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppTheme.softDamageRed),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Exit to Landing?',
                  style: GoogleFonts.cinzel(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textForestLight,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Current expedition progress in Mythril World will be lost. Are you sure you wish to return to the clearing?',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: AppTheme.textForestMuted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'STAY IN MATCH',
                style: GoogleFonts.cinzel(color: AppTheme.textForestMuted, fontWeight: FontWeight.w700),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
                onQuitMatch(); // Quit match logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.softDamageRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'EXIT TO LANDING',
                style: GoogleFonts.cinzel(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getWeaponIcon(WeaponType weapon) {
    switch (weapon) {
      case WeaponType.sword:
        return Icons.shield_moon_outlined;
      case WeaponType.bow:
        return Icons.explore_rounded;
      case WeaponType.bomb:
        return Icons.circle_outlined;
    }
  }
}

// =========================================================================
// SECTION 9: LORE FOOTER
// =========================================================================

class _MenuFooter extends StatelessWidget {
  const _MenuFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.antiqueGold.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            'M-WORLD • MYTHRIL WORLD',
            style: GoogleFonts.cinzel(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppTheme.antiqueGold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Tale v0.4.0 • Indestructible Training Crucible',
            style: GoogleFonts.nunito(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.textForestMuted,
            ),
          ),
        ],
      ),
    );
  }
}
