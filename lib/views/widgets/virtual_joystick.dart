import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Touch / drag virtual analog joystick styled with antique gold and moss green fantasy motifs.
/// Supports dynamic scaling, opacity, and sensitivity based on persisted settings.
class VirtualJoystick extends StatefulWidget {
  final ValueChanged<Offset> onDirectionChanged;
  final double radius;
  final double knobRadius;
  final double opacity;
  final double sensitivity;

  const VirtualJoystick({
    super.key,
    required this.onDirectionChanged,
    this.radius = 65.0,
    this.knobRadius = 26.0,
    this.opacity = 0.85,
    this.sensitivity = 1.0,
  });

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  Offset _knobPosition = Offset.zero;

  void _updateKnobPosition(Offset localOffset) {
    final center = Offset(widget.radius, widget.radius);
    final delta = localOffset - center;
    final distance = delta.distance;

    final maxDistance = widget.radius - widget.knobRadius;

    if (distance <= maxDistance) {
      _knobPosition = delta;
    } else {
      final angle = math.atan2(delta.dy, delta.dx);
      _knobPosition = Offset(
        math.cos(angle) * maxDistance,
        math.sin(angle) * maxDistance,
      );
    }

    final rawX = _knobPosition.dx / maxDistance;
    final rawY = _knobPosition.dy / maxDistance;
    final sensitiveX = (rawX * widget.sensitivity).clamp(-1.0, 1.0);
    final sensitiveY = (rawY * widget.sensitivity).clamp(-1.0, 1.0);

    widget.onDirectionChanged(Offset(sensitiveX, sensitiveY));
    setState(() {});
  }

  void _resetKnob() {
    setState(() {
      _knobPosition = Offset.zero;
    });
    widget.onDirectionChanged(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.radius * 2;

    return Opacity(
      opacity: widget.opacity.clamp(0.2, 1.0),
      child: GestureDetector(
        onPanStart: (details) => _updateKnobPosition(details.localPosition),
        onPanUpdate: (details) => _updateKnobPosition(details.localPosition),
        onPanEnd: (_) => _resetKnob(),
        onPanCancel: () => _resetKnob(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.forestSurface.withValues(alpha: 0.85),
            border: Border.all(
              color: AppTheme.antiqueGold.withValues(alpha: 0.65),
              width: 2.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Inner compass rune indicator
              Icon(
                Icons.explore_outlined,
                color: AppTheme.antiqueGold.withValues(alpha: 0.28),
                size: widget.radius * 0.55,
              ),

              // Draggable Knob (Carved Rune Stone / Mana Core)
              Transform.translate(
                offset: _knobPosition,
                child: Container(
                  width: widget.knobRadius * 2,
                  height: widget.knobRadius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        AppTheme.antiqueGoldLight,
                        AppTheme.mossGreen,
                        AppTheme.mossGreenDark,
                      ],
                    ),
                    border: Border.all(
                      color: AppTheme.antiqueGold,
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.softMagic.withValues(alpha: 0.5),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    size: widget.knobRadius * 0.6,
                    color: AppTheme.parchmentBackground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
