import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/avatar_model.dart';

/// Top-down preview painter for an avatar card matching the in-game animation rig.
class AvatarPreviewPainter extends CustomPainter {
  final AvatarModel avatar;
  final double size;

  AvatarPreviewPainter({required this.avatar, this.size = 64.0});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);

    canvas.save();
    canvas.translate(center.dx, center.dy);

    // 1. FEET: Two leather boots
    final bootPaint = Paint()..color = const Color(0xFF35261A);
    final leftFootRect = Rect.fromCenter(center: const Offset(-8, 12), width: 8, height: 11);
    final rightFootRect = Rect.fromCenter(center: const Offset(8, 12), width: 8, height: 11);
    canvas.drawRRect(RRect.fromRectAndRadius(leftFootRect, const Radius.circular(2)), bootPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(rightFootRect, const Radius.circular(2)), bootPaint);

    // 2. CLOAK (if present)
    if (avatar.hasCloak) {
      final cloakPaint = Paint()..color = avatar.robeColor.withValues(alpha: 0.85);
      final cloakRect = Rect.fromCenter(center: const Offset(0, 6), width: 34, height: 16);
      canvas.drawRRect(RRect.fromRectAndRadius(cloakRect, const Radius.circular(4)), cloakPaint);
    }

    // 3. TORSO / ROBE: Broad rectangular block
    final torsoRect = Rect.fromCenter(center: const Offset(0, 2), width: 30, height: 20);
    final robePaint = Paint()..color = avatar.robeColor;
    canvas.drawRRect(RRect.fromRectAndRadius(torsoRect, const Radius.circular(4)), robePaint);

    // Gold / silver robe trim
    final trimPaint = Paint()
      ..color = avatar.trimColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawRRect(RRect.fromRectAndRadius(torsoRect, const Radius.circular(4)), trimPaint);

    // Collar detail
    final collarPaint = Paint()
      ..color = avatar.trimColor.withValues(alpha: 0.7)
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(-5, -7), const Offset(0, -2), collarPaint);
    canvas.drawLine(const Offset(5, -7), const Offset(0, -2), collarPaint);

    // 4. HANDS
    final skinPaint = Paint()..color = const Color(0xFFFED7AA);
    final handBorder = Paint()
      ..color = const Color(0xFF8B5E3C).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Left hand
    final leftHandRect = Rect.fromCenter(center: const Offset(-17, 2), width: 8, height: 8);
    canvas.drawRRect(RRect.fromRectAndRadius(leftHandRect, const Radius.circular(2)), skinPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(leftHandRect, const Radius.circular(2)), handBorder);

    // Right hand
    final rightHandRect = Rect.fromCenter(center: const Offset(17, 2), width: 8, height: 8);
    canvas.drawRRect(RRect.fromRectAndRadius(rightHandRect, const Radius.circular(2)), skinPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(rightHandRect, const Radius.circular(2)), handBorder);

    // Staff in right hand
    _drawStaff(canvas, avatar.staffType, const Offset(17, 2));

    // 5. HEAD & HAIR
    final headPaint = Paint()..color = const Color(0xFFFED7AA);
    canvas.drawCircle(Offset.zero, 8.5, headPaint);

    // Pointed elf ears
    final earPaint = Paint()..color = const Color(0xFFFDCFA0);
    canvas.drawCircle(const Offset(-9, -2), 2.2, earPaint);
    canvas.drawCircle(const Offset(9, -2), 2.2, earPaint);

    // Hair / Cowl
    final hairPaint = Paint()..color = avatar.hairColor;
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: 8.5),
      math.pi * 0.9,
      math.pi * 1.2,
      false,
      hairPaint,
    );

    // Headpiece / Circlet
    if (avatar.headpiece == 'circlet') {
      final circletPaint = Paint()
        ..color = const Color(0xFFC9A86A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: 8.5),
        math.pi * 0.1,
        math.pi * 0.8,
        false,
        circletPaint,
      );
    }

    canvas.restore();
  }

  void _drawStaff(Canvas canvas, String staffType, Offset handPos) {
    final shaftPaint = Paint()
      ..color = const Color(0xFF784F2E)
      ..strokeWidth = 2.0;

    // Staff shaft
    canvas.drawLine(
      Offset(handPos.dx, handPos.dy + 8),
      Offset(handPos.dx, handPos.dy - 18),
      shaftPaint,
    );

    // Staff Headpiece
    if (staffType == 'crystalStaff') {
      final crystalPaint = Paint()..color = const Color(0xFF8FBFB5);
      canvas.drawCircle(Offset(handPos.dx, handPos.dy - 20), 4.0, crystalPaint);
    } else if (staffType == 'flowerStaff') {
      final flowerPaint = Paint()..color = const Color(0xFFD49A9F);
      canvas.drawCircle(Offset(handPos.dx, handPos.dy - 20), 3.5, flowerPaint);
    } else {
      // Wooden crook staff
      final crookPaint = Paint()
        ..color = const Color(0xFF5C3B20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(handPos.dx - 2, handPos.dy - 20), radius: 4),
        0,
        math.pi * 1.5,
        false,
        crookPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AvatarPreviewPainter oldDelegate) =>
      oldDelegate.avatar.id != avatar.id;
}
