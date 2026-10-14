import 'dart:math';
import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';

class AudioVisualizer extends StatefulWidget {
  final bool isPlaying;
  final int barCount;
  final double height;
  final double barWidth;
  final bool reducedMotion;

  const AudioVisualizer({
    Key? key,
    required this.isPlaying,
    this.barCount = 28,
    this.height = 36,
    this.barWidth = 3.0,
    this.reducedMotion = false,
  }) : super(key: key);

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final Random _random = Random(1337);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    if (widget.isPlaying && !widget.reducedMotion) {
      _animController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reducedMotion != oldWidget.reducedMotion ||
        widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying && !widget.reducedMotion) {
        if (!_animController.isAnimating) {
          _animController.repeat(reverse: true);
        }
      } else {
        _animController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return SizedBox(
          height: widget.height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(widget.barCount, (index) {
              // Generate rhythmic height based on sine waves & pseudo randomness
              final progress = _animController.value;
              final phase = (index / widget.barCount) * 2 * pi;
              final baseAmp = sin(phase + progress * pi).abs();

              double heightFactor;
              if (widget.reducedMotion || !widget.isPlaying) {
                heightFactor = 0.15; // idle static bars
              } else {
                heightFactor = (0.2 + (baseAmp * 0.75)).clamp(0.12, 1.0);
              }

              final barHeight = (widget.height * heightFactor).clamp(4.0, widget.height);

              // Color gradient transition across visualizer
              final color = index < widget.barCount / 2
                  ? Color.lerp(
                      AppColors.secondaryAccent,
                      AppColors.primaryAccent,
                      (index / (widget.barCount / 2)),
                    )
                  : Color.lerp(
                      AppColors.primaryAccent,
                      AppColors.highlightAccent,
                      ((index - widget.barCount / 2) / (widget.barCount / 2)),
                    );

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                width: widget.barWidth,
                height: barHeight,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(widget.barWidth / 2),
                  boxShadow: widget.isPlaying && !widget.reducedMotion
                      ? [
                          BoxShadow(
                            color: color!.withOpacity(0.4),
                            blurRadius: 4,
                            spreadRadius: 0.5,
                          )
                        ]
                      : null,
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
