import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../widgets/game_button.dart';

/// About screen detailing the cozy fantasy expedition lore, weapon spellcraft, and trials.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          'CHRONICLES & SPELLCRAFT',
          style: GoogleFonts.cinzel(
            fontSize: 20,
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
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // M-World Lore Introduction Card
                  _buildGrimoireCard(
                    title: 'ABOUT M-WORLD (MYTHRIL WORLD)',
                    icon: Icons.shield_rounded,
                    body: 'Mythril World is an indestructible, high-altitude training crucible where mages and warriors can unleash catastrophic spells without wrecking the fragile mortal realm.\n\n'
                        'Brawl Arena — Trial of the Enchanted Forest is a friendly training trial inside Mythril World where mages and warriors train. Because the Mythril World cannot be destroyed and the mortal realm is not harmed, wanderers, elves, and companion bots can clash freely with slashing blades, piercing starlight arrows, and explosive runes in safety.',
                  ),
                  const SizedBox(height: 16),

                  // Story Introduction Card
                  _buildGrimoireCard(
                    title: 'A JOURNEY ACROSS ANCIENT CLEARINGS',
                    icon: Icons.auto_stories_rounded,
                    body: 'Long ago, wanderers gathered in the forgotten groves of the ancient realm '
                        'to hone their magic and practice spellcraft alongside companion mages and elves. '
                        'Here, battles are gentle rites of passage—friendly duels among comrades traveling '
                        'under the emerald canopy, where every strike is woven with centuries of quiet dedication.',
                  ),
                  const SizedBox(height: 16),

                  // Weapons Spellcraft Breakdown
                  _buildGrimoireCard(
                    title: 'ANCIENT WEAPONS & CATALYSTS',
                    icon: Icons.military_tech_rounded,
                    body: '',
                    customContent: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLoreRow(
                          icon: Icons.shield_moon_outlined,
                          title: 'Enchanted Sword (Agile Melee)',
                          desc: 'A swift, reforged silver blade favored by elven vanguards. Deals 48 dmg with nimble mobility and sweeping arc recovery.',
                        ),
                        const SizedBox(height: 12),
                        _buildLoreRow(
                          icon: Icons.explore_rounded,
                          title: 'Elven Bow (Precision Ranged)',
                          desc: 'Carved from elder boughs and strung with enchanted silken chord. Snipes across sunlit glades with 34 dmg piercing arrows.',
                        ),
                        const SizedBox(height: 12),
                        _buildLoreRow(
                          icon: Icons.circle_outlined,
                          title: 'Rune Orb (Tactical Demolition)',
                          desc: 'An ancient explosive sphere imbued with heavy warding glyphs. Bestows +30 HP bonus armor and unleashes an 75 dmg arcane blast.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // How to Venture Card
                  _buildGrimoireCard(
                    title: 'TRAIL ADVICE FOR TRAVELERS',
                    icon: Icons.wb_twilight_rounded,
                    body: '1. Stride: Use the Traveler\'s Compass (joystick) or [WASD] keys to wander.\n'
                        '2. Guidance: Your gaze and footsteps turn in harmony with your journey.\n'
                        '3. Spell Release: Tap [SPACEBAR] or the Attack glyph to release your weapon\'s mana.\n'
                        '4. Harmony: Complete the forest rite by overcoming all sparring companion bots in the clearing.',
                  ),
                  const SizedBox(height: 32),

                  // Back Button
                  GameButton(
                    label: 'RETURN TO CLEARING',
                    icon: Icons.arrow_back_rounded,
                    isPrimary: false,
                    height: 52,
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

  Widget _buildGrimoireCard({
    required String title,
    required IconData icon,
    required String body,
    Widget? customContent,
  }) {
    return Container(
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        color: AppTheme.parchmentCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.antiqueGold.withValues(alpha: 0.7),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.antiqueGold.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 3),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: AppTheme.mossGreen,
                  ),
                ),
              ),
            ],
          ),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              body,
              style: GoogleFonts.nunito(
                fontSize: 14,
                height: 1.6,
                color: AppTheme.textOlive,
              ),
            ),
          ],
          if (customContent != null) ...[
            const SizedBox(height: 12),
            customContent,
          ],
        ],
      ),
    );
  }

  Widget _buildLoreRow({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.mossGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.antiqueGold.withValues(alpha: 0.5)),
          ),
          child: Icon(icon, size: 16, color: AppTheme.mossGreen),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.cinzel(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textOlive,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: AppTheme.textOliveMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
