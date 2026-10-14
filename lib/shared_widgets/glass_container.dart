import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final double? width;
  final double? height;

  const GlassContainer({
    Key? key,
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.border,
    this.boxShadow,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.elevatedSurface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ??
            Border.all(
              color: AppColors.glassBorder,
              width: 1.0,
            ),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              )
            ],
      ),
      child: child,
    );
  }
}
