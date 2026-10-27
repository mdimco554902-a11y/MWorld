import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

/// Cozy High Fantasy button with moss green primary fill, parchment secondary,
/// antique gold borders, and smooth tactile scaling animations.
class GameButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isSelected;
  final bool isDanger;
  final double height;
  final double? width;

  const GameButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isPrimary = false,
    this.isSelected = false,
    this.isDanger = false,
    this.height = 54.0,
    this.width,
  });

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Tactile scale feedback: scales down slightly on press (0.96), lifts on hover (1.02)
    final double scale = _isPressed
        ? 0.96
        : (_isHovered
            ? 1.02
            : 1.0);

    // Color tokens based on fantasy theme
    final Color buttonTextColor;
    final Gradient buttonGradient;
    final Border buttonBorder;
    final List<BoxShadow> buttonShadows;

    if (widget.isDanger) {
      buttonTextColor = Colors.white;
      buttonGradient = const LinearGradient(
        colors: [Color(0xFFD46560), AppTheme.softDamageRed],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
      buttonBorder = Border.all(color: const Color(0xFFE58884), width: 1.2);
      buttonShadows = [
        BoxShadow(
          color: AppTheme.softDamageRed.withValues(alpha: _isHovered ? 0.4 : 0.2),
          blurRadius: _isHovered ? 14 : 8,
          offset: const Offset(0, 2),
        ),
      ];
    } else if (widget.isPrimary) {
      // Play / Primary Action: Moss green with warm antique gold border
      buttonTextColor = AppTheme.parchmentBackground;
      buttonGradient = LinearGradient(
        colors: _isHovered
            ? [const Color(0xFF6B916B), AppTheme.mossGreen]
            : [AppTheme.mossGreen, AppTheme.mossGreenDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
      buttonBorder = Border.all(
        color: _isHovered ? AppTheme.antiqueGoldLight : AppTheme.antiqueGold,
        width: 1.4,
      );
      buttonShadows = [
        BoxShadow(
          color: AppTheme.mossGreen.withValues(alpha: _isHovered ? 0.45 : 0.25),
          blurRadius: _isHovered ? 16 : 8,
          offset: const Offset(0, 3),
        ),
        BoxShadow(
          color: AppTheme.antiqueGold.withValues(alpha: _isHovered ? 0.3 : 0.15),
          blurRadius: 6,
          offset: const Offset(0, 1),
        ),
      ];
    } else if (widget.isSelected) {
      // Selected Option: Moss-tinted parchment with gold border
      buttonTextColor = isDark ? AppTheme.textForestLight : AppTheme.textOlive;
      buttonGradient = LinearGradient(
        colors: isDark
            ? [const Color(0xFF3B5641), const Color(0xFF2E4534)]
            : [const Color(0xFFE8F0E4), const Color(0xFFDCE8D7)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
      buttonBorder = Border.all(color: AppTheme.antiqueGold, width: 1.8);
      buttonShadows = [
        BoxShadow(
          color: AppTheme.antiqueGold.withValues(alpha: 0.35),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];
    } else {
      // Secondary / Default: Warm ivory parchment on light, forest slate on dark
      buttonTextColor = isDark ? AppTheme.textForestLight : AppTheme.textOlive;
      buttonGradient = LinearGradient(
        colors: isDark
            ? (_isHovered
                ? [const Color(0xFF38503C), const Color(0xFF2C4030)]
                : [AppTheme.forestSurface, const Color(0xFF223426)])
            : (_isHovered
                ? [const Color(0xFFFFFDF5), const Color(0xFFF9F1DC)]
                : [AppTheme.parchmentCard, const Color(0xFFF7EED8)]),
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
      buttonBorder = Border.all(
        color: _isHovered ? AppTheme.antiqueGold : AppTheme.antiqueGold.withValues(alpha: 0.65),
        width: 1.2,
      );
      buttonShadows = [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
          blurRadius: _isHovered ? 8 : 4,
          offset: const Offset(0, 2),
        ),
      ];
    }

    return MouseRegion(
      cursor: widget.onPressed != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: GestureDetector(
        onTapDown: widget.onPressed != null ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: widget.onPressed != null
            ? (_) {
                setState(() => _isPressed = false);
                widget.onPressed?.call();
              }
            : null,
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: widget.height.clamp(48.0, 100.0),
            width: widget.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: buttonGradient,
              border: buttonBorder,
              boxShadow: buttonShadows,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: widget.isPrimary ? 22 : 18,
                          color: widget.isPrimary ? AppTheme.antiqueGoldLight : buttonTextColor,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        maxLines: 1,
                        style: GoogleFonts.cinzel(
                          fontSize: widget.isPrimary ? 16 : 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: widget.isPrimary ? 2.5 : 1.8,
                          color: buttonTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
