import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';

class PerspectiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const PerspectiveCard({
    Key? key,
    required this.child,
    this.onTap,
    this.borderRadius = 20,
    this.padding,
    this.backgroundColor,
    this.gradient,
    this.border,
    this.boxShadow,
  }) : super(key: key);

  @override
  State<PerspectiveCard> createState() => _PerspectiveCardState();
}

class _PerspectiveCardState extends State<PerspectiveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: widget.padding ?? const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? AppColors.elevatedSurface,
                gradient: widget.gradient,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: widget.border ??
                    Border.all(
                      color: _isPressed
                          ? AppColors.primaryAccent.withOpacity(0.5)
                          : AppColors.glassBorder,
                      width: 1,
                    ),
                boxShadow: widget.boxShadow ??
                    (_isPressed
                        ? [
                            BoxShadow(
                              color: AppColors.primaryAccent.withOpacity(0.2),
                              blurRadius: 16,
                              spreadRadius: 1,
                            )
                          ]
                        : null),
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
