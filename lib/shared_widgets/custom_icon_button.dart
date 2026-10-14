import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app/theme/app_colors.dart';

class CustomIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color? color;
  final Color? iconColor;
  final bool hasGlow;
  final List<BoxShadow>? glowShadow;
  final String? tooltip;

  const CustomIconButton({
    Key? key,
    required this.icon,
    this.onTap,
    this.size = 48,
    this.iconSize = 24,
    this.color,
    this.iconColor,
    this.hasGlow = false,
    this.glowShadow,
    this.tooltip,
  }) : super(key: key);

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Widget button = GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color ?? Colors.transparent,
                boxShadow: widget.hasGlow
                    ? (widget.glowShadow ?? AppColors.primaryGlow)
                    : null,
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  size: widget.iconSize,
                  color: widget.iconColor ?? AppColors.mainText,
                ),
              ),
            ),
          );
        },
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}
