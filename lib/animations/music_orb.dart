import 'dart:math';
import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';

class MusicOrb extends StatefulWidget {
  final double size;
  final bool isPlaying;
  final VoidCallback? onTap;
  final bool reducedMotion;

  const MusicOrb({
    Key? key,
    this.size = 220,
    this.isPlaying = false,
    this.onTap,
    this.reducedMotion = false,
  }) : super(key: key);

  @override
  State<MusicOrb> createState() => _MusicOrbState();
}

class _MusicOrbState extends State<MusicOrb> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    if (!widget.reducedMotion) {
      _rotationController.repeat();
      _pulseController.repeat(reverse: true);
      _floatController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant MusicOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reducedMotion != oldWidget.reducedMotion) {
      if (widget.reducedMotion) {
        _rotationController.stop();
        _pulseController.stop();
        _floatController.stop();
      } else {
        _rotationController.repeat();
        _pulseController.repeat(reverse: true);
        _floatController.repeat(reverse: true);
      }
    }

    if (widget.isPlaying != oldWidget.isPlaying && !widget.reducedMotion) {
      if (widget.isPlaying) {
        _pulseController.duration = const Duration(milliseconds: 1400);
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.duration = const Duration(milliseconds: 2800);
        _pulseController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final floatY = widget.reducedMotion ? 0.0 : sin(_floatController.value * pi) * 6;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotationController, _pulseController, _floatController]),
        builder: (context, child) {
          final pulse = widget.reducedMotion ? 1.0 : 1.0 + (_pulseController.value * 0.06);

          return Transform.translate(
            offset: Offset(0, floatY),
            child: Transform.scale(
              scale: pulse,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: CustomPaint(
                  painter: _OrbPainter(
                    angle: _rotationController.value * 2 * pi,
                    isPlaying: widget.isPlaying,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double angle;
  final bool isPlaying;

  _OrbPainter({required this.angle, required this.isPlaying});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;

    // Outer Ambient Glow
    final outerGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primaryAccent.withOpacity(isPlaying ? 0.45 : 0.25),
          AppColors.secondaryAccent.withOpacity(isPlaying ? 0.30 : 0.15),
          Colors.transparent,
        ],
        stops: const [0.2, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.6));
    canvas.drawCircle(center, radius * 1.5, outerGlowPaint);

    // Rotating Orbital Harmonic Rings
    _drawHarmonicRing(canvas, center, radius * 1.25, angle, AppColors.secondaryAccent.withOpacity(0.4));
    _drawHarmonicRing(canvas, center, radius * 1.15, -angle * 1.4, AppColors.highlightAccent.withOpacity(0.35));
    _drawHarmonicRing(canvas, center, radius * 1.05, angle * 0.8, AppColors.primaryAccent.withOpacity(0.5));

    // Core Spherical 3D Orb Body with Layered Gradients
    final coreGradient = RadialGradient(
      center: const Alignment(-0.35, -0.4),
      radius: 0.95,
      colors: const [
        Color(0xFFE2F4FF), // Specular light highlight
        AppColors.secondaryAccent,
        AppColors.primaryAccent,
        Color(0xFF2C0A5E),
        Color(0xFF090A1E),
      ],
      stops: const [0.0, 0.28, 0.58, 0.85, 1.0],
    );

    final corePaint = Paint()
      ..shader = coreGradient.createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, corePaint);

    // Inner Specular Light Glint
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.85),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(center.dx - radius * 0.32, center.dy - radius * 0.35),
        radius: radius * 0.38,
      ));
    canvas.drawCircle(
      Offset(center.dx - radius * 0.32, center.dy - radius * 0.35),
      radius * 0.35,
      highlightPaint,
    );

    // Floating micro-particles around the orb
    final random = Random(42);
    final particlePaint = Paint()..color = Colors.white.withOpacity(0.6);
    for (int i = 0; i < 14; i++) {
      final pAngle = (i / 14) * 2 * pi + (angle * (i % 2 == 0 ? 0.5 : -0.5));
      final pDist = radius * (1.1 + (random.nextDouble() * 0.35));
      final px = center.dx + cos(pAngle) * pDist;
      final py = center.dy + sin(pAngle) * pDist;
      final pSize = 1.0 + (i % 3) * 0.8;
      canvas.drawCircle(Offset(px, py), pSize, particlePaint);
    }
  }

  void _drawHarmonicRing(Canvas canvas, Offset center, double radius, double rot, Color color) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rot);

    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    // Draw elliptical 3D perspective ring
    final rect = Rect.fromCenter(center: Offset.zero, width: radius * 2, height: radius * 0.7);
    canvas.drawOval(rect, ringPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) =>
      oldDelegate.angle != angle || oldDelegate.isPlaying != isPlaying;
}
