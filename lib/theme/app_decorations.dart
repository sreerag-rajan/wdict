import 'package:flutter/material.dart';
import 'app_colors.dart';

/// A custom ShapeBorder to mimic hand-drawn, slightly irregular boxes.
class SketchyBorder extends OutlinedBorder {
  final double width;
  final Color color;
  final double radius;

  const SketchyBorder({
    this.width = 2.0,
    this.color = AppColors.charcoal,
    this.radius = 16.0,
    super.side = BorderSide.none,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return _getPath(rect.deflate(width));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _getPath(rect);
  }

  Path _getPath(Rect rect) {
    // Subtle irregularities to create the sketchy feel without being too complex
    final path = Path();

    // Top left slightly varied
    final tlRadius = radius * 1.1;
    // Top right slightly smaller
    final trRadius = radius * 0.9;
    // Bottom right slightly varied
    final brRadius = radius * 1.05;
    // Bottom left slightly smaller
    final blRadius = radius * 0.95;

    // Start at top left, after radius
    path.moveTo(rect.left + tlRadius, rect.top + (rect.height * 0.02));

    // Top edge
    // Slight waviness: curve to the middle top, then to top right
    path.quadraticBezierTo(
      rect.left + rect.width / 2,
      rect.top - (rect.height * 0.01),
      rect.right - trRadius,
      rect.top + (rect.height * 0.01),
    );

    // Top Right Corner
    path.quadraticBezierTo(
      rect.right + (rect.width * 0.01),
      rect.top - (rect.width * 0.01),
      rect.right - (rect.width * 0.01),
      rect.top + trRadius,
    );

    // Right edge
    path.quadraticBezierTo(
      rect.right + (rect.width * 0.02),
      rect.top + rect.height / 2,
      rect.right - (rect.width * 0.01),
      rect.bottom - brRadius,
    );

    // Bottom Right Corner
    path.quadraticBezierTo(
      rect.right + (rect.width * 0.01),
      rect.bottom + (rect.width * 0.01),
      rect.right - brRadius,
      rect.bottom - (rect.height * 0.02),
    );

    // Bottom edge
    path.quadraticBezierTo(
      rect.left + rect.width / 2,
      rect.bottom + (rect.height * 0.01),
      rect.left + blRadius,
      rect.bottom - (rect.height * 0.01),
    );

    // Bottom Left Corner
    path.quadraticBezierTo(
      rect.left - (rect.width * 0.01),
      rect.bottom + (rect.width * 0.01),
      rect.left + (rect.width * 0.01),
      rect.bottom - blRadius,
    );

    // Left edge
    path.quadraticBezierTo(
      rect.left - (rect.width * 0.02),
      rect.top + rect.height / 2,
      rect.left + (rect.width * 0.01),
      rect.top + tlRadius,
    );

    // Top Left Corner
    path.quadraticBezierTo(
      rect.left - (rect.width * 0.01),
      rect.top - (rect.width * 0.01),
      rect.left + tlRadius,
      rect.top + (rect.height * 0.02),
    );

    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final baseRect = rect.deflate(width / 2);
    canvas.drawPath(_getPath(baseRect), paint);
  }

  @override
  OutlinedBorder copyWith({BorderSide? side}) {
    return SketchyBorder(
      width: width,
      color: color,
      radius: radius,
      side: side ?? this.side,
    );
  }

  @override
  OutlinedBorder scale(double t) {
    return SketchyBorder(
      width: width * t,
      radius: radius * t,
      color: color,
      side: side.scale(t),
    );
  }
}

/// Helper methods for decorations
class AppDecorations {
  static BoxDecoration get sketchyBox {
    return const BoxDecoration(color: AppColors.paperWhite);
  }
}
