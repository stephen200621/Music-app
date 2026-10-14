import 'dart:math';
import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../data/models/song.dart';

class FloatingAlbumArt extends StatefulWidget {
  final Song? song;
  final double size;
  final bool isPlaying;
  final bool reducedMotion;

  const FloatingAlbumArt({
    Key? key,
    required this.song,
    this.size = 280,
    this.isPlaying = false,
    this.reducedMotion = false,
  }) : super(key: key);

  @override
  State<FloatingAlbumArt> createState() => _FloatingAlbumArtState();
}

class _FloatingAlbumArtState extends State<FloatingAlbumArt>
    with SingleTickerProviderStateMixin {
  late AnimationController _idleFloatController;

  // Interactive touch tilt angles
  double _tiltX = 0.0;
  double _tiltY = 0.0;

  @override
  void initState() {
    super.initState();
    _idleFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );

    if (!widget.reducedMotion) {
      _idleFloatController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant FloatingAlbumArt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reducedMotion != oldWidget.reducedMotion) {
      if (widget.reducedMotion) {
        _idleFloatController.stop();
      } else {
        _idleFloatController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _idleFloatController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (widget.reducedMotion) return;
    setState(() {
      // Invert & scale drag offsets for realistic 3D perspective rotation
      _tiltY = (_tiltY + details.delta.dx * 0.005).clamp(-0.35, 0.35);
      _tiltX = (_tiltX - details.delta.dy * 0.005).clamp(-0.35, 0.35);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _tiltX = 0.0;
      _tiltY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: _idleFloatController,
        builder: (context, child) {
          final floatOffset = widget.reducedMotion
              ? 0.0
              : sin(_idleFloatController.value * pi) * 8.0;

          // Perspective transformation matrix
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.0015) // Perspective projection factor
            ..rotateX(_tiltX)
            ..rotateY(_tiltY);

          return Transform.translate(
            offset: Offset(0, floatOffset),
            child: Transform(
              transform: transform,
              alignment: FractionalOffset.center,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: AppColors.card3dShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Base Artwork or Procedural Fallback
                      _buildArtworkImage(),

                      // Glass Glint Top-Down Gradient Highlight
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.25),
                              Colors.white.withOpacity(0.0),
                              Colors.black.withOpacity(0.4),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),

                      // Glass Border
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: AppColors.glassBorder.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArtworkImage() {
    final artworkUri = widget.song?.artworkUri;
    if (artworkUri != null && artworkUri.startsWith('http')) {
      return Image.network(
        artworkUri,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildProceduralFallback(),
      );
    }
    return _buildProceduralFallback();
  }

  Widget _buildProceduralFallback() {
    final title = widget.song?.title ?? 'VYBE';
    final artist = widget.song?.artist ?? 'AI Music';
    final initial = title.isNotEmpty ? title[0].toUpperCase() : 'V';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2E1065),
            Color(0xFF0F172A),
            Color(0xFF1E1B4B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: AppColors.primaryGlow,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mainText,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                artist,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
