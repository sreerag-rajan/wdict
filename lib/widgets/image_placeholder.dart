import 'package:flutter/material.dart';
import '../theme/app_decorations.dart';
import '../theme/app_colors.dart';

class SketchyImagePlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final IconData icon;
  final String? label;

  const SketchyImagePlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.icon = Icons.image_outlined,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(color: AppColors.paperOffWhite),
      child: Material(
        color: Colors.transparent,
        shape: const SketchyBorder(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: (width < 60 || height < 60) ? 24 : 48,
                color: AppColors.graphite.withValues(alpha: 0.5),
              ),
              if (label != null) ...[
                const SizedBox(height: 8),
                Text(
                  label!,
                  style: TextStyle(
                    color: AppColors.graphite.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
