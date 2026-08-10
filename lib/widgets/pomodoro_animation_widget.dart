import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/pomodoro_state.dart';

class PomodoroAnimationWidget extends StatefulWidget {
  final PomodoroTheme theme;
  final double progress;
  final bool isRunning;

  const PomodoroAnimationWidget({
    Key? key,
    required this.theme,
    required this.progress,
    required this.isRunning,
  }) : super(key: key);

  @override
  State<PomodoroAnimationWidget> createState() => _PomodoroAnimationWidgetState();
}

class _PomodoroAnimationWidgetState extends State<PomodoroAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    if (widget.isRunning) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(PomodoroAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning != oldWidget.isRunning) {
      if (widget.isRunning) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor.withOpacity(0.08),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(widget.isRunning ? 0.25 : 0.1),
                blurRadius: 30 + math.sin(_controller.value * math.pi * 2) * 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: CustomPaint(
            painter: _ThemePainter(
              theme: widget.theme,
              progress: widget.progress,
              animationValue: _controller.value,
              color: primaryColor,
              isRunning: widget.isRunning,
            ),
          ),
        );
      },
    );
  }
}

class _ThemePainter extends CustomPainter {
  final PomodoroTheme theme;
  final double progress;
  final double animationValue;
  final Color color;
  final bool isRunning;

  _ThemePainter({
    required this.theme,
    required this.progress,
    required this.animationValue,
    required this.color,
    required this.isRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    switch (theme) {
      case PomodoroTheme.tree:
        _paintTree(canvas, size, center);
        break;
      case PomodoroTheme.fire:
        _paintFire(canvas, size, center);
        break;
      case PomodoroTheme.space:
        _paintSpace(canvas, size, center);
        break;
      case PomodoroTheme.potion:
        _paintPotion(canvas, size, center);
        break;
      case PomodoroTheme.hourglass:
        _paintHourglass(canvas, size, center);
        break;
      case PomodoroTheme.ocean:
        _paintOcean(canvas, size, center);
        break;
      case PomodoroTheme.coffee:
        _paintCoffee(canvas, size, center);
        break;
      case PomodoroTheme.zen:
        _paintZen(canvas, size, center);
        break;
      case PomodoroTheme.battery:
        _paintBattery(canvas, size, center);
        break;
      case PomodoroTheme.crystal:
        _paintCrystal(canvas, size, center);
        break;
      case PomodoroTheme.vinyl:
        _paintVinyl(canvas, size, center);
        break;
      case PomodoroTheme.candle:
        _paintCandle(canvas, size, center);
        break;
      case PomodoroTheme.mountain:
        _paintMountain(canvas, size, center);
        break;
      case PomodoroTheme.balloon:
        _paintBalloon(canvas, size, center);
        break;
      case PomodoroTheme.ufo:
        _paintUfo(canvas, size, center);
        break;
      case PomodoroTheme.windmill:
        _paintWindmill(canvas, size, center);
        break;
    }
  }

  void _paintTree(Canvas canvas, Size size, Offset center) {
    // Soil ground
    final groundPaint = Paint()
      ..color = color.withOpacity(0.35)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 58), width: 130, height: 22),
      groundPaint,
    );

    // Little flowers on ground
    final flowerPaint = Paint()..color = Colors.pinkAccent;
    canvas.drawCircle(Offset(center.dx - 35, center.dy + 56), 3, flowerPaint);
    canvas.drawCircle(Offset(center.dx + 40, center.dy + 58), 2.5, flowerPaint);

    // Tree trunk grows with progress
    final trunkHeight = 35.0 + progress * 50;
    final trunkWidth = 12.0 + progress * 8;

    final trunkPath = Path()
      ..moveTo(center.dx - trunkWidth / 2, center.dy + 58)
      ..lineTo(center.dx + trunkWidth / 2, center.dy + 58)
      ..lineTo(center.dx + trunkWidth / 3, center.dy + 58 - trunkHeight)
      ..lineTo(center.dx - trunkWidth / 3, center.dy + 58 - trunkHeight)
      ..close();

    final trunkPaint = Paint()
      ..color = Color.lerp(Colors.brown.shade800, color.withOpacity(0.9), 0.4)!
      ..style = PaintingStyle.fill;
    canvas.drawPath(trunkPath, trunkPaint);

    // Foliage grows in stages
    final foliageRadius = 25.0 + progress * 38.0;
    final foliageCenter = Offset(center.dx, center.dy + 58 - trunkHeight - foliageRadius * 0.4);

    final foliagePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(foliageCenter, foliageRadius, foliagePaint);
    canvas.drawCircle(
      foliageCenter.translate(-foliageRadius * 0.5, foliageRadius * 0.2),
      foliageRadius * 0.72,
      Paint()..color = color.withOpacity(0.88),
    );
    canvas.drawCircle(
      foliageCenter.translate(foliageRadius * 0.5, foliageRadius * 0.2),
      foliageRadius * 0.72,
      Paint()..color = color.withOpacity(0.88),
    );

    // Apples / Fruits appear as progress grows
    if (progress > 0.25) {
      final fruitPaint = Paint()..color = Colors.redAccent;
      final fruitCount = (progress * 8).floor();
      final fruitOffsets = [
        Offset(-foliageRadius * 0.3, -foliageRadius * 0.2),
        Offset(foliageRadius * 0.4, -foliageRadius * 0.1),
        Offset(0, foliageRadius * 0.3),
        Offset(-foliageRadius * 0.5, foliageRadius * 0.2),
        Offset(foliageRadius * 0.5, foliageRadius * 0.25),
        Offset(-foliageRadius * 0.2, foliageRadius * 0.5),
        Offset(foliageRadius * 0.2, -foliageRadius * 0.4),
        Offset(0, -foliageRadius * 0.2),
      ];
      for (int i = 0; i < fruitCount && i < fruitOffsets.length; i++) {
        canvas.drawCircle(foliageCenter + fruitOffsets[i], 4, fruitPaint);
      }
    }

    // Fireflies / Floating leaves particles if running
    if (isRunning) {
      final fireflyPaint = Paint()..color = Colors.yellowAccent.withOpacity(0.85);
      for (int i = 0; i < 8; i++) {
        double offsetProgress = (animationValue + i * 0.125) % 1.0;
        double px = center.dx + math.sin(offsetProgress * math.pi * 2 + i) * (35 + i * 4);
        double py = (center.dy - 20) + math.cos(offsetProgress * math.pi * 3) * 40;

        canvas.drawCircle(Offset(px, py), 2.0, fireflyPaint);
      }
    }
  }

  void _paintFire(Canvas canvas, Size size, Offset center) {
    // Warm fire glow
    final glowPaint = Paint()
      ..color = Colors.orangeAccent.withOpacity(0.2 + math.sin(animationValue * math.pi * 2) * 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    canvas.drawCircle(center, 75, glowPaint);

    // Logs at bottom
    final logPaint = Paint()
      ..color = Colors.brown.shade800
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx - 45, center.dy + 50),
      Offset(center.dx + 45, center.dy + 35),
      logPaint,
    );
    canvas.drawLine(
      Offset(center.dx - 45, center.dy + 35),
      Offset(center.dx + 45, center.dy + 50),
      logPaint,
    );

    // Glowing red embers on logs
    final emberPaint = Paint()
      ..color = Colors.redAccent
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(center.dx, center.dy + 42), 10, emberPaint);

    // Flames grow with progress
    final scaleFactor = 0.5 + progress * 0.85;
    final flameHeight = 90.0 * scaleFactor;
    final flameWidth = 70.0 * scaleFactor;

    // 1. Outer Flame (Orange)
    final outerPath = Path();
    final wave = math.sin(animationValue * math.pi * 4) * 8;

    outerPath.moveTo(center.dx - flameWidth / 2, center.dy + 40);
    outerPath.quadraticBezierTo(
      center.dx - flameWidth / 2 - wave,
      center.dy + 40 - flameHeight * 0.5,
      center.dx + wave,
      center.dy + 40 - flameHeight,
    );
    outerPath.quadraticBezierTo(
      center.dx + flameWidth / 2 + wave,
      center.dy + 40 - flameHeight * 0.5,
      center.dx + flameWidth / 2,
      center.dy + 40,
    );
    outerPath.close();

    final outerPaint = Paint()
      ..color = Colors.deepOrange
      ..style = PaintingStyle.fill;
    canvas.drawPath(outerPath, outerPaint);

    // 2. Middle Flame (Yellow-Orange)
    final midPath = Path();
    final midWave = -wave * 0.8;
    midPath.moveTo(center.dx - flameWidth * 0.35, center.dy + 40);
    midPath.quadraticBezierTo(
      center.dx - flameWidth * 0.35 - midWave,
      center.dy + 40 - flameHeight * 0.45,
      center.dx + midWave,
      center.dy + 40 - flameHeight * 0.75,
    );
    midPath.quadraticBezierTo(
      center.dx + flameWidth * 0.35 + midWave,
      center.dy + 40 - flameHeight * 0.45,
      center.dx + flameWidth * 0.35,
      center.dy + 40,
    );
    midPath.close();

    final midPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;
    canvas.drawPath(midPath, midPaint);

    // 3. Inner White-Hot Core Flame
    final innerPath = Path();
    innerPath.moveTo(center.dx - flameWidth * 0.18, center.dy + 40);
    innerPath.quadraticBezierTo(
      center.dx,
      center.dy + 40 - flameHeight * 0.3,
      center.dx,
      center.dy + 40 - flameHeight * 0.5,
    );
    innerPath.quadraticBezierTo(
      center.dx + flameWidth * 0.18,
      center.dy + 40 - flameHeight * 0.3,
      center.dx + flameWidth * 0.18,
      center.dy + 40,
    );
    innerPath.close();

    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(innerPath, innerPaint);

    // Rising embers
    if (isRunning) {
      final sparkPaint = Paint()..color = Colors.yellowAccent;
      for (int i = 0; i < 10; i++) {
        double p = (animationValue + i * 0.1) % 1.0;
        double sx = center.dx + math.sin(p * math.pi * 3 + i) * (20 + i * 3);
        double sy = (center.dy + 20) - p * (flameHeight + 40);
        double r = (1 - p) * 3 + 1;
        canvas.drawCircle(Offset(sx, sy), r, sparkPaint);
      }
    }
  }

  void _paintSpace(Canvas canvas, Size size, Offset center) {
    // Clip whole animation to the circular container
    final circleClip = Path()
      ..addOval(Rect.fromCenter(center: center, width: size.width, height: size.height));
    canvas.save();
    canvas.clipPath(circleClip);

    // Falling and Twinkling background stars
    final starPaint = Paint()..color = Colors.white.withOpacity(0.7);
    for (int i = 0; i < 22; i++) {
      double dist = 20.0 + (i * 11) % 70;
      double angle = (i * 37) * math.pi / 180; 
      
      // Falling effect
      double fallOffset = isRunning ? (animationValue * 120 + (i * 10)) % 120 : 0;
      
      double opacity = 0.2 + 0.8 * math.sin(animationValue * math.pi * 4 + i);
      starPaint.color = Colors.white.withOpacity(opacity.clamp(0.1, 1.0));
      
      double sx = center.dx + math.cos(angle) * dist;
      double sy = center.dy - 60 + math.sin(angle) * dist + fallOffset;
      if (sy > center.dy + 60) sy -= 120; // wrap around

      canvas.drawCircle(Offset(sx, sy), (i % 3) + 1.2, starPaint);
    }

    // DESTINATION PLANET (Approaches as progress increases)
    final planetY = center.dy - 60 + progress * 25; // Smooth descent toward upper center
    final planetRadius = 22.0 + progress * 16.0;   // Smooth growth in size (22 -> 38)
    final planetCenter = Offset(center.dx, planetY);

    final ringRect = Rect.fromCenter(
      center: planetCenter,
      width: planetRadius * 2.6,
      height: planetRadius * 0.7,
    );

    final ringPaint = Paint()
      ..color = Colors.amber.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    // 1. Draw BACK portion of Saturn Ring (behind planet)
    final ringBackPath = Path()..addArc(ringRect, math.pi, math.pi);
    canvas.drawPath(ringBackPath, ringPaint);

    // 2. Planet Atmospheric Glow
    final glowPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(planetCenter, planetRadius + 6, glowPaint);

    // 3. Planet Body (Curated 3D Shader)
    final planetPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        colors: [
          Colors.cyanAccent.shade100,
          Colors.teal.shade400,
          Colors.indigo.shade900,
        ],
        stops: const [0.1, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: planetCenter, radius: planetRadius));
    canvas.drawCircle(planetCenter, planetRadius, planetPaint);

    // 4. Subtle Surface Cloud Bands
    final bandPaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawArc(
      Rect.fromCircle(center: planetCenter, radius: planetRadius * 0.7),
      -0.2,
      1.8,
      false,
      bandPaint,
    );

    // 5. Draw FRONT portion of Saturn Ring (in front of planet for 3D depth)
    final ringFrontPath = Path()..addArc(ringRect, 0, math.pi);
    canvas.drawPath(ringFrontPath, ringPaint);

    // ROCKET TRAJECTORY
    // Rocket moves smoothly from bottom (+55) to just below planet (+12)
    final launchY = 55.0 - progress * 43.0; 
    
    // Shaking effect when engine is running
    final shakeX = isRunning ? math.sin(animationValue * math.pi * 30) * 1.2 : 0.0;
    final shakeY = isRunning ? math.cos(animationValue * math.pi * 25) * 1.2 : 0.0;
    
    final rocketCenter = Offset(center.dx + shakeX, center.dy + launchY + shakeY);

    // Rocket Exhaust Flames if running
    if (isRunning) {
      final exhaustPaint = Paint()
        ..color = Colors.orangeAccent
        ..style = PaintingStyle.fill;

      final p = Path()
        ..moveTo(rocketCenter.dx - 9, rocketCenter.dy + 22)
        ..lineTo(rocketCenter.dx, rocketCenter.dy + 38 + math.sin(animationValue * math.pi * 6) * 7)
        ..lineTo(rocketCenter.dx + 9, rocketCenter.dy + 22)
        ..close();
      canvas.drawPath(p, exhaustPaint);
    }

    // Rocket Body
    final bodyPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final rocketPath = Path()
      ..moveTo(rocketCenter.dx, rocketCenter.dy - 30)
      ..quadraticBezierTo(rocketCenter.dx + 18, rocketCenter.dy - 5, rocketCenter.dx + 13, rocketCenter.dy + 22)
      ..lineTo(rocketCenter.dx - 13, rocketCenter.dy + 22)
      ..quadraticBezierTo(rocketCenter.dx - 18, rocketCenter.dy - 5, rocketCenter.dx, rocketCenter.dy - 30)
      ..close();
    canvas.drawPath(rocketPath, bodyPaint);

    // Rocket Porthole Window
    final windowPaint = Paint()..color = Colors.cyanAccent;
    canvas.drawCircle(Offset(rocketCenter.dx, rocketCenter.dy - 7), 6, windowPaint);

    // Fins
    final finPaint = Paint()..color = color.withOpacity(0.75);
    final leftFin = Path()
      ..moveTo(rocketCenter.dx - 13, rocketCenter.dy + 8)
      ..lineTo(rocketCenter.dx - 22, rocketCenter.dy + 24)
      ..lineTo(rocketCenter.dx - 13, rocketCenter.dy + 22)
      ..close();
    final rightFin = Path()
      ..moveTo(rocketCenter.dx + 13, rocketCenter.dy + 8)
      ..lineTo(rocketCenter.dx + 22, rocketCenter.dy + 24)
      ..lineTo(rocketCenter.dx + 13, rocketCenter.dy + 22)
      ..close();
    canvas.drawPath(leftFin, finPaint);
    canvas.drawPath(rightFin, finPaint);

    canvas.restore();
  }

  void _paintHourglass(Canvas canvas, Size size, Offset center) {
    const width = 64.0;
    const height = 114.0;
    final topY = center.dy - height / 2;
    final bottomY = center.dy + height / 2;

    final sandPaint = Paint()
      ..color = Colors.amberAccent
      ..style = PaintingStyle.fill;

    final glassPaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeJoin = StrokeJoin.round;

    final capPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Outer Glass Path (Top bulb + Neck + Bottom bulb)
    final glassPath = Path()
      ..moveTo(center.dx - width / 2, topY)
      ..quadraticBezierTo(center.dx - width / 2, center.dy - 15, center.dx - 6, center.dy)
      ..quadraticBezierTo(center.dx - width / 2, center.dy + 15, center.dx - width / 2, bottomY)
      ..lineTo(center.dx + width / 2, bottomY)
      ..quadraticBezierTo(center.dx + width / 2, center.dy + 15, center.dx + 6, center.dy)
      ..quadraticBezierTo(center.dx + width / 2, center.dy - 15, center.dx + width / 2, topY)
      ..close();

    // Clip sand to glass shape
    canvas.save();
    canvas.clipPath(glassPath);

    // 1. Upper Chamber Sand (Funnel curve as it empties)
    final upperFill = (1.0 - progress);
    if (upperFill > 0) {
      final upperSandY = center.dy - (height / 2) * upperFill;
      final upperSandPath = Path()
        ..moveTo(center.dx - width, upperSandY)
        ..lineTo(center.dx + width, upperSandY)
        ..quadraticBezierTo(center.dx, upperSandY + 6, center.dx - width, upperSandY)
        ..lineTo(center.dx + width, center.dy)
        ..lineTo(center.dx - width, center.dy)
        ..close();
      canvas.drawPath(upperSandPath, sandPaint);
    }

    // 2. Lower Chamber Sand (Conical mound growing as progress increases)
    if (progress > 0) {
      final lowerSandHeight = (height / 2 - 8) * progress;
      final lowerSandY = bottomY - lowerSandHeight;
      final lowerSandPath = Path()
        ..moveTo(center.dx - width, bottomY)
        ..lineTo(center.dx + width, bottomY)
        ..lineTo(center.dx + width, lowerSandY)
        ..quadraticBezierTo(center.dx, lowerSandY - 12, center.dx - width, lowerSandY)
        ..close();
      canvas.drawPath(lowerSandPath, sandPaint);
    }

    // 3. Falling Sand Stream & Particles if running
    if (isRunning && progress < 1.0) {
      final streamPaint = Paint()
        ..color = Colors.amberAccent
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(center.dx, center.dy - 10), Offset(center.dx, bottomY - 10), streamPaint);

      // Sand particle sparks
      final particlePaint = Paint()..color = Colors.white.withOpacity(0.9);
      for (int i = 0; i < 6; i++) {
        double p = (animationValue + i * 0.16) % 1.0;
        double py = center.dy + p * (height / 2 - 15);
        double px = center.dx + math.sin(p * math.pi * 4) * 2;
        canvas.drawCircle(Offset(px, py), 1.5, particlePaint);
      }
    }

    canvas.restore();

    // Glass Reflection Highlights
    final reflectPaint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final topHighlight = Path()
      ..moveTo(center.dx - width * 0.38, topY + 12)
      ..quadraticBezierTo(center.dx - width * 0.35, center.dy - 25, center.dx - 14, center.dy - 10);
    canvas.drawPath(topHighlight, reflectPaint);

    final botHighlight = Path()
      ..moveTo(center.dx - width * 0.38, bottomY - 12)
      ..quadraticBezierTo(center.dx - width * 0.35, center.dy + 25, center.dx - 14, center.dy + 10);
    canvas.drawPath(botHighlight, reflectPaint);

    // Glass Outer Outline
    canvas.drawPath(glassPath, glassPaint);

    // Wooden / Metal Caps on Top and Bottom
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, topY - 4), width: width + 18, height: 9),
        const Radius.circular(4),
      ),
      capPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, bottomY + 4), width: width + 18, height: 9),
        const Radius.circular(4),
      ),
      capPaint,
    );
  }

  void _paintOcean(Canvas canvas, Size size, Offset center) {
    // Clip whole animation to the circular container
    final circleClip = Path()
      ..addOval(Rect.fromCenter(center: center, width: size.width, height: size.height));
    canvas.save();
    canvas.clipPath(circleClip);

    // 1. Sky & Sun (Sun rises higher into sky as progress increases)
    final sunY = center.dy - 5 - progress * 60; // Rises from above horizon up into sky
    final sunCenter = Offset(center.dx, sunY);

    // Sun Glow
    final sunGlow = Paint()
      ..color = Colors.amber.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(sunCenter, 26, sunGlow);

    // Sun Core
    final sunPaint = Paint()..color = Colors.amber;
    canvas.drawCircle(sunCenter, 18, sunPaint);

    // Sun Rays when running
    if (isRunning) {
      final rayPaint = Paint()
        ..color = Colors.amber.withOpacity(0.6)
        ..strokeWidth = 2;
      for (int i = 0; i < 8; i++) {
        double angle = i * (math.pi / 4) + animationValue * math.pi * 0.5;
        double rx1 = sunCenter.dx + math.cos(angle) * 22;
        double ry1 = sunCenter.dy + math.sin(angle) * 22;
        double rx2 = sunCenter.dx + math.cos(angle) * 30;
        double ry2 = sunCenter.dy + math.sin(angle) * 30;
        canvas.drawLine(Offset(rx1, ry1), Offset(rx2, ry2), rayPaint);
      }
    }

    // 2. Ocean Waves (Layer 1 - Deep Water extending across full circle)
    final waveWave = isRunning ? math.sin(animationValue * math.pi * 2) * 6 : 0.0;
    
    final oceanBackPath = Path()
      ..moveTo(center.dx - 120, center.dy + 15)
      ..quadraticBezierTo(center.dx - 60, center.dy + 15 + waveWave, center.dx, center.dy + 15)
      ..quadraticBezierTo(center.dx + 60, center.dy + 15 - waveWave, center.dx + 120, center.dy + 15)
      ..lineTo(center.dx + 120, center.dy + 120)
      ..lineTo(center.dx - 120, center.dy + 120)
      ..close();

    final oceanBackPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawPath(oceanBackPath, oceanBackPaint);

    // 3. Sailboat on the waves
    final boatX = center.dx + math.sin(animationValue * math.pi) * 12;
    final boatY = center.dy + 12 + waveWave * 0.5;

    // Boat Hull
    final hullPath = Path()
      ..moveTo(boatX - 18, boatY)
      ..lineTo(boatX + 18, boatY)
      ..lineTo(boatX + 12, boatY + 10)
      ..lineTo(boatX - 12, boatY + 10)
      ..close();
    canvas.drawPath(hullPath, Paint()..color = Colors.brown.shade700);

    // Sail
    final sailPath = Path()
      ..moveTo(boatX, boatY - 25)
      ..lineTo(boatX + 14, boatY - 4)
      ..lineTo(boatX, boatY - 4)
      ..close();
    canvas.drawPath(sailPath, Paint()..color = Colors.white.withOpacity(0.9));

    // Mast
    canvas.drawLine(
      Offset(boatX, boatY - 26),
      Offset(boatX, boatY),
      Paint()..color = Colors.brown.shade900..strokeWidth = 2,
    );

    // 4. Ocean Waves (Layer 2 - Foreground Waves extending across full circle)
    final oceanFrontPath = Path()
      ..moveTo(center.dx - 120, center.dy + 25)
      ..quadraticBezierTo(center.dx - 60, center.dy + 25 - waveWave, center.dx, center.dy + 25)
      ..quadraticBezierTo(center.dx + 60, center.dy + 25 + waveWave, center.dx + 120, center.dy + 25)
      ..lineTo(center.dx + 120, center.dy + 120)
      ..lineTo(center.dx - 120, center.dy + 120)
      ..close();

    final oceanFrontPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(oceanFrontPath, oceanFrontPaint);

    canvas.restore();
  }

  void _paintPotion(Canvas canvas, Size size, Offset center) {
    final glassPaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeJoin = StrokeJoin.round;

    // Erlenmeyer Flask shape
    final flaskPath = Path()
      ..moveTo(center.dx - 14, center.dy - 48)
      ..lineTo(center.dx + 14, center.dy - 48)
      ..lineTo(center.dx + 14, center.dy - 18)
      ..lineTo(center.dx + 48, center.dy + 42)
      ..quadraticBezierTo(center.dx + 52, center.dy + 54, center.dx + 38, center.dy + 54)
      ..lineTo(center.dx - 38, center.dy + 54)
      ..quadraticBezierTo(center.dx - 52, center.dy + 54, center.dx - 48, center.dy + 42)
      ..lineTo(center.dx - 14, center.dy - 18)
      ..close();

    // 1. Draw Liquid Fill inside clip
    canvas.save();
    canvas.clipPath(flaskPath);

    final fillLevel = 44 - progress * 78; // Fill level moves up as progress increases
    final waveOffset = isRunning ? math.sin(animationValue * math.pi * 2) * 4 : 0.0;

    final liquidPath = Path()
      ..moveTo(center.dx - 70, center.dy + fillLevel + waveOffset)
      ..quadraticBezierTo(
        center.dx,
        center.dy + fillLevel - waveOffset,
        center.dx + 70,
        center.dy + fillLevel + waveOffset,
      )
      ..lineTo(center.dx + 70, center.dy + 100)
      ..lineTo(center.dx - 70, center.dy + 100)
      ..close();

    final liquidPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color, color.withOpacity(0.7), Colors.purpleAccent],
      ).createShader(Rect.fromLTWH(center.dx - 50, center.dy - 50, 100, 110))
      ..style = PaintingStyle.fill;
    canvas.drawPath(liquidPath, liquidPaint);

    // Bubbles & Sparkles rising if running
    if (isRunning) {
      final bubblePaint = Paint()..color = Colors.white.withOpacity(0.75);
      for (int i = 0; i < 8; i++) {
        double p = (animationValue + i * 0.125) % 1.0;
        double bx = center.dx + math.sin(p * math.pi * 2 + i) * 18;
        double by = (center.dy + 45) - p * (50 + progress * 40);
        if (by > center.dy + fillLevel) {
          canvas.drawCircle(Offset(bx, by), 2.5 + (i % 3), bubblePaint);
        }
      }
    }

    canvas.restore();

    // Measurement Graduation Ticks on Flask Side
    final tickPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(center.dx + 26, center.dy + 25), Offset(center.dx + 34, center.dy + 25), tickPaint);
    canvas.drawLine(Offset(center.dx + 22, center.dy + 5), Offset(center.dx + 28, center.dy + 5), tickPaint);
    canvas.drawLine(Offset(center.dx + 17, center.dy - 10), Offset(center.dx + 23, center.dy - 10), tickPaint);

    // 2. Draw Glass Outline on top for crisp edges
    canvas.drawPath(flaskPath, glassPaint);

    // Flask Lip Rim
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, center.dy - 48), width: 34, height: 6),
        const Radius.circular(3),
      ),
      Paint()
        ..color = Colors.white.withOpacity(0.85)
        ..style = PaintingStyle.fill,
    );

    // Floating Cork Stopper when running
    final corkY = isRunning ? center.dy - 62 + math.sin(animationValue * math.pi * 2) * 3 : center.dy - 55;
    final corkPaint = Paint()..color = Colors.brown.shade600;
    final corkPath = Path()
      ..moveTo(center.dx - 12, corkY)
      ..lineTo(center.dx + 12, corkY)
      ..lineTo(center.dx + 10, corkY - 10)
      ..lineTo(center.dx - 10, corkY - 10)
      ..close();
    canvas.drawPath(corkPath, corkPaint);
  }

  void _paintCoffee(Canvas canvas, Size size, Offset center) {
    // Clip whole animation to circular container
    final circleClip = Path()
      ..addOval(Rect.fromCenter(center: center, width: size.width, height: size.height));
    canvas.save();
    canvas.clipPath(circleClip);

    // 1. Saucer Plate at bottom
    final saucerPaint = Paint()
      ..color = color.withOpacity(0.35)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 48), width: 115, height: 16),
      saucerPaint,
    );

    // 2. Coffee Mug Dimensions
    const mugWidth = 72.0;
    const mugHeight = 65.0;
    final mugTopY = center.dy - 15;
    final mugBottomY = mugTopY + mugHeight;

    final mugPath = Path()
      ..moveTo(center.dx - mugWidth / 2, mugTopY)
      ..lineTo(center.dx + mugWidth / 2, mugTopY)
      ..lineTo(center.dx + mugWidth * 0.42, mugBottomY - 6)
      ..quadraticBezierTo(center.dx + mugWidth * 0.38, mugBottomY, center.dx + mugWidth * 0.25, mugBottomY)
      ..lineTo(center.dx - mugWidth * 0.25, mugBottomY)
      ..quadraticBezierTo(center.dx - mugWidth * 0.38, mugBottomY, center.dx - mugWidth * 0.42, mugBottomY - 6)
      ..close();

    // 3. Mug Handle (Right side)
    final handlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    final handlePath = Path()
      ..moveTo(center.dx + mugWidth * 0.42, mugTopY + 12)
      ..cubicTo(
        center.dx + mugWidth * 0.85,
        mugTopY + 10,
        center.dx + mugWidth * 0.85,
        mugBottomY - 12,
        center.dx + mugWidth * 0.38,
        mugBottomY - 14,
      );
    canvas.drawPath(handlePath, handlePaint);

    // 4. Fill Coffee inside Mug (Clipped to mug interior)
    canvas.save();
    canvas.clipPath(mugPath);

    // Draw glass interior background
    canvas.drawRect(
      Rect.fromLTRB(center.dx - mugWidth, mugTopY, center.dx + mugWidth, mugBottomY + 10),
      Paint()..color = Colors.brown.shade900.withOpacity(0.2),
    );

    // Coffee Liquid Fill level (rises with progress)
    final fillHeight = (mugHeight - 10) * progress;
    if (fillHeight > 0) {
      final coffeeY = mugBottomY - fillHeight;
      final waveOffset = isRunning ? math.sin(animationValue * math.pi * 2) * 2 : 0.0;

      final coffeePath = Path()
        ..moveTo(center.dx - mugWidth, mugBottomY + 10)
        ..lineTo(center.dx + mugWidth, mugBottomY + 10)
        ..lineTo(center.dx + mugWidth, coffeeY + waveOffset)
        ..quadraticBezierTo(center.dx, coffeeY - waveOffset, center.dx - mugWidth, coffeeY + waveOffset)
        ..close();

      final coffeePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.amber.shade900, Colors.brown.shade900],
        ).createShader(Rect.fromLTWH(center.dx - 40, coffeeY, 80, fillHeight + 10));
      canvas.drawPath(coffeePath, coffeePaint);

      // Creamy Golden Foam Layer on Top Surface
      final foamPaint = Paint()
        ..color = Colors.amber.shade200.withOpacity(0.85)
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTRB(center.dx - mugWidth * 0.45, coffeeY - 2, center.dx + mugWidth * 0.45, coffeeY + 3),
        foamPaint,
      );
    }

    canvas.restore();

    // 5. Draw Ceramic Mug Outer Wall & Rim
    final mugPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5;
    canvas.drawPath(mugPath, mugPaint);

    // Rim Line
    canvas.drawLine(Offset(center.dx - mugWidth / 2, mugTopY), Offset(center.dx + mugWidth / 2, mugTopY), mugPaint);

    // Coffee Bean Emblem on Front of Mug
    final beanCenter = Offset(center.dx, center.dy + 16);
    final beanPaint = Paint()..color = color.withOpacity(0.7);
    canvas.drawOval(Rect.fromCenter(center: beanCenter, width: 14, height: 20), beanPaint);
    canvas.drawArc(
      Rect.fromCenter(center: beanCenter, width: 10, height: 18),
      -1.2,
      2.4,
      false,
      Paint()
        ..color = Colors.black38
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // 6. Rising Steam Curls when running
    if (isRunning) {
      final steamPaint = Paint()
        ..color = Colors.white.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < 3; i++) {
        double p = (animationValue + i * 0.33) % 1.0;
        double sy = mugTopY - 8 - p * 42;
        double sx = center.dx - 16 + i * 16 + math.sin(p * math.pi * 3) * 5;
        double alpha = (1 - p).clamp(0.0, 1.0) * 0.6;

        steamPaint.color = Colors.white.withOpacity(alpha);

        final steamPath = Path()
          ..moveTo(sx, sy)
          ..quadraticBezierTo(sx + 6, sy - 8, sx - 4, sy - 16);
        canvas.drawPath(steamPath, steamPaint);
      }
    }

    canvas.restore();
  }

  void _paintZen(Canvas canvas, Size size, Offset center) {
    // Clip whole animation to circular container
    final circleClip = Path()
      ..addOval(Rect.fromCenter(center: center, width: size.width, height: size.height));
    canvas.save();
    canvas.clipPath(circleClip);

    // 1. Stacked Zen Stones at bottom
    final stonePaint = Paint()..color = Colors.grey.shade700;
    final stoneLightPaint = Paint()..color = Colors.grey.shade500;

    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy + 62), width: 70, height: 18), stonePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx - 2, center.dy + 50), width: 50, height: 14), stoneLightPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx + 2, center.dy + 40), width: 34, height: 11), stonePaint);

    // 2. Bamboo Stalk grows upward with progress
    final bambooHeight = 40.0 + progress * 70;
    final bambooTopY = center.dy + 35 - bambooHeight;

    final stalkPaint = Paint()
      ..color = color
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(center.dx, center.dy + 35), Offset(center.dx, bambooTopY), stalkPaint);

    // Bamboo Nodes
    final nodePaint = Paint()
      ..color = Colors.green.shade900
      ..strokeWidth = 9;
    final segmentCount = (bambooHeight / 25).floor();
    for (int i = 0; i <= segmentCount; i++) {
      double nodeY = center.dy + 35 - i * 25;
      if (nodeY >= bambooTopY) {
        canvas.drawLine(Offset(center.dx - 5, nodeY), Offset(center.dx + 5, nodeY), nodePaint);

        // Leaves sprouting at node
        final leafPaint = Paint()..color = color.withOpacity(0.85);
        final leafPath = Path()
          ..moveTo(center.dx, nodeY)
          ..quadraticBezierTo(center.dx + 18, nodeY - 12, center.dx + 24, nodeY - 4)
          ..quadraticBezierTo(center.dx + 12, nodeY + 4, center.dx, nodeY)
          ..close();
        canvas.drawPath(leafPath, leafPaint);
      }
    }

    // 3. Falling Sakura (Cherry Blossom) Petals when running
    if (isRunning) {
      final sakuraPaint = Paint()..color = Colors.pinkAccent.shade100.withOpacity(0.85);
      for (int i = 0; i < 7; i++) {
        double p = (animationValue + i * 0.14) % 1.0;
        double px = center.dx - 50 + p * 100 + math.sin(p * math.pi * 3) * 15;
        double py = (center.dy - 60) + p * 120;

        canvas.save();
        canvas.translate(px, py);
        canvas.rotate(p * math.pi * 2);
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 8, height: 4), sakuraPaint);
        canvas.restore();
      }
    }

    canvas.restore();
  }

  void _paintBattery(Canvas canvas, Size size, Offset center) {
    final circleClip = Path()
      ..addOval(Rect.fromCenter(center: center, width: size.width, height: size.height));
    canvas.save();
    canvas.clipPath(circleClip);

    const batWidth = 56.0;
    const batHeight = 100.0;
    final batTopY = center.dy - batHeight / 2 + 5;
    final batBottomY = batTopY + batHeight;

    // Battery Positive Terminal Cap on Top
    final capPaint = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, batTopY - 4), width: 22, height: 8),
        const Radius.circular(3),
      ),
      capPaint,
    );

    // Outer Battery Frame
    final framePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final batRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 5), width: batWidth, height: batHeight),
      const Radius.circular(10),
    );

    // Fill Energy (rises with progress)
    canvas.save();
    canvas.clipRRect(batRRect);

    final fillHeight = (batHeight - 8) * progress;
    if (fillHeight > 0) {
      final fillY = batBottomY - fillHeight;
      final energyPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.cyanAccent, color, Colors.lightGreenAccent],
        ).createShader(Rect.fromLTWH(center.dx - 25, fillY, 50, fillHeight));
      canvas.drawRect(Rect.fromLTRB(center.dx - batWidth, fillY, center.dx + batWidth, batBottomY + 5), energyPaint);
    }
    canvas.restore();

    canvas.drawRRect(batRRect, framePaint);

    // Central Lightning Bolt Symbol
    final boltPaint = Paint()
      ..color = progress > 0.4 ? Colors.white : color.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final boltPath = Path()
      ..moveTo(center.dx + 2, center.dy - 20)
      ..lineTo(center.dx - 12, center.dy + 5)
      ..lineTo(center.dx - 2, center.dy + 5)
      ..lineTo(center.dx - 4, center.dy + 25)
      ..lineTo(center.dx + 10, center.dy)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(boltPath, boltPaint);

    // Electric Sparks when running
    if (isRunning) {
      final sparkPaint = Paint()..color = Colors.cyanAccent.withOpacity(0.85);
      for (int i = 0; i < 6; i++) {
        double p = (animationValue + i * 0.16) % 1.0;
        double sx = center.dx - 20 + (i * 11) % 40;
        double sy = (center.dy + 35) - p * 70;
        canvas.drawCircle(Offset(sx, sy), 2.0, sparkPaint);
      }
    }

    canvas.restore();
  }

  void _paintCrystal(Canvas canvas, Size size, Offset center) {
    final circleClip = Path()
      ..addOval(Rect.fromCenter(center: center, width: size.width, height: size.height));
    canvas.save();
    canvas.clipPath(circleClip);

    // 1. Crystal Aura Glow
    final glowPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.25 + math.sin(animationValue * math.pi * 2) * 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, 45 + progress * 15, glowPaint);

    // 2. Crystal Rotation & Floating offset
    final floatY = isRunning ? math.sin(animationValue * math.pi * 2) * 6 : 0.0;
    final crystalCenter = Offset(center.dx, center.dy + floatY);
    const sizeFactor = 40.0;

    // Facets of 3D Crystal Gem
    final topVertex = Offset(crystalCenter.dx, crystalCenter.dy - sizeFactor - progress * 10);
    final botVertex = Offset(crystalCenter.dx, crystalCenter.dy + sizeFactor + progress * 10);
    final leftVertex = Offset(crystalCenter.dx - sizeFactor * 0.7, crystalCenter.dy);
    final rightVertex = Offset(crystalCenter.dx + sizeFactor * 0.7, crystalCenter.dy);
    final midVertex = Offset(crystalCenter.dx, crystalCenter.dy + 5);

    // Left Upper Facet
    final f1 = Path()..moveTo(topVertex.dx, topVertex.dy)..lineTo(leftVertex.dx, leftVertex.dy)..lineTo(midVertex.dx, midVertex.dy)..close();
    canvas.drawPath(f1, Paint()..color = Colors.cyanAccent.shade200.withOpacity(0.9));

    // Right Upper Facet
    final f2 = Path()..moveTo(topVertex.dx, topVertex.dy)..lineTo(rightVertex.dx, rightVertex.dy)..lineTo(midVertex.dx, midVertex.dy)..close();
    canvas.drawPath(f2, Paint()..color = color.withOpacity(0.9));

    // Left Lower Facet
    final f3 = Path()..moveTo(botVertex.dx, botVertex.dy)..lineTo(leftVertex.dx, leftVertex.dy)..lineTo(midVertex.dx, midVertex.dy)..close();
    canvas.drawPath(f3, Paint()..color = Colors.purpleAccent.shade100.withOpacity(0.85));

    // Right Lower Facet
    final f4 = Path()..moveTo(botVertex.dx, botVertex.dy)..lineTo(rightVertex.dx, rightVertex.dy)..lineTo(midVertex.dx, midVertex.dy)..close();
    canvas.drawPath(f4, Paint()..color = Colors.indigo.shade400.withOpacity(0.95));

    // Crystal Wireframe Outline
    final wirePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(f1, wirePaint);
    canvas.drawPath(f2, wirePaint);
    canvas.drawPath(f3, wirePaint);
    canvas.drawPath(f4, wirePaint);

    // Orbiting Energy Ring when running
    if (isRunning) {
      final ringPaint = Paint()
        ..color = Colors.cyanAccent.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawOval(
        Rect.fromCenter(center: crystalCenter, width: sizeFactor * 2.2, height: sizeFactor * 0.6),
        ringPaint,
      );
    }

    canvas.restore();
  }

  void _paintVinyl(Canvas canvas, Size size, Offset center) {
    final circleClip = Path()
      ..addOval(Rect.fromCenter(center: center, width: size.width, height: size.height));
    canvas.save();
    canvas.clipPath(circleClip);

    // 1. Vinyl Record Disc Base
    const radius = 68.0;
    canvas.drawCircle(center, radius, Paint()..color = Colors.grey.shade900);

    // 2. Concentric Vinyl Grooves
    final groovePaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int r = 25; r < radius - 5; r += 7) {
      canvas.drawCircle(center, r.toDouble(), groovePaint);
    }

    // 3. Center Label (Spins when running)
    canvas.save();
    if (isRunning) {
      canvas.translate(center.dx, center.dy);
      canvas.rotate(animationValue * math.pi * 2);
      canvas.translate(-center.dx, -center.dy);
    }

    final labelPaint = Paint()..color = color;
    canvas.drawCircle(center, 22, labelPaint);
    canvas.drawCircle(center, 5, Paint()..color = Colors.white);

    canvas.restore();

    // 4. Floating Musical Notes when running
    if (isRunning) {
      final notePaint = Paint()..color = color;
      final textPainter = TextPainter(textDirection: TextDirection.ltr);

      for (int i = 0; i < 4; i++) {
        double p = (animationValue + i * 0.25) % 1.0;
        double nx = center.dx + math.sin(p * math.pi * 2 + i) * 55;
        double ny = (center.dy + 30) - p * 80;

        textPainter.text = TextSpan(
          text: i % 2 == 0 ? '🎵' : '🎶',
          style: TextStyle(fontSize: 16, color: color.withOpacity(1 - p)),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(nx, ny));
      }
    }

    canvas.restore();
  }

  void _paintCandle(Canvas canvas, Size size, Offset center) {
    final circleClip = Path()
      ..addOval(Rect.fromCenter(center: center, width: size.width, height: size.height));
    canvas.save();
    canvas.clipPath(circleClip);

    // 1. Brass Candle Holder Stand
    final standY = center.dy + 45;
    final standPaint = Paint()..color = color.withOpacity(0.4);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, standY), width: 95, height: 16), standPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, standY - 4), width: 60, height: 10), standPaint);

    // 2. Candle Wax Pillar
    const waxWidth = 36.0;
    const waxHeight = 70.0;
    final waxTopY = center.dy - 15;
    final waxBotY = waxTopY + waxHeight;

    final waxRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx, waxTopY + waxHeight / 2), width: waxWidth, height: waxHeight),
      const Radius.circular(6),
    );
    canvas.drawRRect(waxRRect, Paint()..color = Colors.amber.shade50);

    // Wax Drips on side
    final dripPaint = Paint()..color = Colors.amber.shade100;
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx - 12, waxTopY + 18), width: 8, height: 22), dripPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx + 10, waxTopY + 28), width: 7, height: 18), dripPaint);

    // 3. Black Wick
    final wickY = waxTopY - 6;
    canvas.drawLine(
      Offset(center.dx, waxTopY + 2),
      Offset(center.dx, wickY),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // 4. Candle Flame Glow Halo
    final flameY = wickY - 14;
    final flicker = isRunning ? math.sin(animationValue * math.pi * 4) * 2.5 : 0.0;

    final auraPaint = Paint()
      ..color = Colors.amberAccent.withOpacity(0.3 + (flicker.abs() * 0.05))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(Offset(center.dx + flicker * 0.5, flameY), 28, auraPaint);

    // 5. Teardrop Flame (Outer Orange, Inner White Core)
    final outerFlame = Path()
      ..moveTo(center.dx + flicker, flameY - 18)
      ..quadraticBezierTo(center.dx + 12 + flicker, flameY, center.dx + flicker, flameY + 10)
      ..quadraticBezierTo(center.dx - 12 + flicker, flameY, center.dx + flicker, flameY - 18)
      ..close();
    canvas.drawPath(outerFlame, Paint()..color = Colors.deepOrangeAccent);

    final innerFlame = Path()
      ..moveTo(center.dx + flicker, flameY - 10)
      ..quadraticBezierTo(center.dx + 6 + flicker, flameY, center.dx + flicker, flameY + 6)
      ..quadraticBezierTo(center.dx - 6 + flicker, flameY, center.dx + flicker, flameY - 10)
      ..close();
    canvas.drawPath(innerFlame, Paint()..color = Colors.yellowAccent);

    // Core White hot center
    canvas.drawCircle(Offset(center.dx + flicker, flameY + 2), 3, Paint()..color = Colors.white);

    // 6. Warm Smoke Trail when running
    if (isRunning) {
      final smokePaint = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (int i = 0; i < 3; i++) {
        double p = (animationValue + i * 0.33) % 1.0;
        double sx = center.dx + math.sin(p * math.pi * 3) * 8;
        double sy = (flameY - 20) - p * 40;

        smokePaint.color = Colors.white.withOpacity((1 - p) * 0.4);
        canvas.drawCircle(Offset(sx, sy), 2 + p * 4, smokePaint);
      }
    }

    canvas.restore();
  }

  void _paintMountain(Canvas canvas, Size size, Offset center) {
    final circleClip = Path()
      ..addOval(Rect.fromCenter(center: center, width: size.width, height: size.height));
    canvas.save();
    canvas.clipPath(circleClip);

    // 1. Mountain Peak Paths
    final mainPeakY = center.dy - 35;
    final botY = center.dy + 55;

    // Background secondary mountain
    final sidePeak = Path()
      ..moveTo(center.dx - 65, botY)
      ..lineTo(center.dx - 30, center.dy - 10)
      ..lineTo(center.dx + 15, botY)
      ..close();
    canvas.drawPath(sidePeak, Paint()..color = color.withOpacity(0.5));

    // Main Mountain Peak
    final mainPeak = Path()
      ..moveTo(center.dx - 55, botY)
      ..lineTo(center.dx + 10, mainPeakY)
      ..lineTo(center.dx + 65, botY)
      ..close();
    canvas.drawPath(mainPeak, Paint()..color = color.withOpacity(0.85));

    // Snow Cap on Top Peak
    final snowCap = Path()
      ..moveTo(center.dx + 10, mainPeakY)
      ..lineTo(center.dx - 6, mainPeakY + 22)
      ..lineTo(center.dx + 4, mainPeakY + 18)
      ..lineTo(center.dx + 15, mainPeakY + 24)
      ..lineTo(center.dx + 26, mainPeakY + 20)
      ..close();
    canvas.drawPath(snowCap, Paint()..color = Colors.white.withOpacity(0.95));

    // 2. Victory Flag at Peak
    final flagX = center.dx + 10;
    final flagY = mainPeakY - 15;
    canvas.drawLine(Offset(flagX, mainPeakY + 5), Offset(flagX, flagY), Paint()..color = Colors.brown.shade800..strokeWidth = 2);

    final flagPath = Path()
      ..moveTo(flagX, flagY)
      ..lineTo(flagX + 14, flagY + 4)
      ..lineTo(flagX, flagY + 9)
      ..close();
    canvas.drawPath(flagPath, Paint()..color = Colors.redAccent);

    // 3. Climber / Progress Indicator along mountain trail
    final climberProgress = progress;
    final climberX = (center.dx - 55) + climberProgress * 65;
    final climberY = botY - climberProgress * (botY - mainPeakY);

    final climberPaint = Paint()..color = Colors.amberAccent;
    canvas.drawCircle(Offset(climberX, climberY - 4), 4, climberPaint);
    canvas.drawLine(Offset(climberX, climberY - 4), Offset(climberX, climberY + 3), climberPaint..strokeWidth = 2);

    // 4. Drifting Clouds when running
    if (isRunning) {
      final cloudPaint = Paint()..color = Colors.white.withOpacity(0.65);
      for (int i = 0; i < 2; i++) {
        double p = (animationValue + i * 0.5) % 1.0;
        double cx = center.dx - 70 + p * 140;
        double cy = center.dy - 40 + i * 35;

        canvas.drawCircle(Offset(cx, cy), 12, cloudPaint);
        canvas.drawCircle(Offset(cx - 10, cy + 3), 8, cloudPaint);
        canvas.drawCircle(Offset(cx + 10, cy + 2), 9, cloudPaint);
      }
    }

    canvas.restore();
  }

  void _paintBalloon(Canvas canvas, Size size, Offset center) {
    final circleClip = Path()
      ..addOval(Rect.fromCenter(center: center, width: size.width, height: size.height));
    canvas.save();
    canvas.clipPath(circleClip);

    // Balloon Y position rises as progress increases
    final maxRise = 55.0;
    final balloonY = (center.dy + 25) - progress * maxRise;
    final sway = isRunning ? math.sin(animationValue * math.pi * 2) * 4 : 0.0;
    final balloonCenter = Offset(center.dx + sway, balloonY);

    // 1. Wicker Basket
    const basketWidth = 22.0;
    const basketHeight = 16.0;
    final basketTopY = balloonCenter.dy + 38;

    final basketRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(balloonCenter.dx, basketTopY + basketHeight / 2), width: basketWidth, height: basketHeight),
      const Radius.circular(3),
    );
    canvas.drawRRect(basketRRect, Paint()..color = Colors.brown.shade700);

    // Suspension Ropes
    final ropePaint = Paint()
      ..color = Colors.brown.shade400
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(balloonCenter.dx - 12, balloonCenter.dy + 20), Offset(balloonCenter.dx - 8, basketTopY), ropePaint);
    canvas.drawLine(Offset(balloonCenter.dx + 12, balloonCenter.dy + 20), Offset(balloonCenter.dx + 8, basketTopY), ropePaint);

    // 2. Hot Air Balloon Envelope (Hot-air teardrop shape)
    const balloonRadius = 34.0;
    final balloonPath = Path()
      ..addOval(Rect.fromCircle(center: balloonCenter, radius: balloonRadius));
    canvas.drawPath(balloonPath, Paint()..color = color);

    // Stripe pattern on balloon
    final stripe1 = Paint()..color = Colors.amber.shade400;
    canvas.drawOval(Rect.fromCenter(center: balloonCenter, width: balloonRadius * 1.2, height: balloonRadius * 2), stripe1);

    final stripe2 = Paint()..color = Colors.deepOrangeAccent;
    canvas.drawOval(Rect.fromCenter(center: balloonCenter, width: balloonRadius * 0.5, height: balloonRadius * 2), stripe2);

    // Rim Outline
    canvas.drawCircle(balloonCenter, balloonRadius, Paint()..color = Colors.white.withOpacity(0.8)..style = PaintingStyle.stroke..strokeWidth = 2);

    // 3. Clouds floating past when running
    if (isRunning) {
      final cloudPaint = Paint()..color = Colors.white.withOpacity(0.7);
      for (int i = 0; i < 3; i++) {
        double p = (animationValue + i * 0.33) % 1.0;
        double cx = center.dx - 70 + p * 140;
        double cy = (center.dy - 30) + i * 30;

        canvas.drawCircle(Offset(cx, cy), 14, cloudPaint);
        canvas.drawCircle(Offset(cx - 12, cy + 3), 9, cloudPaint);
        canvas.drawCircle(Offset(cx + 12, cy + 2), 10, cloudPaint);
      }
    }

    canvas.restore();
  }

  void _paintUfo(Canvas canvas, Size size, Offset center) {
    final circleClip = Path()
      ..addOval(Rect.fromCenter(center: center, width: size.width, height: size.height));
    canvas.save();
    canvas.clipPath(circleClip);

    final ufoY = center.dy - 30 + (isRunning ? math.sin(animationValue * math.pi * 2) * 5 : 0.0);
    final ufoCenter = Offset(center.dx, ufoY);

    // 1. Glowing Abduction Tractor Beam Emitting Downward
    final beamProgress = progress;
    if (beamProgress > 0) {
      final beamBottomY = center.dy + 55;
      final beamWidthAtBottom = 75.0 * beamProgress;

      final beamPath = Path()
        ..moveTo(ufoCenter.dx - 18, ufoCenter.dy + 8)
        ..lineTo(ufoCenter.dx + 18, ufoCenter.dy + 8)
        ..lineTo(ufoCenter.dx + beamWidthAtBottom / 2, beamBottomY)
        ..lineTo(ufoCenter.dx - beamWidthAtBottom / 2, beamBottomY)
        ..close();

      final beamPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.cyanAccent.withOpacity(0.7),
            Colors.greenAccent.withOpacity(0.2),
          ],
        ).createShader(Rect.fromLTRB(ufoCenter.dx - 40, ufoCenter.dy, ufoCenter.dx + 40, beamBottomY));
      canvas.drawPath(beamPath, beamPaint);

      // Energy particles in beam when running
      if (isRunning) {
        final sparkPaint = Paint()..color = Colors.white.withOpacity(0.85);
        for (int i = 0; i < 5; i++) {
          double p = (animationValue + i * 0.2) % 1.0;
          double sx = ufoCenter.dx - 20 + (i * 12) % 40;
          double sy = (ufoCenter.dy + 15) + p * (beamBottomY - ufoCenter.dy - 15);
          canvas.drawCircle(Offset(sx, sy), 2.0, sparkPaint);
        }
      }
    }

    // 2. UFO Metallic Glass Dome
    final domePaint = Paint()..color = Colors.cyanAccent.shade100.withOpacity(0.85);
    canvas.drawArc(
      Rect.fromCenter(center: Offset(ufoCenter.dx, ufoCenter.dy - 4), width: 36, height: 28),
      math.pi,
      math.pi,
      true,
      domePaint,
    );

    // 3. Metallic Saucer Disc Body
    final bodyPaint = Paint()..color = Colors.grey.shade400;
    canvas.drawOval(Rect.fromCenter(center: ufoCenter, width: 80, height: 20), bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(ufoCenter.dx, ufoCenter.dy + 2), width: 80, height: 14), Paint()..color = Colors.grey.shade700);

    // 4. Pulsing Colored LED Lights around Saucer Rim
    final ledColors = [Colors.redAccent, Colors.yellowAccent, Colors.greenAccent, Colors.cyanAccent, Colors.pinkAccent];
    for (int i = 0; i < 5; i++) {
      double lx = ufoCenter.dx - 28 + i * 14;
      double ly = ufoCenter.dy + 2;

      Color c = isRunning ? ledColors[(i + (animationValue * 5).floor()) % ledColors.length] : ledColors[i];
      canvas.drawCircle(Offset(lx, ly), 3, Paint()..color = c);
    }

    canvas.restore();
  }

  void _paintWindmill(Canvas canvas, Size size, Offset center) {
    final circleClip = Path()
      ..addOval(Rect.fromCenter(center: center, width: size.width, height: size.height));
    canvas.save();
    canvas.clipPath(circleClip);

    // 1. Green Hill Mound at bottom
    final hillPaint = Paint()..color = color.withOpacity(0.5);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 55), width: 140, height: 35),
      hillPaint,
    );

    // 2. Windmill Tower
    final towerTopY = center.dy - 25;
    final towerBotY = center.dy + 50;

    final towerPath = Path()
      ..moveTo(center.dx - 18, towerTopY)
      ..lineTo(center.dx + 18, towerTopY)
      ..lineTo(center.dx + 28, towerBotY)
      ..lineTo(center.dx - 28, towerBotY)
      ..close();
    canvas.drawPath(towerPath, Paint()..color = Colors.brown.shade700);

    // Roof Cone
    final roofPath = Path()
      ..moveTo(center.dx - 22, towerTopY)
      ..lineTo(center.dx + 22, towerTopY)
      ..lineTo(center.dx, towerTopY - 20)
      ..close();
    canvas.drawPath(roofPath, Paint()..color = Colors.deepOrange.shade800);

    // Door & Window
    canvas.drawRect(Rect.fromCenter(center: Offset(center.dx, towerBotY - 12), width: 10, height: 16), Paint()..color = Colors.brown.shade900);
    canvas.drawCircle(Offset(center.dx, towerTopY + 15), 5, Paint()..color = Colors.amber.shade200);

    // 3. Rotating Blades (Vanes)
    canvas.save();
    canvas.translate(center.dx, towerTopY);

    if (isRunning) {
      canvas.rotate(animationValue * math.pi * 2);
    }

    final bladePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    final bladeFramePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 4; i++) {
      canvas.save();
      canvas.rotate(i * (math.pi / 2));

      final bPath = Path()
        ..moveTo(0, 0)
        ..lineTo(6, -8)
        ..lineTo(10, -50)
        ..lineTo(0, -50)
        ..close();

      canvas.drawPath(bPath, bladePaint);
      canvas.drawPath(bPath, bladeFramePaint);

      canvas.restore();
    }

    // Center Hub
    canvas.drawCircle(Offset.zero, 6, Paint()..color = color);

    canvas.restore();

    // 4. Smooth Wind Gust Streams & Floating Leaves (Replaced lollipops)
    if (isRunning) {
      final windPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;

      final leafPaint = Paint()..color = Colors.lightGreenAccent.withOpacity(0.8);

      for (int i = 0; i < 3; i++) {
        double p = (animationValue + i * 0.33) % 1.0;
        double wx = center.dx - 70 + p * 140;
        double wy = center.dy - 60 + i * 28 + math.sin(p * math.pi * 2) * 8;
        double alpha = (1 - (p - 0.5).abs() * 2).clamp(0.0, 0.6);

        windPaint.color = Colors.white.withOpacity(alpha);

        final windPath = Path()
          ..moveTo(wx - 25, wy)
          ..quadraticBezierTo(wx, wy - 8, wx + 25, wy);
        canvas.drawPath(windPath, windPaint);

        // Floating leaf along wind
        canvas.drawOval(
          Rect.fromCenter(center: Offset(wx + 15, wy - 4), width: 6, height: 3),
          leafPaint,
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ThemePainter oldDelegate) {
    return oldDelegate.theme != theme ||
        oldDelegate.progress != progress ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.isRunning != isRunning ||
        oldDelegate.color != color;
  }
}
