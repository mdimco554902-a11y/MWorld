import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/app_state_controller.dart';
import '../../core/theme.dart';
import '../../models/avatar_model.dart';
import '../../models/map_model.dart';
import '../../models/player_model.dart';
import '../../utils/responsive.dart';
import '../../utils/smooth_page_route.dart';
import '../widgets/avatar_preview_painter.dart';
import '../widgets/game_button.dart';
import 'about_screen.dart';
import 'avatar_select_screen.dart';
import 'map_select_screen.dart';
import 'settings_screen.dart';

/// Landing / Main Menu screen reskinned to a Cozy Enchanted Forest Clearing
/// inspired by the tranquil, nostalgic mood of Frieren.
/// Features a slim top bar, 2-column hero section on desktop, How to Play,
/// Grimoire Weapon Artifacts, Maps Atlas teaser, Party teaser, Journey Chronicle,
/// Expedition Features, and lore footer.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with SingleTickerProviderStateMixin {
  late final TextEditingController _nicknameController;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _ambientAnimationController;

  final GlobalKey _journeyKey = GlobalKey();
  final GlobalKey _howToPlayKey = GlobalKey();
  final GlobalKey _grimoireKey = GlobalKey();
  final GlobalKey _mapsKey = GlobalKey();
  final GlobalKey _partyKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();

  List<AvatarModel> _previewParty = [];
  bool _isFocused = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppStateController>(context, listen: false);
    _nicknameController = TextEditingController(text: appState.nickname);
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });

    _ambientAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _previewParty = AvatarModel.generatePresets().take(4).toList();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _ambientAnimationController.dispose();
    super.dispose();
  }

  void _scrollToKey(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _shufflePreviewParty() {
    setState(() {
      _previewParty = AvatarModel.generatePresets().take(4).toList();
    });
  }

  Future<T?> _navigateTo<T>(Widget page) async {
    _ambientAnimationController.stop();
    final result = await Navigator.push<T>(
      context,
      SmoothPageRoute(page: page),
    );
    if (mounted) {
      _ambientAnimationController.repeat();
    }
    return result;
  }

  void _handlePlayPressed() {
    final text = _nicknameController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your traveler name before venturing!';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    final appState = Provider.of<AppStateController>(context, listen: false);
    appState.setNickname(text);

    _navigateTo(const AvatarSelectScreen());
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: AppTheme.parchmentBackground,
      body: Stack(
        children: [
          // 1. Pastoral Enchanted Forest Clearing with animated petals & fireflies
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _ambientAnimationController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ForestClearingAmbientPainter(
                      animationValue: _ambientAnimationController.value,
                    ),
                  );
                },
              ),
            ),
          ),

          // 2. Responsive Scrollable Page with Slim Top Bar & Professional Content Grid
          SafeArea(
            child: Column(
              children: [
                // Slim Top Bar (Navigation & Tale version)
                _buildTopBar(isDesktop),

                // Main Scrollable Content Body
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 32.0 : 16.0,
                      vertical: 16.0,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1280),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // HERO SECTION (2 balanced columns on desktop, stacked on mobile)
                            KeyedSubtree(
                              key: _journeyKey,
                              child: isDesktop
                                  ? _buildDesktopHeroSection()
                                  : _buildMobileHeroSection(),
                            ),
                            const SizedBox(height: 36),

                            // SECTION 1: HOW TO PLAY
                            KeyedSubtree(
                              key: _howToPlayKey,
                              child: _buildHowToPlaySection(isDesktop),
                            ),
                            const SizedBox(height: 36),

                            // SECTION 2: GRIMOIRE / WEAPON ARTIFACTS
                            KeyedSubtree(
                              key: _grimoireKey,
                              child: _buildGrimoireSection(isDesktop),
                            ),
                            const SizedBox(height: 36),

                            // SECTION 3: EXPEDITION MAPS ATLAS TEASER
                            KeyedSubtree(
                              key: _mapsKey,
                              child: _buildMapsAtlasSection(isDesktop),
                            ),
                            const SizedBox(height: 36),

                            // SECTION 4: PARTY / TRAVELER TEASER
                            KeyedSubtree(
                              key: _partyKey,
                              child: _buildPartySection(isDesktop),
                            ),
                            const SizedBox(height: 36),

                            // SECTION 5: JOURNEY CHRONICLE TIMELINE
                            _buildJourneyChronicleSection(isDesktop),
                            const SizedBox(height: 36),

                            // SECTION 6: EXPEDITION FEATURES GRID
                            KeyedSubtree(
                              key: _featuresKey,
                              child: _buildFeaturesSection(isDesktop),
                            ),
                            const SizedBox(height: 40),

                            // LORE FOOTER
                            const _PageFooter(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TOP BAR
  // ==========================================
  Widget _buildTopBar(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32.0 : 16.0,
        vertical: 10.0,
      ),
      decoration: BoxDecoration(
        color: AppTheme.parchmentCard.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.antiqueGold.withValues(alpha: 0.4),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.antiqueGold.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo + Brand Title
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _scrollToKey(_journeyKey),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.mossGreen.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.antiqueGold.withValues(alpha: 0.7),
                                width: 1.0,
                              ),
                            ),
                            child: const Icon(
                              Icons.spa_rounded,
                              size: 18,
                              color: AppTheme.mossGreen,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'M-WORLD',
                                style: GoogleFonts.cinzel(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.8,
                                  color: AppTheme.textOlive,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(width: 1, height: 12, color: AppTheme.antiqueGold),
                              const SizedBox(width: 6),
                              Text(
                                'BRAWL ARENA',
                                style: GoogleFonts.cinzel(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                  color: AppTheme.mossGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Center Navigation Links (Web/Desktop only)
              if (isDesktop)
                Row(
                  children: [
                    _buildNavLink('Journey', () => _scrollToKey(_journeyKey)),
                    _buildNavLink('How to Play', () => _scrollToKey(_howToPlayKey)),
                    _buildNavLink('Grimoire', () => _scrollToKey(_grimoireKey)),
                    _buildNavLink('Maps', () => _scrollToKey(_mapsKey)),
                    _buildNavLink('Party', () => _scrollToKey(_partyKey)),
                    _buildNavLink('Features', () => _scrollToKey(_featuresKey)),
                  ],
                ),

              // Right Version Badge
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.parchmentBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.antiqueGold.withValues(alpha: 0.6),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.mossGreen,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'TALE v0.4.0',
                        style: GoogleFonts.cinzel(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: AppTheme.antiqueGold,
                        ),
                      ),
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

  Widget _buildNavLink(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.textOlive,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: GoogleFonts.cinzel(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: AppTheme.textOlive,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // HERO SECTION (DESKTOP & MOBILE)
  // ==========================================
  Widget _buildDesktopHeroSection() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Sticky Action Card
          SizedBox(
            width: 440,
            child: _buildHeroActionCard(),
          ),
          const SizedBox(width: 24),

          // Right Hero Panel with Chronicles Story, Forest Illustration, and Stats
          Expanded(
            child: _buildHeroStoryPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeroActionCard(),
        const SizedBox(height: 20),
        _buildHeroStoryPanel(),
      ],
    );
  }

  /// Left Action Card: Title, Callsign Input, Play, Settings, About
  Widget _buildHeroActionCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 26.0),
      decoration: BoxDecoration(
        color: AppTheme.parchmentCard.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.antiqueGold, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.antiqueGold.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppTheme.mossGreen.withValues(alpha: 0.06),
            blurRadius: 36,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Grimoire Title Header
          const _GrimoireTitleHeader(),
          const SizedBox(height: 22),

          // Callsign Input Field (Editable, Enter triggers Play)
          _buildNicknameSection(),
          const SizedBox(height: 20),

          // 1. PLAY BUTTON (Large Primary Moss Green)
          GameButton(
            label: 'PLAY',
            icon: Icons.auto_awesome_rounded,
            isPrimary: true,
            height: 56,
            onPressed: _handlePlayPressed,
          ),
          const SizedBox(height: 12),

          // 2. SETTINGS BUTTON (Dark Forest / Gold Secondary)
          GameButton(
            label: 'SETTINGS',
            icon: Icons.menu_book_rounded,
            isPrimary: false,
            height: 48,
            onPressed: () => _navigateTo(const SettingsScreen()),
          ),
          const SizedBox(height: 12),

          // 3. ABOUT BUTTON (Dark Forest / Gold Secondary)
          GameButton(
            label: 'ABOUT',
            icon: Icons.local_florist_rounded,
            isPrimary: false,
            height: 48,
            onPressed: () => _navigateTo(const AboutScreen()),
          ),
          const SizedBox(height: 20),

          // Action Card Footer Status
          const _StorybookFooter(),
        ],
      ),
    );
  }

  Widget _buildNicknameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
          child: Row(
            children: [
              const Icon(
                Icons.edit_note_rounded,
                size: 18,
                color: AppTheme.mossGreen,
              ),
              const SizedBox(width: 6),
              Text(
                'BRAWLER CALLSIGN',
                style: GoogleFonts.cinzel(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: _isFocused ? AppTheme.mossGreen : AppTheme.textOliveMuted,
                ),
              ),
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppTheme.antiqueGold.withValues(alpha: 0.3),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: _nicknameController,
            focusNode: _focusNode,
            maxLength: 16,
            style: GoogleFonts.nunito(
              color: AppTheme.textOlive,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            cursorColor: AppTheme.mossGreen,
            decoration: InputDecoration(
              counterText: '',
              hintText: 'Enter your companion name...',
              errorText: _errorMessage,
              prefixIcon: const Icon(
                Icons.history_edu_rounded,
                color: AppTheme.mossGreen,
                size: 22,
              ),
            ),
            onSubmitted: (_) => _handlePlayPressed(),
          ),
        ),
      ],
    );
  }

  /// Right Hero Panel with Chronicles Story, Soft Forest Illustration, and Stats Strip
  Widget _buildHeroStoryPanel() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppTheme.parchmentCard.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.antiqueGold, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.antiqueGold.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Story Heading & Paragraph
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_stories_rounded, color: AppTheme.mossGreen, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'CHRONICLES OF THE GROVE',
                        style: GoogleFonts.cinzel(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: AppTheme.mossGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Mythril World is an indestructible, high-altitude training crucible where mages and warriors can unleash catastrophic spells without wrecking the fragile mortal realm. Along tranquil glades and sunlit ruins in the Brawl Arena, a small party of peaceful wandering mages and elves gathers in friendly arena duels to hone their spellcraft. Dodge behind mossy logs, weave starlight arrows, and test elder relics without fear of harming the mortal world.',
                style: GoogleFonts.nunito(
                  fontSize: 13.5,
                  height: 1.55,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textOlive,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Soft Forest Landscape Illustration (Taller, expansive atmospheric scenic banner)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 185,
              child: CustomPaint(
                painter: _PastoralForestBannerPainter(),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Narrative Lore Excerpt Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.parchmentBackground.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.antiqueGold.withValues(alpha: 0.35),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.format_quote_rounded,
                  size: 16,
                  color: AppTheme.antiqueGold,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"The journey itself is the reward — slow days, warm tea, and spells cast under ancient trees."',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textOlive,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Stats Strip (3 Weapons, 7 Maps, 8 Avatars, 3 Difficulties)
          _buildStatsStrip(),
        ],
      ),
    );
  }

  Widget _buildStatsStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.parchmentBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.antiqueGold.withValues(alpha: 0.5),
          width: 1.0,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatPill('3', 'WEAPONS'),
            Container(width: 1, height: 20, margin: const EdgeInsets.symmetric(horizontal: 12), color: AppTheme.antiqueGold.withValues(alpha: 0.3)),
            _buildStatPill('7', 'MAPS'),
            Container(width: 1, height: 20, margin: const EdgeInsets.symmetric(horizontal: 12), color: AppTheme.antiqueGold.withValues(alpha: 0.3)),
            _buildStatPill('8', 'AVATARS'),
            Container(width: 1, height: 20, margin: const EdgeInsets.symmetric(horizontal: 12), color: AppTheme.antiqueGold.withValues(alpha: 0.3)),
            _buildStatPill('3', 'DIFFICULTIES'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(String number, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          number,
          style: GoogleFonts.cinzel(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppTheme.mossGreen,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.cinzel(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppTheme.textOliveMuted,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION 1: HOW TO PLAY
  // ==========================================
  Widget _buildHowToPlaySection(bool isDesktop) {
    final steps = [
      _PlayStep(
        icon: Icons.sports_esports_rounded,
        title: 'Move & Stride',
        description: 'Steer your traveler using virtual joystick or WASD / Arrow keys.',
        shortcut: 'WASD / COMPASS',
      ),
      _PlayStep(
        icon: Icons.flash_on_rounded,
        title: 'Cast & Attack',
        description: 'Release weapon spells by tapping the Glyph button or pressing Spacebar.',
        shortcut: 'SPACEBAR / GLYPH',
      ),
      _PlayStep(
        icon: Icons.shield_rounded,
        title: 'Tactical Cover',
        description: 'Dodge behind ancient stone pillars and mossy logs to absorb arrows.',
        shortcut: 'LOGS & RUINS',
      ),
      _PlayStep(
        icon: Icons.military_tech_rounded,
        title: 'Expedition Victory',
        description: 'Outmaneuver all companion bots in the clearing to complete the trial.',
        shortcut: 'HARMONIES',
      ),
    ];

    return _buildSectionContainer(
      title: 'HOW TO PLAY',
      subtitle: 'Simple, responsive controls designed for mouse, touch, and physical keyboard',
      icon: Icons.explore_rounded,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = isDesktop ? 4 : (constraints.maxWidth > 580 ? 2 : 1);
          if (columns == 4) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: steps
                  .map((s) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: _buildHowToPlayCard(s),
                        ),
                      ))
                  .toList(),
            );
          } else if (columns == 2) {
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: steps.map((s) {
                return SizedBox(
                  width: (constraints.maxWidth - 12) / 2,
                  child: _buildHowToPlayCard(s),
                );
              }).toList(),
            );
          }
          return Column(
            children: steps
                .map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: _buildHowToPlayCard(s),
                    ))
                .toList(),
          );
        },
      ),
    );
  }

  Widget _buildHowToPlayCard(_PlayStep step) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.parchmentBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.antiqueGold.withValues(alpha: 0.5),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.mossGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.antiqueGold.withValues(alpha: 0.5),
                  ),
                ),
                child: Icon(step.icon, size: 20, color: AppTheme.mossGreen),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.mossGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.antiqueGold.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  step.shortcut,
                  style: GoogleFonts.cinzel(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppTheme.mossGreenDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            step.title,
            style: GoogleFonts.cinzel(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.mossGreenDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            step.description,
            style: GoogleFonts.nunito(
              fontSize: 11.5,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: AppTheme.textOliveMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 2: GRIMOIRE / WEAPON ARTIFACTS
  // ==========================================
  Widget _buildGrimoireSection(bool isDesktop) {
    final weapons = [
      _WeaponCardInfo(
        type: WeaponType.sword,
        name: 'SWORD: VERDANT SLASH',
        role: 'Agile Melee Cleave',
        description: 'Fast sweeping blade strikes with broad arc, nimble movement, and +40 Bonus Health.',
        damage: 48,
        speed: 175,
        rangeLabel: 'Close Melee',
        cooldown: '0.38s',
        bonusHealth: '+40 HP',
        icon: Icons.shield_moon_outlined,
      ),
      _WeaponCardInfo(
        type: WeaponType.bow,
        name: 'BOW: STARLIGHT ARROW',
        role: 'Precision Ranged Archer',
        description: 'High-velocity starlight arrows that pierce opponents over vast forest clearings.',
        damage: 34,
        speed: 145,
        rangeLabel: '420 px (Long)',
        cooldown: '0.55s',
        bonusHealth: 'Base 100 HP',
        icon: Icons.explore_rounded,
      ),
      _WeaponCardInfo(
        type: WeaponType.bomb,
        name: 'BOMB: RUNE DETONATION',
        role: 'Area Burst Demolition',
        description: 'Plants heavy rune orbs that explode after a 1.8s fuse with massive AoE and +75 Bonus Health.',
        damage: 75,
        speed: 120,
        rangeLabel: '160 px AoE',
        cooldown: '1.30s',
        bonusHealth: '+75 HP Armor',
        icon: Icons.circle_outlined,
      ),
    ];

    return _buildSectionContainer(
      title: 'GRIMOIRE WEAPON ARTIFACTS',
      subtitle: 'Each enchanted tool dictates unique combat mobility, health pools, and incantations',
      icon: Icons.auto_stories_rounded,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 720;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: weapons
                  .map((w) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: _buildWeaponCard(w),
                        ),
                      ))
                  .toList(),
            );
          }
          return Column(
            children: weapons
                .map((w) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildWeaponCard(w),
                    ))
                .toList(),
          );
        },
      ),
    );
  }

  Widget _buildWeaponCard(_WeaponCardInfo weapon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.parchmentBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.antiqueGold.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.mossGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.antiqueGold.withValues(alpha: 0.5)),
                ),
                child: Icon(weapon.icon, size: 22, color: AppTheme.mossGreen),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weapon.name,
                      style: GoogleFonts.cinzel(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textOlive,
                      ),
                    ),
                    Text(
                      weapon.role,
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.mossGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            weapon.description,
            style: GoogleFonts.nunito(
              fontSize: 11.5,
              height: 1.4,
              color: AppTheme.textOliveMuted,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.antiqueGoldLight),
          const SizedBox(height: 12),

          // Stat Indicators
          _buildStatRow('Base Damage', '${weapon.damage.toInt()} HP', weapon.damage / 75.0),
          const SizedBox(height: 6),
          _buildStatRow('Move Stride', '${weapon.speed.toInt()} px/s', weapon.speed / 175.0),
          const SizedBox(height: 6),
          _buildStatRow('Attack Range', weapon.rangeLabel, null),
          const SizedBox(height: 6),
          _buildStatRow('Bonus Vitality', weapon.bonusHealth, null),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, double? progress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.cinzel(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textOliveMuted,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: FittedBox(
            alignment: Alignment.centerRight,
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (progress != null) ...[
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.mossGreen,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  value,
                  style: GoogleFonts.cinzel(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textOlive,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION 3: EXPEDITION MAPS ATLAS TEASER
  // ==========================================
  Widget _buildMapsAtlasSection(bool isDesktop) {
    final maps = MapModel.allMaps;

    return _buildSectionContainer(
      title: 'EXPEDITION MAPS ATLAS',
      subtitle: '7 ancient realms across the forest kingdom — 5 open glades & 2 sealed elder shrines',
      icon: Icons.map_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Horizontal strip of map preview cards
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: maps.map((map) {
                return Container(
                  width: 175,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.parchmentBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: map.isLocked
                          ? Colors.black26
                          : AppTheme.antiqueGold.withValues(alpha: 0.6),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 90,
                          child: map.isLocked
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    RepaintBoundary(
                                      child: ImageFiltered(
                                        imageFilter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                                        child: Container(color: map.groundBaseColor),
                                      ),
                                    ),
                                    Container(
                                      color: Colors.black.withValues(alpha: 0.45),
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.lock_rounded, color: AppTheme.antiqueGold, size: 22),
                                          SizedBox(height: 2),
                                          Text(
                                            'SEALED',
                                            style: TextStyle(
                                              fontSize: 8,
                                              color: Colors.white70,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Container(
                                  color: map.groundBaseColor,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: map.runeColor.withValues(alpha: 0.5)),
                                        ),
                                      ),
                                      Icon(Icons.explore_rounded, color: map.runeColor, size: 20),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Name
                      Text(
                        map.isLocked ? '???' : map.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cinzel(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textOlive,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Tag
                      Text(
                        map.isLocked ? 'Sealed Elder Shrine' : map.coverTag,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: map.isLocked ? AppTheme.softDamageRed : AppTheme.mossGreen,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Action button to open full Map Select
          Center(
            child: OutlinedButton.icon(
              onPressed: () => _navigateTo(const MapSelectScreen()),
              icon: const Icon(Icons.travel_explore_rounded, size: 18, color: AppTheme.mossGreen),
              label: Text(
                'VIEW ALL 7 REALMS IN MAP SELECT',
                style: GoogleFonts.cinzel(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppTheme.mossGreen,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.antiqueGold, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                backgroundColor: AppTheme.parchmentBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 4: PARTY / TRAVELER TEASER
  // ==========================================
  Widget _buildPartySection(bool isDesktop) {
    return _buildSectionContainer(
      title: 'PARTY TRAVELER PRESETS',
      subtitle: 'Elves, apprentice mages, and hedge knights ready to venture into the grove',
      icon: Icons.groups_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 580;
              if (isWide) {
                return Row(
                  children: _previewParty.map((avatar) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: _buildPartyPreviewCard(avatar),
                      ),
                    );
                  }).toList(),
                );
              }
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _previewParty.map((avatar) {
                  return SizedBox(
                    width: (constraints.maxWidth - 10) / 2,
                    child: _buildPartyPreviewCard(avatar),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 16),

          // Actions: Open Avatar Picker & Shuffle Presets
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _shufflePreviewParty,
                icon: const Icon(Icons.shuffle_rounded, size: 16, color: AppTheme.textOlive),
                label: Text(
                  'SHUFFLE PREVIEWS',
                  style: GoogleFonts.cinzel(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: AppTheme.textOlive,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.antiqueGold, width: 1.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  backgroundColor: AppTheme.parchmentBackground,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _navigateTo(const AvatarSelectScreen()),
                icon: const Icon(Icons.face_rounded, size: 16, color: Colors.white),
                label: Text(
                  'OPEN AVATAR PICKER',
                  style: GoogleFonts.cinzel(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(140, 44),
                  backgroundColor: AppTheme.mossGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartyPreviewCard(AvatarModel avatar) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.parchmentBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.antiqueGold.withValues(alpha: 0.5),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CustomPaint(
              painter: AvatarPreviewPainter(avatar: avatar),
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              avatar.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textOlive,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              avatar.className,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.mossGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 5: JOURNEY CHRONICLE TIMELINE
  // ==========================================
  Widget _buildJourneyChronicleSection(bool isDesktop) {
    final stops = [
      _JourneyStop(name: 'Departure', desc: 'Peaceful Village Outskirts', isLocked: false),
      _JourneyStop(name: 'Whispering Clearing', desc: 'Ancient Elder Pines & Logs', isLocked: false),
      _JourneyStop(name: 'Sunlit Ruins', desc: 'Courtyards & Arcane Starlight', isLocked: false),
      _JourneyStop(name: 'Flower Field Meadow', desc: 'Wild Chamomile & Swift Duels', isLocked: false),
      _JourneyStop(name: 'Frostfall Shrine', desc: 'Glacial Rime (Lv. 10)', isLocked: true),
      _JourneyStop(name: "Dragon's Spire", desc: 'Peak Tempest (Lv. 20)', isLocked: true),
    ];

    return _buildSectionContainer(
      title: 'JOURNEY CHRONICLE',
      subtitle: 'A long, tranquil expedition across peaceful realms and sealed elder sanctums',
      icon: Icons.timeline_rounded,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(stops.length, (index) {
            final stop = stops[index];
            final isLast = index == stops.length - 1;

            return Row(
              children: [
                Container(
                  width: 170,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: stop.isLocked
                        ? const Color(0xFFF0EBE1)
                        : AppTheme.parchmentBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: stop.isLocked
                          ? Colors.black26
                          : AppTheme.antiqueGold.withValues(alpha: 0.6),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            stop.isLocked ? Icons.lock_outline_rounded : Icons.place_rounded,
                            size: 16,
                            color: stop.isLocked ? AppTheme.softDamageRed : AppTheme.mossGreen,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'STOP ${index + 1}',
                            style: GoogleFonts.cinzel(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color: stop.isLocked ? AppTheme.softDamageRed : AppTheme.mossGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        stop.isLocked ? '???' : stop.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cinzel(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textOlive,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stop.desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 10.5,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textOliveMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 24,
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: AppTheme.antiqueGold.withValues(alpha: 0.5),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ==========================================
  // SECTION 6: EXPEDITION FEATURES GRID
  // ==========================================
  Widget _buildFeaturesSection(bool isDesktop) {
    final features = [
      _FeatureItem(
        icon: Icons.shield_moon_outlined,
        title: '3 WEAPON ARTIFACTS',
        description: 'Sword (Verdant Slash), Bow (Starlight Arrow), and Bomb (Rune Detonation) with tailored stats.',
      ),
      _FeatureItem(
        icon: Icons.map_rounded,
        title: '7 EXPEDITION MAPS',
        description: '5 playable glades and ruins, plus 2 sealed elder shrines with procedural miniature previews.',
      ),
      _FeatureItem(
        icon: Icons.face_rounded,
        title: 'AVATAR PICKER',
        description: '8 randomized traveler presets with top-down previews, elven & mage robes, and shuffle controls.',
      ),
      _FeatureItem(
        icon: Icons.psychology_rounded,
        title: 'BOT TRIAL DIFFICULTY',
        description: 'Practice spellcraft against Easy, Normal, or Hard companion AI bots with dynamic dodging.',
      ),
      _FeatureItem(
        icon: Icons.tune_rounded,
        title: 'PERSISTED AUDIO & CONTROLS',
        description: 'Fine-tune master volume, ambient melodies, compass scale, opacity, and stride sensitivity.',
      ),
    ];

    return _buildSectionContainer(
      title: 'EXPEDITION FEATURES',
      subtitle: 'Complete list of modules and features powering your cozy fantasy expedition',
      icon: Icons.star_rounded,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = isDesktop ? 3 : (constraints.maxWidth > 580 ? 2 : 1);
          if (columns == 3) {
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: features.map((f) {
                return SizedBox(
                  width: (constraints.maxWidth - 28) / 3,
                  child: _buildFeatureCard(f),
                );
              }).toList(),
            );
          } else if (columns == 2) {
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: features.map((f) {
                return SizedBox(
                  width: (constraints.maxWidth - 12) / 2,
                  child: _buildFeatureCard(f),
                );
              }).toList(),
            );
          }
          return Column(
            children: features
                .map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: _buildFeatureCard(f),
                    ))
                .toList(),
          );
        },
      ),
    );
  }

  Widget _buildFeatureCard(_FeatureItem item) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppTheme.parchmentBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.antiqueGold.withValues(alpha: 0.45), width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.mossGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, size: 20, color: AppTheme.mossGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.cinzel(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textOlive,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.description,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textOliveMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SHARED SECTION WRAPPER
  // ==========================================
  Widget _buildSectionContainer({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppTheme.parchmentCard.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.antiqueGold, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppTheme.antiqueGold.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.mossGreen, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: GoogleFonts.cinzel(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.8,
                      color: AppTheme.mossGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textOliveMuted,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppTheme.antiqueGoldLight),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

// ==========================================
// DATA MODELS
// ==========================================
class _PlayStep {
  final IconData icon;
  final String title;
  final String description;
  final String shortcut;

  const _PlayStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.shortcut,
  });
}

class _WeaponCardInfo {
  final WeaponType type;
  final String name;
  final String role;
  final String description;
  final double damage;
  final double speed;
  final String rangeLabel;
  final String cooldown;
  final String bonusHealth;
  final IconData icon;

  const _WeaponCardInfo({
    required this.type,
    required this.name,
    required this.role,
    required this.description,
    required this.damage,
    required this.speed,
    required this.rangeLabel,
    required this.cooldown,
    required this.bonusHealth,
    required this.icon,
  });
}

class _JourneyStop {
  final String name;
  final String desc;
  final bool isLocked;

  const _JourneyStop({
    required this.name,
    required this.desc,
    required this.isLocked,
  });
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

// ==========================================
// FOOTER & HEADER WIDGETS
// ==========================================
class _PageFooter extends StatelessWidget {
  const _PageFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.parchmentCard.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.antiqueGold.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(
            '“A journey of a thousand leagues is measured not in the distance walked, but in the peaceful moments shared beneath the forest canopy.”',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              color: AppTheme.textOlive,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppTheme.antiqueGoldLight),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sports_esports_outlined, size: 16, color: AppTheme.mossGreen),
                    const SizedBox(width: 8),
                    Text(
                      'JOYSTICK & KEYBOARD [WASD] • CAST [SPACEBAR]',
                      style: GoogleFonts.cinzel(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppTheme.textOliveMuted,
                      ),
                    ),
                  ],
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'M-WORLD • MYTHRIL WORLD — BRAWL ARENA v0.4.0',
                  style: GoogleFonts.cinzel(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: AppTheme.antiqueGold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StorybookFooter extends StatelessWidget {
  const _StorybookFooter();

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.mossGreen,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.softMagic,
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'FOREST CLEARING READY',
                style: GoogleFonts.cinzel(
                  color: AppTheme.textOliveMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Text(
            'TALE v0.4.0',
            style: GoogleFonts.cinzel(
              color: AppTheme.antiqueGold,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _GrimoireTitleHeader extends StatelessWidget {
  const _GrimoireTitleHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Decorative Gold Flora Ornament
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 32, height: 1, color: AppTheme.antiqueGold),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(
                Icons.spa_rounded,
                size: 16,
                color: AppTheme.antiqueGold,
              ),
            ),
            Container(width: 32, height: 1, color: AppTheme.antiqueGold),
          ],
        ),
        const SizedBox(height: 10),

        // Title Hierarchy: M-World (Main Title) -> Mythril World (Subtitle) -> Brawl Arena (Mode)
        Text(
          'M-WORLD',
          textAlign: TextAlign.center,
          style: GoogleFonts.cinzel(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: 4.0,
            color: AppTheme.textOlive,
            shadows: [
              Shadow(
                color: AppTheme.antiqueGold.withValues(alpha: 0.5),
                blurRadius: 14,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        Text(
          'MYTHRIL WORLD',
          textAlign: TextAlign.center,
          style: GoogleFonts.cinzel(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 3.2,
            color: AppTheme.antiqueGold,
          ),
        ),
        const SizedBox(height: 6),

        // Arena Mode
        Text(
          'BRAWL ARENA',
          textAlign: TextAlign.center,
          style: GoogleFonts.cinzel(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.2,
            color: AppTheme.mossGreen,
          ),
        ),
        const SizedBox(height: 4),

        // Subtitle Pill Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.parchmentBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.antiqueGold.withValues(alpha: 0.6),
              width: 1.0,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.mossGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'TRIAL OF THE ENCHANTED FOREST',
                  style: GoogleFonts.cinzel(
                    color: AppTheme.mossGreen,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),

        Text(
          'AN INDESTRUCTIBLE TRAINING CRUCIBLE FOR MAGES & WARRIORS',
          style: GoogleFonts.nunito(
            color: AppTheme.textOliveMuted,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}

/// Ambient background rendering warm sunbeams, drifting flower petals, and fireflies.
class _ForestClearingAmbientPainter extends CustomPainter {
  final double animationValue;

  static final Paint _petalPaint = Paint()..color = const Color(0xFFE8B4B8).withValues(alpha: 0.45);
  static final Paint _whitePetalPaint = Paint()..color = Colors.white.withValues(alpha: 0.65);
  static final Paint _fireflyPaint = Paint()..color = AppTheme.antiqueGoldLight.withValues(alpha: 0.7);
  static final Paint _fireflyGlow = Paint()..color = AppTheme.softMagic.withValues(alpha: 0.25);

  _ForestClearingAmbientPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Soft Pastoral Forest Backdrop
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFEFE7D3),
          Color(0xFFF7F1E3),
          Color(0xFFEDE3CB),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Soft Emerald Sunlight Canopy Glow at top
    final canopyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -1.0),
        radius: 1.2,
        colors: [
          AppTheme.mossGreen.withValues(alpha: 0.14),
          AppTheme.softMagic.withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), canopyPaint);

    // 3. Falling Petals (Lightweight 60 FPS particles with reused static paints)
    const int petalCount = 18;
    for (int i = 0; i < petalCount; i++) {
      final double seed = (i * 137.5) % 1.0;
      final double progress = (animationValue + seed) % 1.0;
      final double x = (seed * size.width) + math.sin(progress * math.pi * 3) * 28;
      final double y = progress * (size.height + 40) - 20;

      final double petalAngle = progress * math.pi * 2 + seed;
      final paint = i % 2 == 0 ? _petalPaint : _whitePetalPaint;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(petalAngle);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 8.0, height: 4.5),
        paint,
      );
      canvas.restore();
    }

    // 4. Glowing Fireflies (Warm golden / mana light orbs with reused static paints)
    const int fireflyCount = 12;
    for (int i = 0; i < fireflyCount; i++) {
      final double seed = (i * 93.3) % 1.0;
      final double progress = (animationValue * 0.7 + seed) % 1.0;
      final double x = (seed * size.width) + math.cos(progress * math.pi * 2) * 24;
      final double y = size.height - (progress * size.height);
      final double pulse = (math.sin((animationValue * 4 + i) * math.pi) + 1.0) / 2.0;

      canvas.drawCircle(Offset(x, y), 2.0 + pulse * 1.5, _fireflyPaint);
      canvas.drawCircle(Offset(x, y), 6.0 + pulse * 4.0, _fireflyGlow);
    }
  }

  @override
  bool shouldRepaint(covariant _ForestClearingAmbientPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

/// Custom painter for the soft pastoral landscape banner in the Hero section.
class _PastoralForestBannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Sky gradient
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE4ECDE), Color(0xFFF3ECE0)],
      ).createShader(rect);
    canvas.drawRect(rect, skyPaint);

    // Distant mountain silhouettes
    final mountainPaint = Paint()..color = const Color(0xFFCAD8C4);
    final mountainPath = Path()
      ..moveTo(0, size.height * 0.7)
      ..lineTo(size.width * 0.25, size.height * 0.45)
      ..lineTo(size.width * 0.5, size.height * 0.65)
      ..lineTo(size.width * 0.75, size.height * 0.4)
      ..lineTo(size.width, size.height * 0.6)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(mountainPath, mountainPaint);

    // Rolling green hill
    final hillPaint = Paint()..color = const Color(0xFF8BAA85);
    final hillPath = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.6, size.width, size.height * 0.8)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hillPath, hillPaint);

    // Foreground meadow hill
    final meadowPaint = Paint()..color = AppTheme.mossGreen;
    final meadowPath = Path()
      ..moveTo(0, size.height * 0.88)
      ..quadraticBezierTo(size.width * 0.6, size.height * 0.75, size.width, size.height * 0.85)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(meadowPath, meadowPaint);

    // Ancient stone ruin pillar on the right
    final stonePaint = Paint()..color = const Color(0xFF485848);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.82, size.height * 0.5, 14, size.height * 0.4),
        const Radius.circular(2),
      ),
      stonePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.8, size.height * 0.47, 18, 5),
        const Radius.circular(2),
      ),
      Paint()..color = AppTheme.antiqueGold,
    );

    // Elder tree silhouette on the left
    final trunkPaint = Paint()..color = const Color(0xFF382A1C);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.12, size.height * 0.55, 10, size.height * 0.35), trunkPaint);
    final foliagePaint = Paint()..color = const Color(0xFF426544);
    canvas.drawCircle(Offset(size.width * 0.12 + 5, size.height * 0.5), 24, foliagePaint);
    canvas.drawCircle(Offset(size.width * 0.12 - 6, size.height * 0.52), 16, foliagePaint);
    canvas.drawCircle(Offset(size.width * 0.12 + 16, size.height * 0.52), 16, foliagePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
