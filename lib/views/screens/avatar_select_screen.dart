import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/app_state_controller.dart';
import '../../core/theme.dart';
import '../../models/avatar_model.dart';
import '../../utils/responsive.dart';
import '../../utils/smooth_page_route.dart';
import '../widgets/avatar_preview_painter.dart';
import '../widgets/game_button.dart';
import 'map_select_screen.dart';

/// Avatar Selection screen providing 8 randomized fantasy presets, top-down previews,
/// class labels, shuffle/randomize actions, and nickname customization.
class AvatarSelectScreen extends StatefulWidget {
  const AvatarSelectScreen({super.key});

  @override
  State<AvatarSelectScreen> createState() => _AvatarSelectScreenState();
}

class _AvatarSelectScreenState extends State<AvatarSelectScreen> {
  late List<AvatarModel> _avatars;
  late AvatarModel _selectedAvatar;
  late final TextEditingController _nicknameController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppStateController>(context, listen: false);
    _avatars = AvatarModel.generatePresets();
    _selectedAvatar = appState.selectedAvatar;

    // Ensure selected avatar is among current presets or prepend it
    if (!_avatars.any((a) => a.id == _selectedAvatar.id)) {
      _avatars[0] = _selectedAvatar;
    }

    _nicknameController = TextEditingController(text: appState.nickname);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _shuffleAllAvatars() {
    setState(() {
      _avatars = AvatarModel.generatePresets();
      _selectedAvatar = _avatars.first;
      _nicknameController.text = _selectedAvatar.name;
    });

    final appState = Provider.of<AppStateController>(context, listen: false);
    appState.setAvatar(_selectedAvatar, updateNickname: true);
  }

  void _randomPick() {
    final random = math.Random();
    final chosen = _avatars[random.nextInt(_avatars.length)];
    setState(() {
      _selectedAvatar = chosen;
      _nicknameController.text = chosen.name;
    });

    final appState = Provider.of<AppStateController>(context, listen: false);
    appState.setAvatar(chosen, updateNickname: true);
  }

  void _selectAvatar(AvatarModel avatar) {
    setState(() {
      _selectedAvatar = avatar;
      _nicknameController.text = avatar.name;
    });

    final appState = Provider.of<AppStateController>(context, listen: false);
    appState.setAvatar(avatar, updateNickname: true);
  }

  void _handleContinue() {
    final appState = Provider.of<AppStateController>(context, listen: false);
    final text = _nicknameController.text.trim();
    if (text.isNotEmpty) {
      appState.setNickname(text);
    }

    Navigator.push(
      context,
      SmoothPageRoute(page: const MapSelectScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.getGridColumns(context, mobile: 2, tablet: 3, desktop: 4);

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
          'SELECT TRAVELER',
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Nickname Customization Card
                  _buildNicknameCard(),
                  const SizedBox(height: 16),

                  // Quick Action Buttons: Shuffle All / Random Pick
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _shuffleAllAvatars,
                          icon: const Icon(Icons.shuffle_rounded, size: 18, color: AppTheme.mossGreen),
                          label: Text(
                            'SHUFFLE ALL',
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
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _randomPick,
                          icon: const Icon(Icons.casino_outlined, size: 18, color: AppTheme.antiqueGold),
                          label: Text(
                            'RANDOM PICK',
                            style: GoogleFonts.cinzel(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AppTheme.textOlive,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.antiqueGold, width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: AppTheme.parchmentCard,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 8 Avatar Slots Responsive Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _avatars.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: columns <= 2 ? 0.82 : 0.88,
                    ),
                    itemBuilder: (context, index) {
                      final avatar = _avatars[index];
                      final isSelected = avatar.id == _selectedAvatar.id;
                      return _buildAvatarCard(avatar, isSelected);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Primary Continue Button
                  GameButton(
                    label: 'CHOOSE REALM MAP',
                    icon: Icons.map_outlined,
                    isPrimary: true,
                    height: 54,
                    onPressed: _handleContinue,
                  ),
                  const SizedBox(height: 10),

                  // Back Button
                  GameButton(
                    label: 'RETURN TO CLEARING',
                    icon: Icons.arrow_back_rounded,
                    isPrimary: false,
                    height: 48,
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

  Widget _buildNicknameCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.parchmentCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.antiqueGold.withValues(alpha: 0.65), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.antiqueGold.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_edu_rounded, size: 18, color: AppTheme.mossGreen),
              const SizedBox(width: 8),
              Text(
                'TRAVELER CALLSIGN & CLASS',
                style: GoogleFonts.cinzel(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: AppTheme.mossGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _nicknameController,
            focusNode: _focusNode,
            maxLength: 24,
            style: GoogleFonts.nunito(
              color: AppTheme.textOlive,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            cursorColor: AppTheme.mossGreen,
            decoration: InputDecoration(
              counterText: '',
              hintText: 'Enter your custom companion callsign...',
              prefixIcon: const Icon(Icons.edit_rounded, color: AppTheme.antiqueGold, size: 20),
              suffixText: _selectedAvatar.className,
              suffixStyle: GoogleFonts.cinzel(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.mossGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarCard(AvatarModel avatar, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectAvatar(avatar),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEBF1E8) : AppTheme.parchmentCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppTheme.mossGreen : AppTheme.antiqueGold.withValues(alpha: 0.5),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.mossGreen.withValues(alpha: 0.25)
                  : AppTheme.antiqueGold.withValues(alpha: 0.08),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top-down avatar preview in matching animation rig
            SizedBox(
              width: 58,
              height: 58,
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: AvatarPreviewPainter(avatar: avatar),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Name
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                avatar.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppTheme.mossGreenDark : AppTheme.textOlive,
                ),
              ),
            ),
            const SizedBox(height: 2),

            // Class Label
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                avatar.className,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textOliveMuted,
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Selection indicator badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.mossGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isSelected ? 'SELECTED' : 'TAP TO CHOOSE',
                style: GoogleFonts.cinzel(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : AppTheme.antiqueGold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
