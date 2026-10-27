import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/app_state_controller.dart';
import '../../core/theme.dart';
import '../../models/map_model.dart';
import '../../utils/responsive.dart';
import '../../utils/smooth_page_route.dart';
import '../widgets/game_button.dart';
import 'match_setup_screen.dart';

/// Map Selection screen presenting 5 unlocked exploration realms and 2 sealed blurred maps.
class MapSelectScreen extends StatefulWidget {
  const MapSelectScreen({super.key});

  @override
  State<MapSelectScreen> createState() => _MapSelectScreenState();
}

class _MapSelectScreenState extends State<MapSelectScreen> {
  late MapModel _selectedMap;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppStateController>(context, listen: false);
    _selectedMap = appState.selectedMap;
  }

  void _selectMap(MapModel map) {
    if (map.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            map.lockedHint ?? 'This place is still sealed by elder runes...',
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
      return;
    }

    setState(() {
      _selectedMap = map;
    });

    final appState = Provider.of<AppStateController>(context, listen: false);
    appState.setMap(map);
  }

  void _handleContinue() {
    Navigator.push(
      context,
      SmoothPageRoute(page: const MatchSetupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.getGridColumns(context, mobile: 2, tablet: 3, desktop: 4);
    final maps = MapModel.allMaps;

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
          'SELECT REALM MAP',
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
                  // Map Selection Info Banner
                  _buildHeaderBanner(),
                  const SizedBox(height: 18),

                  // 7 Maps Responsive Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: maps.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: columns <= 2 ? 0.74 : 0.80,
                    ),
                    itemBuilder: (context, index) {
                      final map = maps[index];
                      final isSelected = !map.isLocked && map.id == _selectedMap.id;
                      return _buildMapCard(map, isSelected);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Primary Continue Button
                  GameButton(
                    label: 'CHOOSE WEAPON ARTIFACT',
                    icon: Icons.shield_moon_outlined,
                    isPrimary: true,
                    height: 54,
                    onPressed: _handleContinue,
                  ),
                  const SizedBox(height: 10),

                  // Back Button
                  GameButton(
                    label: 'BACK TO TRAVELERS',
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

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.parchmentCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.antiqueGold.withValues(alpha: 0.65), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.antiqueGold.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.explore_outlined, color: AppTheme.mossGreen, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT REALM: ${_selectedMap.name.toUpperCase()}',
                  style: GoogleFonts.cinzel(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.mossGreen,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _selectedMap.description,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
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

  Widget _buildMapCard(MapModel map, bool isSelected) {
    if (map.isLocked) {
      return _buildLockedMapCard(map);
    }

    return GestureDetector(
      onTap: () => _selectMap(map),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Procedural Map Preview Card
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomPaint(
                  painter: _MapThumbnailPainter(map: map),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Map Name
            Text(
              map.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cinzel(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppTheme.mossGreenDark : AppTheme.textOlive,
              ),
            ),
            const SizedBox(height: 2),

            // Cover Tag Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.mossGreen.withValues(alpha: 0.15)
                    : AppTheme.antiqueGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                map.coverTag,
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppTheme.mossGreen : AppTheme.textOliveMuted,
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Select Indicator
            Container(
              padding: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.mossGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isSelected ? 'SELECTED' : 'EXPLORE',
                textAlign: TextAlign.center,
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

  /// Sealed / Locked map card with ImageFiltered blur and lock overlay.
  Widget _buildLockedMapCard(MapModel map) {
    return GestureDetector(
      onTap: () => _selectMap(map),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3ECE0),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.black26,
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Blurred preview using ImageFiltered with GPU raster caching
                    RepaintBoundary(
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: CustomPaint(
                          painter: _MapThumbnailPainter(map: map, isGrayscale: true),
                        ),
                      ),
                    ),
                    // Dark lock overlay
                    Container(
                      color: Colors.black.withValues(alpha: 0.45),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_rounded, color: AppTheme.antiqueGoldLight, size: 28),
                          SizedBox(height: 4),
                          Text(
                            'SEALED',
                            style: TextStyle(
                              color: AppTheme.parchmentBackground,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            Text(
              map.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cinzel(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textOliveMuted,
              ),
            ),
            const SizedBox(height: 2),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.antiqueGold.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppTheme.antiqueGold.withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              child: Text(
                map.coverTag,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textOlive,
                ),
              ),
            ),
            const SizedBox(height: 6),

            Text(
              'LOCKED • TAP FOR HINT',
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: AppTheme.textOliveMuted,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter generating a scenic miniature preview for each map using shapes & colors.
class _MapThumbnailPainter extends CustomPainter {
  final MapModel map;
  final bool isGrayscale;

  _MapThumbnailPainter({required this.map, this.isGrayscale = false});

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = isGrayscale ? const Color(0xFF333333) : map.groundBaseColor;
    final pathColor = isGrayscale ? const Color(0xFF4A4A4A) : map.pathColor;
    final ringColor = isGrayscale ? const Color(0xFF606060) : map.ringColor;
    final runeColor = isGrayscale ? Colors.white30 : map.runeColor;

    // Background base
    final bgPaint = Paint()..color = baseColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Diagonal soil / river / clearing path
    final pathPaint = Paint()..color = pathColor;
    final path = Path()
      ..moveTo(0, size.height * 0.3)
      ..lineTo(size.width, size.height * 0.6)
      ..lineTo(size.width, size.height * 0.9)
      ..lineTo(0, size.height * 0.6)
      ..close();
    canvas.drawPath(path, pathPaint);

    // Central circular glade or shrine
    final ringPaint = Paint()..color = ringColor;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width * 0.22, ringPaint);

    // Rune ring
    final runePaint = Paint()
      ..color = runeColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width * 0.16, runePaint);

    // Decorative obstacle silhouettes
    final obsPaint = Paint()..color = map.obstaclePrimaryColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.width * 0.28, size.height * 0.3), width: 18, height: 10),
        const Radius.circular(3),
      ),
      obsPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.width * 0.72, size.height * 0.7), width: 14, height: 14),
        const Radius.circular(3),
      ),
      obsPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MapThumbnailPainter oldDelegate) =>
      oldDelegate.map.id != map.id || oldDelegate.isGrayscale != isGrayscale;
}
