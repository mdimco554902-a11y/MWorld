import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/app_state_controller.dart';
import '../../controllers/game_controller.dart';
import '../../core/theme.dart';
import '../../models/player_model.dart';
import '../../utils/smooth_page_route.dart';
import '../widgets/game_button.dart';
import 'game_screen.dart';

/// Match Setup / Rite of Passage screen for selecting weapon artifact and bot trial difficulty.
class MatchSetupScreen extends StatefulWidget {
  const MatchSetupScreen({super.key});

  @override
  State<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends State<MatchSetupScreen> {
  late WeaponType _selectedWeapon;
  late BotDifficulty _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    final gameController = Provider.of<GameController>(context, listen: false);
    _selectedWeapon = gameController.selectedWeapon;
    _selectedDifficulty = gameController.botDifficulty;
  }

  void _handleStartMatch() {
    final appState = Provider.of<AppStateController>(context, listen: false);
    final gameController = Provider.of<GameController>(context, listen: false);

    gameController.setWeaponType(_selectedWeapon);
    gameController.setBotDifficulty(_selectedDifficulty);
    gameController.startMatch(
      playerNickname: appState.nickname,
      avatar: appState.selectedAvatar,
      map: appState.selectedMap,
    );

    Navigator.push(
      context,
      SmoothPageRoute(page: const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.parchmentBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.mossGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'MATCH LOBBY',
          style: GoogleFonts.cinzel(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.5,
            color: AppTheme.textOlive,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SECTION 1: WEAPON ARTIFACT
                  const _RuneSectionHeader(
                    title: '1. CHOOSE WEAPON ARTIFACT',
                    subtitle: 'Equip your traveler with an enchanted tool of magic',
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: GameButton(
                          label: 'SWORD',
                          icon: Icons.shield_moon_outlined,
                          isSelected: _selectedWeapon == WeaponType.sword,
                          height: 64,
                          onPressed: () {
                            setState(() => _selectedWeapon = WeaponType.sword);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GameButton(
                          label: 'BOW',
                          icon: Icons.explore_rounded,
                          isSelected: _selectedWeapon == WeaponType.bow,
                          height: 64,
                          onPressed: () {
                            setState(() => _selectedWeapon = WeaponType.bow);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GameButton(
                          label: 'BOMB',
                          icon: Icons.circle_outlined,
                          isSelected: _selectedWeapon == WeaponType.bomb,
                          height: 64,
                          onPressed: () {
                            setState(() => _selectedWeapon = WeaponType.bomb);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Selected Weapon info banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.parchmentCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.antiqueGold.withValues(alpha: 0.6)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _selectedWeapon.displayName.toUpperCase(),
                          style: GoogleFonts.cinzel(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: AppTheme.mossGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedWeapon.description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: AppTheme.textOliveMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // SECTION 2: TRIAL DIFFICULTY (RUNE STONES)
                  const _RuneSectionHeader(
                    title: '2. TRIAL DIFFICULTY (RUNE STONES)',
                    subtitle: 'Select the combat acumen of fellow forest mages',
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: GameButton(
                          label: 'EASY',
                          isSelected: _selectedDifficulty == BotDifficulty.easy,
                          height: 52,
                          onPressed: () {
                            setState(() => _selectedDifficulty = BotDifficulty.easy);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GameButton(
                          label: 'NORMAL',
                          isSelected: _selectedDifficulty == BotDifficulty.normal,
                          height: 52,
                          onPressed: () {
                            setState(() => _selectedDifficulty = BotDifficulty.normal);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GameButton(
                          label: 'HARD',
                          isSelected: _selectedDifficulty == BotDifficulty.hard,
                          height: 52,
                          onPressed: () {
                            setState(() => _selectedDifficulty = BotDifficulty.hard);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Selected Difficulty info banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.parchmentCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.antiqueGold.withValues(alpha: 0.6)),
                    ),
                    child: Text(
                      _selectedDifficulty.description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: AppTheme.textOlive,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 44),

                  // PRIMARY START MATCH ACTION
                  GameButton(
                    label: 'START MATCH',
                    icon: Icons.auto_awesome_rounded,
                    isPrimary: true,
                    height: 58,
                    onPressed: _handleStartMatch,
                  ),
                  const SizedBox(height: 14),

                  // BACK BUTTON
                  GameButton(
                    label: 'RETURN TO CLEARING',
                    icon: Icons.arrow_back_rounded,
                    isPrimary: false,
                    height: 50,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RuneSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _RuneSectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.cinzel(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
            color: AppTheme.mossGreen,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: AppTheme.textOliveMuted,
          ),
        ),
      ],
    );
  }
}
