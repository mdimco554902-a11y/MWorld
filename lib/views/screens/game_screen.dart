import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/app_state_controller.dart';
import '../../controllers/game_controller.dart';
import '../../core/theme.dart';
import '../../models/game_entities.dart';
import '../../models/map_model.dart';
import '../../models/player_model.dart';
import '../../utils/responsive.dart';
import '../../utils/smooth_page_route.dart';
import '../widgets/arena_hamburger_menu.dart';
import '../widgets/game_button.dart';
import '../widgets/virtual_joystick.dart';
import 'settings_screen.dart';

/// Active arena screen reskinned to an Enchanted Forest Clearing with ancient stone ruins,
/// elf/mage avatars in robes with staffs and spellcraft, simultaneous WASD + Joystick,
/// and live 60 FPS combat.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final FocusNode _keyboardFocusNode = FocusNode();
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  Offset _joystickDirection = Offset.zero;
  Offset _keyboardDirection = Offset.zero;
  GameController? _gameController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gameController = Provider.of<GameController>(context, listen: false);
  }

  @override
  void dispose() {
    if (_gameController != null && _gameController!.isMatchActive) {
      _gameController!.quitMatch();
    }
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  bool _isMenuOpen = false;

  void _openHamburgerMenu() {
    setState(() {
      _isMenuOpen = true;
      _pressedKeys.clear();
      _joystickDirection = Offset.zero;
      _keyboardDirection = Offset.zero;
    });
    final gameController = Provider.of<GameController>(context, listen: false);
    gameController.setMovementInput(Offset.zero);
    gameController.pauseMatch();
  }

  void _closeHamburgerMenu() {
    setState(() {
      _isMenuOpen = false;
      _pressedKeys.clear();
      _joystickDirection = Offset.zero;
      _keyboardDirection = Offset.zero;
    });
    final gameController = Provider.of<GameController>(context, listen: false);
    gameController.setMovementInput(Offset.zero);
    gameController.resumeMatch();
    _keyboardFocusNode.requestFocus();
  }

  void _handleKeyEvent(KeyEvent event) {
    // Esc toggles the hamburger menu
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      if (_isMenuOpen) {
        _closeHamburgerMenu();
      } else {
        _openHamburgerMenu();
      }
      return;
    }

    // When menu is open, combat controls are disabled
    if (_isMenuOpen) return;

    if (event is KeyDownEvent) {
      _pressedKeys.add(event.logicalKey);
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(event.logicalKey);
    }

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      final gameController = Provider.of<GameController>(context, listen: false);
      gameController.performActiveAttack();
    }

    _updateKeyboardMovement();
  }

  void _updateKeyboardMovement() {
    if (_isMenuOpen) return;

    double dx = 0.0;
    double dy = 0.0;

    if (_pressedKeys.contains(LogicalKeyboardKey.keyW) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {
      dy -= 1.0;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyS) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {
      dy += 1.0;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyA) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {
      dx -= 1.0;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyD) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {
      dx += 1.0;
    }

    if (dx != 0.0 && dy != 0.0) {
      final length = math.sqrt(dx * dx + dy * dy);
      dx /= length;
      dy /= length;
    }

    _keyboardDirection = Offset(dx, dy);
    _syncMovementToController();
  }

  void _handleJoystickChanged(Offset direction) {
    if (_isMenuOpen) return;
    _joystickDirection = direction;
    _syncMovementToController();
  }

  void _syncMovementToController() {
    if (_isMenuOpen) return;
    final gameController = Provider.of<GameController>(context, listen: false);
    final effectiveDirection =
        _joystickDirection != Offset.zero ? _joystickDirection : _keyboardDirection;
    gameController.setMovementInput(effectiveDirection);
  }

  void _handleQuitMatch() {
    final gameController = Provider.of<GameController>(context, listen: false);
    gameController.quitMatch();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _handleRestartMatch() {
    final appState = Provider.of<AppStateController>(context, listen: false);
    final gameController = Provider.of<GameController>(context, listen: false);
    gameController.startMatch(
      playerNickname: appState.nickname,
      avatar: appState.selectedAvatar,
      map: appState.selectedMap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateController>(context);
    final gameController = Provider.of<GameController>(context);
    final player = gameController.player;

    final isMobile = Responsive.isMobile(context);
    final isLandscape = Responsive.isLandscape(context);
    final isPortrait = !isLandscape;
    final showKeyboard = Responsive.showKeyboardHints && !isMobile;

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: AppTheme.forestBackground,
        body: Stack(
          children: [
            // 1. Enchanted Forest Ruins Game Viewport Canvas
            Positioned.fill(
              child: RepaintBoundary(
                child: ClipRect(
                  child: AnimatedBuilder(
                    animation: gameController.canvasTickNotifier,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _EnchantedForestCanvasPainter(
                          player: gameController.player,
                          bots: gameController.bots,
                          obstacles: gameController.obstacles,
                          projectiles: gameController.projectiles,
                          bombs: gameController.bombs,
                          explosions: gameController.explosions,
                          slashes: gameController.slashes,
                          currentMap: gameController.currentMap,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // 2. Top HUD Bar (Parchment & Gold Grimoire Header)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 10.0 : 16.0,
                    vertical: isMobile ? 6.0 : 8.0,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 860),
                      child: RepaintBoundary(
                        child: _buildTopHudBar(context, gameController, player),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 3. Combat Notification / Action Banner
            Positioned(
              left: isMobile ? 12 : 20,
              right: isMobile ? 12 : 20,
              top: isMobile ? 66 : 76,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.forestSurface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.antiqueGold.withValues(alpha: 0.6),
                      width: 1.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    gameController.lastCombatAction,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: isMobile ? 11 : 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.antiqueGoldLight,
                    ),
                  ),
                ),
              ),
            ),

            // 4. Movement Virtual Joystick (Repositioned dynamically for portrait vs landscape)
            if (appState.showVirtualJoystick)
              Positioned(
                left: isLandscape ? 28 : (isMobile ? 16 : 24),
                bottom: isLandscape ? 20 : (isMobile ? 16 : 24),
                child: SafeArea(
                  child: RepaintBoundary(
                    child: AbsorbPointer(
                      absorbing: _isMenuOpen,
                      child: VirtualJoystick(
                        radius: ((isMobile && isPortrait) ? 50.0 : 62.0) * appState.joystickSize,
                        knobRadius: 24.0 * appState.joystickSize,
                        opacity: appState.joystickOpacity,
                        sensitivity: appState.joystickSensitivity,
                        onDirectionChanged: _handleJoystickChanged,
                      ),
                    ),
                  ),
                ),
              ),

            // 5. Spell Release Action Button (Repositioned for portrait vs landscape)
            Positioned(
              right: isLandscape ? 28 : (isMobile ? 16 : 24),
              bottom: isLandscape ? 20 : (isMobile ? 16 : 24),
              child: SafeArea(
                child: RepaintBoundary(
                  child: AbsorbPointer(
                    absorbing: _isMenuOpen,
                    child: _buildAttackActionWidget(
                      gameController,
                      isMobile && isPortrait,
                    ),
                  ),
                ),
              ),
            ),

            // 6. Keyboard Control Help Badge (Hidden on mobile/touch, shown on desktop/web)
            if (showKeyboard)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.forestSurface.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.antiqueGold.withValues(alpha: 0.3),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      'STRIDE: [WASD] or [COMPASS]  •  RELEASE SPELL: [SPACEBAR] or [GLYPH]',
                      style: GoogleFonts.cinzel(
                        fontSize: 10,
                        color: AppTheme.textForestMuted,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ),

            // 7. Spellbook Grimoire Page Modal (Victory / Defeat)
            if (gameController.isGameOver)
              Positioned.fill(
                child: _buildSpellbookEndModal(context, gameController),
              ),

            // 8. In-Match Hamburger Pause Drawer Menu (Top-Right Drawer)
            Positioned.fill(
              child: ArenaHamburgerMenu(
                isOpen: _isMenuOpen,
                onClose: _closeHamburgerMenu,
                onOpenFullSettings: () async {
                  await Navigator.push(
                    context,
                    SmoothPageRoute(page: const SettingsScreen()),
                  );
                  if (mounted) {
                    _keyboardFocusNode.requestFocus();
                  }
                },
                onRestartMatch: _handleRestartMatch,
                onQuitMatch: _handleQuitMatch,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHudBar(BuildContext context, GameController controller, PlayerModel? player) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final isMobileNarrow = availableWidth < 500;
        final isVeryNarrow = availableWidth < 380;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobileNarrow ? 10 : 16,
            vertical: isMobileNarrow ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: AppTheme.forestSurface.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.antiqueGold, width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Player Identity & Parchment-framed HP
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: isMobileNarrow ? 32 : 38,
                      height: isMobileNarrow ? 32 : 38,
                      decoration: BoxDecoration(
                        color: (player?.avatar?.robeColor ?? AppTheme.mossGreen).withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: player?.avatar?.trimColor ?? AppTheme.antiqueGold,
                          width: 1.2,
                        ),
                      ),
                      child: Icon(
                        Icons.auto_stories_rounded,
                        color: player?.avatar?.trimColor ?? AppTheme.antiqueGold,
                        size: isMobileNarrow ? 16 : 20,
                      ),
                    ),
                    SizedBox(width: isMobileNarrow ? 6 : 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            player?.name ?? 'Traveler',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cinzel(
                              fontSize: isMobileNarrow ? 12 : 14,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textForestLight,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: isVeryNarrow ? 56 : (isMobileNarrow ? 72 : 100),
                                height: 7,
                                decoration: BoxDecoration(
                                  color: Colors.black38,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: AppTheme.antiqueGold.withValues(alpha: 0.5),
                                    width: 0.8,
                                  ),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: ((player?.health ?? 100) / (player?.maxHealth ?? 100)).clamp(0.0, 1.0),
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
                              const SizedBox(width: 5),
                              Text(
                                '${player?.health.toInt() ?? 100} HP',
                                style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.pastoralHealthGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Badges Section (Adaptive based on available width)
              if (!isMobileNarrow) ...[
                const SizedBox(width: 6),
                _buildInfoBadge(
                  label: 'ARTIFACT',
                  value: controller.selectedWeapon.displayName.toUpperCase(),
                  icon: _getWeaponIcon(controller.selectedWeapon),
                ),
                const SizedBox(width: 6),
                _buildInfoBadge(
                  label: 'RUNE TRIAL',
                  value: controller.botDifficulty.displayName.toUpperCase(),
                  icon: Icons.shield_outlined,
                ),
              ],

              const SizedBox(width: 6),
              // Kills / Rite Completed Badge
              _buildInfoBadge(
                label: 'HARMONIES',
                value: '${player?.kills ?? 0}',
                icon: Icons.auto_awesome_rounded,
                compact: isMobileNarrow,
              ),

              const SizedBox(width: 8),
              // Hamburger Pill Menu Button (Top right only, min 48px touch target, 3 gold lines in dark forest pill)
              _buildHamburgerPillButton(context, isMobileNarrow),
            ],
          ),
        );
      },
    );
  }

  /// 3 Gold lines in a dark forest pill with min 48px touch target for opening the in-match drawer
  Widget _buildHamburgerPillButton(BuildContext context, bool isCompact) {
    final double buttonSize = isCompact ? 44.0 : 48.0;

    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: 'Expedition Menu',
        child: InkWell(
          key: const Key('hamburger_menu_button'),
          onTap: _openHamburgerMenu,
          borderRadius: BorderRadius.circular(12),
          hoverColor: AppTheme.antiqueGold.withValues(alpha: 0.2),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.forestCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.antiqueGold.withValues(alpha: 0.8),
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 18,
                  height: 2.2,
                  decoration: BoxDecoration(
                    color: AppTheme.antiqueGold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 3.5),
                Container(
                  width: 18,
                  height: 2.2,
                  decoration: BoxDecoration(
                    color: AppTheme.antiqueGold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 3.5),
                Container(
                  width: 18,
                  height: 2.2,
                  decoration: BoxDecoration(
                    color: AppTheme.antiqueGold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBadge({
    required String label,
    required String value,
    required IconData icon,
    bool compact = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: AppTheme.forestCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.antiqueGold.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: AppTheme.antiqueGold),
          SizedBox(width: compact ? 4 : 6),
          if (!compact)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cinzel(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textForestMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.cinzel(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textForestLight,
                  ),
                ),
              ],
            )
          else
            Text(
              value,
              style: GoogleFonts.cinzel(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.textForestLight,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAttackActionWidget(GameController gameController, [bool isCompact = false]) {
    final player = gameController.player;
    final isOffCooldown = (player?.attackCooldownTimer ?? 0) <= 0;
    final cooldownProgress = player != null && player.attackCooldownTimer > 0
        ? (player.attackCooldownTimer / player.weapon.attackCooldown).clamp(0.0, 1.0)
        : 0.0;
    final buttonSize = isCompact ? 68.0 : 82.0;

    return GestureDetector(
      onTap: () {
        _keyboardFocusNode.requestFocus();
        gameController.performActiveAttack();
      },
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isOffCooldown
              ? const RadialGradient(
                  colors: [
                    AppTheme.antiqueGoldLight,
                    AppTheme.mossGreen,
                    AppTheme.mossGreenDark,
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.grey.shade800,
                    Colors.grey.shade900,
                  ],
                ),
          border: Border.all(
            color: isOffCooldown ? AppTheme.antiqueGold : Colors.white24,
            width: 2.2,
          ),
          boxShadow: [
            if (isOffCooldown)
              BoxShadow(
                color: AppTheme.antiqueGold.withValues(alpha: 0.45),
                blurRadius: 16,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (cooldownProgress > 0)
              CircularProgressIndicator(
                value: cooldownProgress,
                strokeWidth: 4,
                color: AppTheme.antiqueGoldLight,
                backgroundColor: Colors.transparent,
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getWeaponIcon(gameController.selectedWeapon),
                  color: AppTheme.parchmentBackground,
                  size: 26,
                ),
                const SizedBox(height: 2),
                Text(
                  gameController.selectedWeapon.displayName.toUpperCase().split(' ').first,
                  style: GoogleFonts.cinzel(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.parchmentBackground,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Grimoire spellbook page modal for Victory / Defeat.
  Widget _buildSpellbookEndModal(BuildContext context, GameController controller) {
    final isVictory = controller.isVictory;

    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Container(
          width: 390,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppTheme.parchmentCard,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppTheme.antiqueGold,
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.antiqueGold.withValues(alpha: 0.35),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grimoire Emblem
              Icon(
                isVictory ? Icons.local_florist_rounded : Icons.spa_outlined,
                size: 54,
                color: isVictory ? AppTheme.mossGreen : AppTheme.softDamageRed,
              ),
              const SizedBox(height: 12),

              Text(
                isVictory ? 'EXPEDITION COMPLETE' : 'REST NOW, TRAVELER',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.2,
                  color: isVictory ? AppTheme.mossGreen : AppTheme.softDamageRed,
                ),
              ),
              const SizedBox(height: 6),

              Text(
                isVictory
                    ? 'The clearing whispers of your skill. All companion mages were gracefully bested.'
                    : 'The ancient grove pauses your footsteps. Take comfort by the campfire and try again.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: AppTheme.textOlive,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.parchmentBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.antiqueGold.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'HARMONIES: ${controller.player?.kills ?? 0}',
                      style: GoogleFonts.cinzel(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.mossGreen,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'TRIAL: ${controller.botDifficulty.displayName.toUpperCase()}',
                      style: GoogleFonts.cinzel(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.antiqueGold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              GameButton(
                label: 'VENTURE AGAIN',
                icon: Icons.replay_rounded,
                isPrimary: true,
                height: 52,
                onPressed: _handleRestartMatch,
              ),
              const SizedBox(height: 12),

              GameButton(
                label: 'RETURN TO CLEARING',
                icon: Icons.menu_book_rounded,
                isPrimary: false,
                height: 48,
                onPressed: _handleQuitMatch,
              ),
            ],
          ),
        ),
      ),
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

/// Custom painter rendering the Enchanted Forest Ruins:
/// Ancient mossy soil, stone tiles, rune circles, fallen logs, thorn hedges,
/// wooden chests, barrels, mossy stone ruin walls, and elf/mage characters in robes with visible
/// hands, animated stepping feet, and soft magical combat trails.
class _EnchantedForestCanvasPainter extends CustomPainter {
  final PlayerModel? player;
  final List<PlayerModel> bots;
  final List<CityObstacle> obstacles;
  final List<Projectile> projectiles;
  final List<BombEntity> bombs;
  final List<ExplosionEffect> explosions;
  final List<SlashEffect> slashes;
  final MapModel currentMap;

  // Cached Background Picture to avoid repainting static ground & obstacles on every frame
  static ui.Picture? _cachedBackground;
  static String? _cachedMapId;

  // Pre-allocated static Paint objects to eliminate GC allocations during 60 FPS gameplay
  static final Paint _bootPaint = Paint()..color = const Color(0xFF35261A);
  static final Paint _bootOutline = Paint()
    ..color = const Color(0xFF1E140C)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
  static final Paint _torsoPaint = Paint();
  static final Paint _torsoBorder = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4;
  static final Paint _mantlePaint = Paint()..strokeWidth = 1.8;
  static final Paint _handSkinPaint = Paint()..color = const Color(0xFFFED7AA);
  static final Paint _handBorder = Paint()
    ..color = const Color(0xFF8B5E3C).withValues(alpha: 0.7)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
  static final Paint _headPaint = Paint();
  static final Paint _earPaint = Paint()..color = const Color(0xFFFDCFA0);
  static final Paint _hairPaint = Paint();
  static final Paint _manaAuraPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.8;
  static final Paint _bladePaint = Paint()
    ..color = const Color(0xFFEDF2F7)
    ..strokeWidth = 3.5;
  static final Paint _guardPaint = Paint()
    ..color = AppTheme.antiqueGold
    ..strokeWidth = 6.0;
  static final Paint _runeGlowPaint = Paint()
    ..color = AppTheme.softMagic.withValues(alpha: 0.7)
    ..strokeWidth = 1.5;
  static final Paint _bowPaint = Paint()
    ..color = const Color(0xFFC49A6C)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.8;
  static final Paint _chordPaint = Paint()
    ..color = AppTheme.softMagic
    ..strokeWidth = 1.0;
  static final Paint _orbPaint = Paint()..color = const Color(0xFF283E38);
  static final Paint _runeCorePaint = Paint()..color = AppTheme.softMagic;
  static final Paint _hpBgPaint = Paint()..color = AppTheme.forestSurface.withValues(alpha: 0.85);
  static final Paint _hpFillPaint = Paint();
  static final Paint _hpBorderPaint = Paint()
    ..color = AppTheme.antiqueGold.withValues(alpha: 0.85)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.8;
  static final Paint _arrowShaftPaint = Paint()
    ..color = const Color(0xFFE2D9C5)
    ..strokeWidth = 2.0;
  static final Paint _arrowTipPaint = Paint()..color = AppTheme.softMagic;
  static final Path _arrowTipPath = Path()
    ..moveTo(14, 0)
    ..lineTo(8, -4)
    ..lineTo(8, 4)
    ..close();
  static final Paint _arrowTrailPaint = Paint()
    ..color = AppTheme.softMagic.withValues(alpha: 0.35)
    ..strokeWidth = 4.0;
  static final Paint _bombRuneGlow = Paint()
    ..color = AppTheme.antiqueGold.withValues(alpha: 0.16)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  static final Paint _bombOrbPaint = Paint()..color = const Color(0xFF223630);
  static final Paint _bombCorePaint = Paint();
  static final Paint _slashPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  static final Paint _shockwavePaint = Paint()
    ..style = PaintingStyle.stroke;
  static final Paint _manaBurstPaint = Paint()
    ..style = PaintingStyle.fill;

  _EnchantedForestCanvasPainter({
    required this.player,
    required this.bots,
    required this.obstacles,
    required this.projectiles,
    required this.bombs,
    required this.explosions,
    required this.slashes,
    required this.currentMap,
  });

  void _ensureBackgroundCached() {
    if (_cachedBackground != null && _cachedMapId == currentMap.id) {
      return;
    }
    _cachedBackground?.dispose();
    final recorder = ui.PictureRecorder();
    final bgCanvas = Canvas(recorder);
    _drawEnchantedForestGround(bgCanvas);
    _drawForestObstacles(bgCanvas);
    _cachedBackground = recorder.endRecording();
    _cachedMapId = currentMap.id;
  }

  @override
  void paint(Canvas canvas, Size size) {
    double cameraX = 0.0;
    double cameraY = 0.0;
    if (player != null) {
      cameraX = (size.width / 2) - player!.x;
      cameraY = (size.height / 2) - player!.y;
    }

    canvas.save();
    canvas.translate(cameraX, cameraY);

    // Fast GPU raster draw call of cached background
    _ensureBackgroundCached();
    canvas.drawPicture(_cachedBackground!);

    _drawMagicProjectiles(canvas);
    _drawRuneOrbs(canvas);

    for (final bot in bots) {
      if (bot.isAlive) {
        _drawElfMageCharacter(
          canvas: canvas,
          character: bot,
          robeColor: bot.avatar?.robeColor ??
              (bot.weapon == WeaponType.sword
                  ? const Color(0xFF6B4A3A) // Earthy wanderer
                  : (bot.weapon == WeaponType.bow ? const Color(0xFF385E48) : const Color(0xFF485875))),
          hairColor: bot.avatar?.hairColor ?? const Color(0xFFE8D3A2),
          trimColor: bot.avatar?.trimColor ?? AppTheme.antiqueGold,
          isLocalPlayer: false,
        );
      }
    }

    if (player != null && player!.isAlive) {
      _drawElfMageCharacter(
        canvas: canvas,
        character: player!,
        robeColor: player!.avatar?.robeColor ?? AppTheme.mossGreen,
        hairColor: player!.avatar?.hairColor ?? const Color(0xFFFDE68A),
        trimColor: player!.avatar?.trimColor ?? AppTheme.antiqueGold,
        isLocalPlayer: true,
      );
    }

    _drawMagicEffects(canvas);

    canvas.restore();
  }

  /// Draws the Enchanted Forest ground using the active realm's visual tokens:
  /// deep woodland moss, clearing soil trails, stone pavers, and ancient central magic rune circles.
  void _drawEnchantedForestGround(Canvas canvas) {
    const double w = GameController.mapWidth;
    const double h = GameController.mapHeight;

    // Deep forest floor base
    final forestFloorPaint = Paint()..color = currentMap.groundBaseColor;
    canvas.drawRect(const Rect.fromLTWH(0, 0, w, h), forestFloorPaint);

    // Pastoral glade soil path (gentle warm earthen trail)
    final soilPathPaint = Paint()..color = currentMap.pathColor;
    canvas.drawRect(const Rect.fromLTWH(70, 70, w - 140, h - 140), soilPathPaint);

    // Ancient moss-covered stone clearing ring in the center
    final stoneRingPaint = Paint()
      ..color = currentMap.ringColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2, h / 2), 170, stoneRingPaint);

    // Celestial Mana Glyphs / Ancient Forest Rune Rings
    final runeRingsPaint = Paint()
      ..color = currentMap.runeColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset(w / 2, h / 2), 80, runeRingsPaint);
    canvas.drawCircle(Offset(w / 2, h / 2), 160, runeRingsPaint);

    final softManaGlow = Paint()
      ..color = currentMap.runeColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(Offset(w / 2, h / 2), 120, softManaGlow);

    // Subtle Ancient Stone Flagstones
    final paverPaint = Paint()
      ..color = currentMap.ringColor.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;
    for (double x = 120; x < w - 120; x += 55) {
      canvas.drawLine(Offset(x, 100), Offset(x, h - 100), paverPaint);
    }
    for (double y = 100; y < h - 100; y += 55) {
      canvas.drawLine(Offset(100, y), Offset(w - 100, y), paverPaint);
    }

    // Outer Glade Woodland Border
    final borderGlow = Paint()
      ..color = currentMap.runeColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(const Rect.fromLTWH(0, 0, w, h), borderGlow);
  }

  /// Draws forest obstacles: mossy fallen oak logs, ancient stone ruins, thorn hedges,
  /// wooden chests, oak barrels, water wells, and mossy stone walls.
  void _drawForestObstacles(Canvas canvas) {
    for (final obs in obstacles) {
      final rect = obs.rect;

      switch (obs.type) {
        case ObstacleType.ruinedCar:
          // Rendered as: Mossy Fallen Oak Log & Ancient Ruin Pillar
          final logPaint = Paint()..color = currentMap.obstaclePrimaryColor;
          canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), logPaint);

          // Wood Bark Rings & Tree Knots
          final barkPaint = Paint()..color = currentMap.obstaclePrimaryColor.withValues(alpha: 0.8);
          canvas.drawCircle(Offset(rect.left + 12, rect.center.dy), 8, barkPaint);

          // Clinging Emerald Moss / Accents
          final mossPaint = Paint()..color = currentMap.obstacleAccentColor;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(rect.left + 6, rect.top + 2, rect.width * 0.7, 8),
              const Radius.circular(3),
            ),
            mossPaint,
          );
          break;

        case ObstacleType.concreteBarrier:
          // Rendered as: Thorn Hedge & Bramble Wooden Palisade
          final hedgePaint = Paint()..color = currentMap.obstaclePrimaryColor;
          canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(5)), hedgePaint);

          // Brambles & Flowering Buds
          final bramblePaint = Paint()
            ..color = currentMap.obstacleAccentColor
            ..strokeWidth = 2.0;
          for (double x = rect.left + 8; x < rect.right - 8; x += 14) {
            canvas.drawLine(Offset(x, rect.top + 3), Offset(x + 6, rect.bottom - 3), bramblePaint);
          }
          break;

        case ObstacleType.dumpster:
          // Rendered as: Ancient Forest Stone Shrine & Water Well
          final shrinePaint = Paint()..color = currentMap.obstaclePrimaryColor;
          canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), shrinePaint);

          // Well Water / Blue Mana Basin
          final basinRect = Rect.fromCenter(
            center: rect.center,
            width: rect.width * 0.65,
            height: rect.height * 0.65,
          );
          final waterPaint = Paint()..color = currentMap.runeColor.withValues(alpha: 0.65);
          canvas.drawRRect(RRect.fromRectAndRadius(basinRect, const Radius.circular(4)), waterPaint);
          break;

        case ObstacleType.crate:
          // Rendered as: Wooden Treasure Chest & Oak Barrel
          final chestPaint = Paint()..color = currentMap.obstaclePrimaryColor;
          canvas.drawRect(rect, chestPaint);

          // Warm Antique Gold Straps
          final goldStrapPaint = Paint()
            ..color = AppTheme.antiqueGold.withValues(alpha: 0.75)
            ..strokeWidth = 2.0;
          canvas.drawLine(Offset(rect.left, rect.top + 8), Offset(rect.right, rect.top + 8), goldStrapPaint);
          canvas.drawLine(Offset(rect.left, rect.bottom - 8), Offset(rect.right, rect.bottom - 8), goldStrapPaint);
          canvas.drawLine(Offset(rect.center.dx, rect.top), Offset(rect.center.dx, rect.bottom), goldStrapPaint);
          break;

        case ObstacleType.brickWall:
          // Rendered as: Ancient Mossy Stone Ruin Wall
          final stonePaint = Paint()..color = currentMap.obstaclePrimaryColor;
          canvas.drawRect(rect, stonePaint);

          // Ivy and Lichen accents
          final ivyPaint = Paint()
            ..color = currentMap.obstacleAccentColor
            ..strokeWidth = 1.5;
          for (double y = rect.top + 16; y < rect.bottom; y += 18) {
            canvas.drawLine(Offset(rect.left + 2, y), Offset(rect.right - 2, y), ivyPaint);
          }
          break;
      }

      // Antique Gold & Forest Outline
      final outlinePaint = Paint()
        ..color = AppTheme.antiqueGold.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), outlinePaint);
    }
  }

  /// Draws a Roblox-style Elf / Mage character in robes with visible body,
  /// hands holding weapon artifacts, animated stepping leather boots, and head with elven hair.
  void _drawElfMageCharacter({
    required Canvas canvas,
    required PlayerModel character,
    required Color robeColor,
    required Color hairColor,
    Color trimColor = AppTheme.antiqueGold,
    required bool isLocalPlayer,
  }) {
    canvas.save();
    canvas.translate(character.x, character.y);
    canvas.rotate(character.angle);

    final double walkSin = math.sin(character.walkCycle);
    final double footOffset = walkSin * 5.0;
    final double handOffset = walkSin * 4.0;

    // 1. FEET: Soft Leather Traveler Boots with animated stepping (reused static paint)
    final leftFootRect = Rect.fromCenter(
      center: Offset(-9, 11 + footOffset),
      width: 9,
      height: 12,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(leftFootRect, const Radius.circular(2)), _bootPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(leftFootRect, const Radius.circular(2)), _bootOutline);

    // Right Boot
    final rightFootRect = Rect.fromCenter(
      center: Offset(9, 11 - footOffset),
      width: 9,
      height: 12,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(rightFootRect, const Radius.circular(2)), _bootPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(rightFootRect, const Radius.circular(2)), _bootOutline);

    // 2. TORSO / BODY: Traveler Robe / Mantle with Antique Gold clasp
    final torsoRect = Rect.fromCenter(center: const Offset(0, 2), width: 34, height: 22);
    _torsoPaint.color = character.hitFlashTimer > 0 ? Colors.white : robeColor;
    canvas.drawRRect(RRect.fromRectAndRadius(torsoRect, const Radius.circular(5)), _torsoPaint);

    _torsoBorder.color = trimColor.withValues(alpha: 0.8);
    canvas.drawRRect(RRect.fromRectAndRadius(torsoRect, const Radius.circular(5)), _torsoBorder);

    // Robe Mantle Cowl Line
    _mantlePaint.color = trimColor.withValues(alpha: 0.7);
    canvas.drawLine(const Offset(-6, -8), const Offset(0, -3), _mantlePaint);
    canvas.drawLine(const Offset(6, -8), const Offset(0, -3), _mantlePaint);

    // 3. HANDS & EQUIPPED ARTIFACT WEAPONS
    final leftHandRect = Rect.fromCenter(
      center: Offset(-19, 2 - handOffset),
      width: 10,
      height: 10,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(leftHandRect, const Radius.circular(2)), _handSkinPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(leftHandRect, const Radius.circular(2)), _handBorder);

    // Right Hand (Swings forward during spell release)
    double rightHandX = 19;
    double rightHandY = 2 + handOffset;
    if (character.attackAnimTimer > 0) {
      rightHandY -= 12.0;
    }

    final rightHandRect = Rect.fromCenter(
      center: Offset(rightHandX, rightHandY),
      width: 10,
      height: 10,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(rightHandRect, const Radius.circular(2)), _handSkinPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(rightHandRect, const Radius.circular(2)), _handBorder);

    // Draw Equipped Artifact Weapon held in Hand
    _drawFantasyWeapon(
      canvas: canvas,
      weapon: character.weapon,
      handPos: Offset(rightHandX, rightHandY),
      isAttacking: character.attackAnimTimer > 0,
    );

    // 4. HEAD & ELVEN HAIR
    _headPaint.color = character.hitFlashTimer > 0 ? Colors.white : const Color(0xFFFED7AA);
    canvas.drawCircle(Offset.zero, 9.5, _headPaint);

    // Elven pointed ears peeking from side of head
    canvas.drawCircle(const Offset(-10, -2), 2.5, _earPaint);
    canvas.drawCircle(const Offset(10, -2), 2.5, _earPaint);

    // Elven Hair / Traveler Hood
    _hairPaint.color = hairColor;
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: 9.5),
      math.pi * 0.9,
      math.pi * 1.2,
      false,
      _hairPaint,
    );

    // 5. Player Companion Aura (Antique Gold Mana Ring)
    if (isLocalPlayer) {
      _manaAuraPaint.color = AppTheme.antiqueGold.withValues(alpha: 0.6);
      canvas.drawCircle(Offset.zero, 28, _manaAuraPaint);
    }

    canvas.restore();

    // 6. Floating Parchment-Framed Health Bar
    _drawParchmentHealthBar(canvas, character, isLocalPlayer);
  }

  void _drawFantasyWeapon({
    required Canvas canvas,
    required WeaponType weapon,
    required Offset handPos,
    required bool isAttacking,
  }) {
    switch (weapon) {
      case WeaponType.sword:
        canvas.drawLine(
          Offset(handPos.dx - 4, handPos.dy - 2),
          Offset(handPos.dx + 4, handPos.dy - 2),
          _guardPaint,
        );
        canvas.drawLine(
          Offset(handPos.dx, handPos.dy - 2),
          Offset(handPos.dx, handPos.dy - (isAttacking ? 34 : 26)),
          _bladePaint,
        );
        canvas.drawLine(
          Offset(handPos.dx, handPos.dy - 4),
          Offset(handPos.dx, handPos.dy - (isAttacking ? 30 : 22)),
          _runeGlowPaint,
        );
        break;

      case WeaponType.bow:
        canvas.drawArc(
          Rect.fromCenter(center: Offset(handPos.dx - 12, handPos.dy - 8), width: 32, height: 18),
          0,
          math.pi,
          false,
          _bowPaint,
        );
        canvas.drawLine(
          Offset(handPos.dx - 26, handPos.dy - 8),
          Offset(handPos.dx + 2, handPos.dy - 8),
          _chordPaint,
        );
        break;

      case WeaponType.bomb:
        canvas.drawCircle(Offset(handPos.dx, handPos.dy - 8), 7.5, _orbPaint);
        canvas.drawCircle(Offset(handPos.dx, handPos.dy - 8), 3.5, _runeCorePaint);
        break;
    }
  }

  void _drawParchmentHealthBar(Canvas canvas, PlayerModel character, bool isLocalPlayer) {
    const double barWidth = 44.0;
    const double barHeight = 5.0;
    final double barX = character.x - (barWidth / 2);
    final double barY = character.y - 34.0;

    // Parchment card base
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(barX, barY, barWidth, barHeight), const Radius.circular(2)),
      _hpBgPaint,
    );

    // Health Fill (Pastoral vitality green or soft danger red)
    final double fillRatio = (character.health / character.maxHealth).clamp(0.0, 1.0);
    _hpFillPaint.color = isLocalPlayer
        ? AppTheme.softMagic
        : (character.health > 35 ? AppTheme.pastoralHealthGreen : AppTheme.softDamageRed);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barX, barY, barWidth * fillRatio, barHeight),
        const Radius.circular(2),
      ),
      _hpFillPaint,
    );

    // Antique Gold Frame
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(barX, barY, barWidth, barHeight), const Radius.circular(2)),
      _hpBorderPaint,
    );
  }

  void _drawMagicProjectiles(Canvas canvas) {
    for (final p in projectiles) {
      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.angle);

      // Wooden Shaft
      canvas.drawLine(const Offset(-12, 0), const Offset(12, 0), _arrowShaftPaint);

      // Arrow Tip with Soft Magic Sheen
      canvas.drawPath(_arrowTipPath, _arrowTipPaint);

      // Soft Mana Trail
      canvas.drawLine(const Offset(-22, 0), const Offset(-10, 0), _arrowTrailPaint);

      canvas.restore();
    }
  }

  void _drawRuneOrbs(Canvas canvas) {
    for (final b in bombs) {
      final pulse = ((b.fuseTimer * 6).toInt() % 2 == 0);

      // Glowing Mana Glyph Ring
      canvas.drawCircle(Offset(b.x, b.y), b.blastRadius, _bombRuneGlow);

      // Rune Orb Core
      canvas.drawCircle(Offset(b.x, b.y), 9, _bombOrbPaint);

      // Pulsing Mana Core
      _bombCorePaint.color = pulse ? AppTheme.softMagic : AppTheme.antiqueGold;
      canvas.drawCircle(Offset(b.x, b.y), 4, _bombCorePaint);
    }
  }

  void _drawMagicEffects(Canvas canvas) {
    // Gold-Green Mana Slash Arcs
    for (final s in slashes) {
      final sweepAngle = math.pi * 0.7;
      final alpha = (1.0 - s.progress).clamp(0.0, 1.0);
      _slashPaint.color = AppTheme.softMagic.withValues(alpha: alpha * 0.8);
      _slashPaint.strokeWidth = 5.0 * (1.0 - s.progress * 0.4);

      canvas.drawArc(
        Rect.fromCircle(center: Offset(s.x, s.y), radius: s.radius * (0.8 + s.progress * 0.3)),
        s.angle - (sweepAngle / 2),
        sweepAngle,
        false,
        _slashPaint,
      );
    }

    // Celestial Mana Burst / Detonations
    for (final e in explosions) {
      final currentRadius = e.maxRadius * e.progress;
      final alpha = (1.0 - e.progress).clamp(0.0, 1.0);

      _shockwavePaint.color = AppTheme.antiqueGold.withValues(alpha: alpha * 0.75);
      _shockwavePaint.strokeWidth = 5.0 * (1.0 - e.progress);
      canvas.drawCircle(Offset(e.x, e.y), currentRadius, _shockwavePaint);

      _manaBurstPaint.color = AppTheme.softMagic.withValues(alpha: alpha * 0.45);
      canvas.drawCircle(Offset(e.x, e.y), currentRadius * 0.65, _manaBurstPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _EnchantedForestCanvasPainter oldDelegate) => true;
}
