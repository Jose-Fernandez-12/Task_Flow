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
    }
  }

  void _paintTree(Canvas canvas, Size size, Offset center) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Soil ground
    final groundPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 60), width: 120, height: 20),
      groundPaint,
    );

    // Tree trunk grows with progress
    final trunkHeight = 30.0 + progress * 50;
    final trunkWidth = 10.0 + progress * 8;

    final trunkPath = Path()
      ..moveTo(center.dx - trunkWidth / 2, center.dy + 60)
      ..lineTo(center.dx + trunkWidth / 2, center.dy + 60)
      ..lineTo(center.dx + trunkWidth / 3, center.dy + 60 - trunkHeight)
      ..lineTo(center.dx - trunkWidth / 3, center.dy + 60 - trunkHeight)
      ..close();

    final trunkPaint = Paint()
      ..color = Color.lerp(Colors.brown.shade700, color.withOpacity(0.9), 0.5)!
      ..style = PaintingStyle.fill;
    canvas.drawPath(trunkPath, trunkPaint);

    // Foliage grows in stages
    final foliageRadius = 25.0 + progress * 40.0;
    final foliageCenter = Offset(center.dx, center.dy + 60 - trunkHeight - foliageRadius * 0.5);

    final foliagePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(foliageCenter, foliageRadius, foliagePaint);
    canvas.drawCircle(
      foliageCenter.translate(-foliageRadius * 0.5, foliageRadius * 0.2),
      foliageRadius * 0.7,
      Paint()..color = color.withOpacity(0.85),
    );
    canvas.drawCircle(
      foliageCenter.translate(foliageRadius * 0.5, foliageRadius * 0.2),
      foliageRadius * 0.7,
      Paint()..color = color.withOpacity(0.85),
    );

    // Falling / Floating leaves particles if running
    if (isRunning) {
      final rand = math.Random(42);
      final particlePaint = Paint()..color = color.withOpacity(0.8);

      for (int i = 0; i < 8; i++) {
        double offsetProgress = (animationValue + i * 0.125) % 1.0;
        double px = center.dx + math.sin(offsetProgress * math.pi * 2 + i) * (30 + i * 5);
        double py = (center.dy - 30) + offsetProgress * 90;

        canvas.drawOval(
          Rect.fromCenter(center: Offset(px, py), width: 6, height: 10),
          particlePaint,
        );
      }
    }
  }

  void _paintFire(Canvas canvas, Size size, Offset center) {
    // Warm fire glow
    final glowPaint = Paint()
      ..color = Colors.orangeAccent.withOpacity(0.15 + math.sin(animationValue * math.pi * 2) * 0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, 70, glowPaint);

    // Logs at bottom
    final logPaint = Paint()
      ..color = Colors.brown.shade800
      ..strokeWidth = 12
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

    // Flames grow with progress
    final scaleFactor = 0.5 + progress * 0.8;
    final flameHeight = 90.0 * scaleFactor;
    final flameWidth = 70.0 * scaleFactor;

    // Main Outer Flame
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
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
    canvas.drawPath(outerPath, outerPaint);

    // Inner Flame
    final innerPath = Path();
    final innerWave = -wave * 0.8;
    innerPath.moveTo(center.dx - flameWidth * 0.3, center.dy + 40);
    innerPath.quadraticBezierTo(
      center.dx - flameWidth * 0.3 - innerWave,
      center.dy + 40 - flameHeight * 0.4,
      center.dx + innerWave,
      center.dy + 40 - flameHeight * 0.7,
    );
    innerPath.quadraticBezierTo(
      center.dx + flameWidth * 0.3 + innerWave,
      center.dy + 40 - flameHeight * 0.4,
      center.dx + flameWidth * 0.3,
      center.dy + 40,
    );
    innerPath.close();

    final innerPaint = Paint()
      ..color = Colors.yellow
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
    const width = 60.0;
    const height = 110.0;
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

    // 1. Upper Chamber Sand (Decreases with progress)
    final upperFill = (1.0 - progress);
    if (upperFill > 0) {
      final upperSandY = center.dy - (height / 2) * upperFill;
      final upperSandPath = Path()
        ..moveTo(center.dx - width, upperSandY)
        ..lineTo(center.dx + width, upperSandY)
        ..lineTo(center.dx + width, center.dy)
        ..lineTo(center.dx - width, center.dy)
        ..close();
      canvas.drawPath(upperSandPath, sandPaint);
    }

    // 2. Lower Chamber Sand (Increases with progress)
    if (progress > 0) {
      final lowerSandHeight = (height / 2 - 10) * progress;
      final lowerSandY = bottomY - lowerSandHeight;
      final lowerSandPath = Path()
        ..moveTo(center.dx - width, bottomY)
        ..lineTo(center.dx + width, bottomY)
        ..lineTo(center.dx + width, lowerSandY)
        ..quadraticBezierTo(center.dx, lowerSandY - 6, center.dx - width, lowerSandY)
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
      for (int i = 0; i < 5; i++) {
        double p = (animationValue + i * 0.2) % 1.0;
        double py = center.dy + p * (height / 2 - 15);
        double px = center.dx + math.sin(p * math.pi * 4) * 2;
        canvas.drawCircle(Offset(px, py), 1.5, particlePaint);
      }
    }

    canvas.restore();

    // Glass Outline & Caps
    canvas.drawPath(glassPath, glassPaint);

    // Wooden / Metal Caps on Top and Bottom
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, topY - 3), width: width + 16, height: 8),
        const Radius.circular(4),
      ),
      capPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, bottomY + 3), width: width + 16, height: 8),
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
      ..moveTo(center.dx - 14, center.dy - 50)
      ..lineTo(center.dx + 14, center.dy - 50)
      ..lineTo(center.dx + 14, center.dy - 20)
      ..lineTo(center.dx + 48, center.dy + 40)
      ..quadraticBezierTo(center.dx + 52, center.dy + 52, center.dx + 38, center.dy + 52)
      ..lineTo(center.dx - 38, center.dy + 52)
      ..quadraticBezierTo(center.dx - 52, center.dy + 52, center.dx - 48, center.dy + 40)
      ..lineTo(center.dx - 14, center.dy - 20)
      ..close();

    // 1. Draw Liquid Fill inside clip
    canvas.save();
    canvas.clipPath(flaskPath);

    final fillLevel = 42 - progress * 75; // Fill level moves up as progress increases
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
      ..color = color.withOpacity(0.85)
      ..style = PaintingStyle.fill;
    canvas.drawPath(liquidPath, liquidPaint);

    // Bubbles rising if running
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

    // 2. Draw Glass Outline on top for crisp edges
    canvas.drawPath(flaskPath, glassPaint);

    // Flask Lip Rim
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, center.dy - 52), width: 34, height: 6),
        const Radius.circular(3),
      ),
      Paint()
        ..color = Colors.white.withOpacity(0.85)
        ..style = PaintingStyle.fill,
    );
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
