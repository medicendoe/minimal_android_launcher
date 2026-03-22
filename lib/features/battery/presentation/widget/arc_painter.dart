import 'dart:math';
import 'package:flutter/material.dart';

/// A [CustomPainter] that draws a circular arc representing a percentage value.
///
/// The arc starts at the top (12 o'clock position) and sweeps clockwise.
/// Only the foreground arc is drawn; no background track is painted.
class ArcPainter extends CustomPainter {
  /// Value from 0 to 100 representing how much of the circle to fill.
  final int percentage;

  /// Color of the arc stroke.
  final Color foregroundColor;

  /// Width of the arc stroke in logical pixels.
  final double strokeWidth;

  const ArcPainter({
    required this.percentage,
    required this.foregroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    // Shrink the radius by half the stroke width so the arc fits within bounds.
    final radius = min(size.width / 2, size.height / 2) - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    paint.color = foregroundColor;
    // Sweep angle proportional to [percentage]; -π/2 places the start at 12 o'clock.
    final sweepAngle = 2 * pi * (percentage / 100);
    canvas.drawArc(rect, -pi / 2, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant ArcPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.foregroundColor != foregroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
