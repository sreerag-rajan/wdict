import 'package:flutter/material.dart';
import '../theme/app_decorations.dart';
import '../theme/app_colors.dart';

class SketchyButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;

  const SketchyButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.paperWhite,
        foregroundColor: AppColors.charcoal,
        elevation: 0,
        padding: padding,
        shape: const SketchyBorder(),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
