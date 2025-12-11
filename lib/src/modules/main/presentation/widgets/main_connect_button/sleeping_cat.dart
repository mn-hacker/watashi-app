import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated sleeping anime-style cat widget
/// Features: breathing animation, tail wagging
class SleepingCat extends StatefulWidget {
  final double width;
  final double height;
  final Color catColor;
  final Color accentColor;

  const SleepingCat({
    super.key,
    this.width = 60,
    this.height = 40,
    this.catColor = const Color(0xFF2D2D2D), // Default black for light theme
    this.accentColor = const Color(0xFFFFB6C1), // Pink for inner ears/nose
  });

  @override
  State<SleepingCat> createState() => _SleepingCatState();
}

class _SleepingCatState extends State<SleepingCat>
    with TickerProviderStateMixin {
  // Breathing animation
  late final AnimationController _breathController;
  late final Animation<double> _breathAnimation;

  // Tail wagging animation
  late final AnimationController _tailController;
  late final Animation<double> _tailAnimation;

  // Ear twitch animation (occasional)
  late final AnimationController _earController;
  late final Animation<double> _earAnimation;

  @override
  void initState() {
    super.initState();
    _initBreathingAnimation();
    _initTailAnimation();
    _initEarAnimation();
  }

  void _initBreathingAnimation() {
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _breathAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOut,
      ),
    );

    _breathController.repeat(reverse: true);
  }

  void _initTailAnimation() {
    _tailController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _tailAnimation = Tween<double>(begin: -0.15, end: 0.25).animate(
      CurvedAnimation(
        parent: _tailController,
        curve: Curves.easeInOut,
      ),
    );

    _tailController.repeat(reverse: true);
  }

  void _initEarAnimation() {
    _earController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _earAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(
        parent: _earController,
        curve: Curves.easeInOut,
      ),
    );

    // Occasional ear twitch
    _startEarTwitchCycle();
  }

  void _startEarTwitchCycle() async {
    while (mounted) {
      await Future.delayed(
          Duration(milliseconds: 3000 + (math.Random().nextInt(4000))));
      if (mounted) {
        await _earController.forward();
        await _earController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    _tailController.dispose();
    _earController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation:
            Listenable.merge([_breathAnimation, _tailAnimation, _earAnimation]),
        builder: (context, child) {
          return CustomPaint(
            painter: _SleepingCatPainter(
              breathValue: _breathAnimation.value,
              tailValue: _tailAnimation.value,
              earValue: _earAnimation.value,
              catColor: widget.catColor,
              accentColor: widget.accentColor,
            ),
            size: Size(widget.width, widget.height),
          );
        },
      ),
    );
  }
}

class _SleepingCatPainter extends CustomPainter {
  final double breathValue;
  final double tailValue;
  final double earValue;
  final Color catColor;
  final Color accentColor;

  _SleepingCatPainter({
    required this.breathValue,
    required this.tailValue,
    required this.earValue,
    required this.catColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Base position
    final bodyY = h * 0.6 + (breathValue * 2);

    // Colors from parameters (theme-aware)
    final bodyColor = catColor;
    final bodyDarkColor = HSLColor.fromColor(catColor)
        .withLightness(
            (HSLColor.fromColor(catColor).lightness - 0.15).clamp(0.0, 1.0))
        .toColor();
    final innerEarColor = accentColor;
    final noseColor = accentColor;

    // === TAIL (behind body, wagging over the button) ===
    paint.color = bodyColor;
    final tailPath = Path();
    final tailStartX = w * 0.15;
    final tailStartY = bodyY + h * 0.1;
    final tailEndX = w * -0.3; // Extends to the left (over button)
    final tailEndY = bodyY - h * 0.2 + (tailValue * h * 0.4);

    tailPath.moveTo(tailStartX, tailStartY);
    tailPath.quadraticBezierTo(
      tailStartX - w * 0.15,
      tailStartY - h * 0.1 + (tailValue * h * 0.2),
      tailEndX,
      tailEndY,
    );
    tailPath.quadraticBezierTo(
      tailStartX - w * 0.15 - 3,
      tailStartY - h * 0.05 + (tailValue * h * 0.2),
      tailStartX,
      tailStartY + 4,
    );
    tailPath.close();
    canvas.drawPath(tailPath, paint);

    // === BODY (curled up sleeping position) ===
    paint.color = bodyColor;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.45, bodyY),
        width: w * 0.55,
        height: h * 0.45 + (breathValue * 3),
      ),
      const Radius.circular(20),
    );
    canvas.drawRRect(bodyRect, paint);

    // === HEAD ===
    paint.color = bodyColor;
    final headCenterX = w * 0.7;
    final headCenterY = bodyY - h * 0.05;
    canvas.drawCircle(
      Offset(headCenterX, headCenterY),
      w * 0.2,
      paint,
    );

    // === EARS ===
    // Left ear
    final leftEarPath = Path();
    leftEarPath.moveTo(headCenterX - w * 0.12, headCenterY - w * 0.12);
    leftEarPath.lineTo(
        headCenterX - w * 0.18 - (earValue * 5), headCenterY - w * 0.28);
    leftEarPath.lineTo(headCenterX - w * 0.05, headCenterY - w * 0.15);
    leftEarPath.close();
    canvas.drawPath(leftEarPath, paint);

    // Right ear
    final rightEarPath = Path();
    rightEarPath.moveTo(headCenterX + w * 0.12, headCenterY - w * 0.12);
    rightEarPath.lineTo(
        headCenterX + w * 0.18 + (earValue * 5), headCenterY - w * 0.28);
    rightEarPath.lineTo(headCenterX + w * 0.05, headCenterY - w * 0.15);
    rightEarPath.close();
    canvas.drawPath(rightEarPath, paint);

    // Inner ears (pink)
    paint.color = innerEarColor;
    final leftInnerEarPath = Path();
    leftInnerEarPath.moveTo(headCenterX - w * 0.11, headCenterY - w * 0.13);
    leftInnerEarPath.lineTo(
        headCenterX - w * 0.15 - (earValue * 3), headCenterY - w * 0.23);
    leftInnerEarPath.lineTo(headCenterX - w * 0.07, headCenterY - w * 0.14);
    leftInnerEarPath.close();
    canvas.drawPath(leftInnerEarPath, paint);

    final rightInnerEarPath = Path();
    rightInnerEarPath.moveTo(headCenterX + w * 0.11, headCenterY - w * 0.13);
    rightInnerEarPath.lineTo(
        headCenterX + w * 0.15 + (earValue * 3), headCenterY - w * 0.23);
    rightInnerEarPath.lineTo(headCenterX + w * 0.07, headCenterY - w * 0.14);
    rightInnerEarPath.close();
    canvas.drawPath(rightInnerEarPath, paint);

    // === CLOSED EYES (sleeping) ===
    paint.color = bodyDarkColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    paint.strokeCap = StrokeCap.round;

    // Left closed eye (curved line)
    final leftEyePath = Path();
    leftEyePath.moveTo(headCenterX - w * 0.1, headCenterY);
    leftEyePath.quadraticBezierTo(
      headCenterX - w * 0.07,
      headCenterY + 3,
      headCenterX - w * 0.04,
      headCenterY,
    );
    canvas.drawPath(leftEyePath, paint);

    // Right closed eye
    final rightEyePath = Path();
    rightEyePath.moveTo(headCenterX + w * 0.04, headCenterY);
    rightEyePath.quadraticBezierTo(
      headCenterX + w * 0.07,
      headCenterY + 3,
      headCenterX + w * 0.1,
      headCenterY,
    );
    canvas.drawPath(rightEyePath, paint);

    // === NOSE ===
    paint.style = PaintingStyle.fill;
    paint.color = noseColor;
    final nosePath = Path();
    nosePath.moveTo(headCenterX, headCenterY + w * 0.05);
    nosePath.lineTo(headCenterX - w * 0.025, headCenterY + w * 0.08);
    nosePath.lineTo(headCenterX + w * 0.025, headCenterY + w * 0.08);
    nosePath.close();
    canvas.drawPath(nosePath, paint);

    // === WHISKERS ===
    paint.color = bodyDarkColor.withOpacity(0.5);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;

    // Left whiskers
    canvas.drawLine(
      Offset(headCenterX - w * 0.08, headCenterY + w * 0.06),
      Offset(headCenterX - w * 0.2, headCenterY + w * 0.03),
      paint,
    );
    canvas.drawLine(
      Offset(headCenterX - w * 0.08, headCenterY + w * 0.08),
      Offset(headCenterX - w * 0.2, headCenterY + w * 0.09),
      paint,
    );

    // Right whiskers
    canvas.drawLine(
      Offset(headCenterX + w * 0.08, headCenterY + w * 0.06),
      Offset(headCenterX + w * 0.2, headCenterY + w * 0.03),
      paint,
    );
    canvas.drawLine(
      Offset(headCenterX + w * 0.08, headCenterY + w * 0.08),
      Offset(headCenterX + w * 0.2, headCenterY + w * 0.09),
      paint,
    );

    // === ZZZ (sleeping indicator) ===
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'z',
        style: TextStyle(
          color: bodyDarkColor.withOpacity(0.4 + (breathValue * 0.3)),
          fontSize: 10 + (breathValue * 2),
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
          headCenterX + w * 0.15, headCenterY - w * 0.25 - (breathValue * 3)),
    );

    // Second smaller z
    final textPainter2 = TextPainter(
      text: TextSpan(
        text: 'z',
        style: TextStyle(
          color: bodyDarkColor.withOpacity(0.3 + (breathValue * 0.2)),
          fontSize: 7 + (breathValue * 1.5),
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter2.layout();
    textPainter2.paint(
      canvas,
      Offset(
          headCenterX + w * 0.22, headCenterY - w * 0.35 - (breathValue * 5)),
    );
  }

  @override
  bool shouldRepaint(covariant _SleepingCatPainter oldDelegate) {
    return breathValue != oldDelegate.breathValue ||
        tailValue != oldDelegate.tailValue ||
        earValue != oldDelegate.earValue ||
        catColor != oldDelegate.catColor ||
        accentColor != oldDelegate.accentColor;
  }
}
