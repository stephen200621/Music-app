import 'dart:math';
import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';

class VinylDisc extends StatefulWidget {
  final double size;
  final bool isPlaying;
  final bool reducedMotion;

  const VinylDisc({
    Key? key,
    this.size = 250,
    required this.isPlaying,
    this.reducedMotion = false,
  }) : super(key: key);

  @override
  State<VinylDisc> createState() => _VinylDiscState();
}

class _VinylDiscState extends State<VinylDisc> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    if (widget.isPlaying && !widget.reducedMotion) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant VinylDisc oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reducedMotion != oldWidget.reducedMotion ||
        widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying && !widget.reducedMotion) {
        if (!_rotationController.isAnimating) {
          _rotationController.repeat();
        }
      } else {
        _rotationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationController.value * 2 * pi,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _VinylPainter(),
            ),
          ),
        );
      },
    );
  }
}

class _VinylPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Disc Base (Deep Matte Obsidian Vinyl)
    final basePaint = Paint()
      ..color = const Color(0xFF0D0D11)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, basePaint);

    // Subtle Outer Rim
    final rimPaint = Paint()
      ..color = const Color(0xFF222430)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius - 2, rimPaint);

    // Concentric Sound Grooves
    final groovePaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (double r = radius * 0.42; r < radius * 0.94; r += 7.0) {
      canvas.drawCircle(center, r, groovePaint);
    }

    // Light sheen reflection (Anisotropic highlight sheen across vinyl)
    final sheenPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.09),
          Colors.transparent,
          Colors.white.withOpacity(0.09),
          Colors.transparent,
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, sheenPaint);

    // Center Vinyl Label
    final labelRadius = radius * 0.35;
    final labelPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          AppColors.primaryAccent,
          AppColors.secondaryBackground,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: labelRadius));
    canvas.drawCircle(center, labelRadius, labelPaint);

    // Center Spindle Hole
    final spindlePaint = Paint()..color = AppColors.mainBackground;
    canvas.drawCircle(center, 9, spindlePaint);

    final spindleBorder = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, 9, spindleBorder);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
