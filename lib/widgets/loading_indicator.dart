import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SketchyLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;

  const SketchyLoadingIndicator({
    super.key,
    this.message = 'Loading...',
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              strokeWidth: 3.0,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.sketchBrown),
              backgroundColor: AppColors.paperOffWhite,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                color: AppColors.graphite,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
