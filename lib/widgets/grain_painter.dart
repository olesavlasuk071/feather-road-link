import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Deterministic full-canvas film grain.
///
/// Only the loader opts in (`points: 45000`); every other screen keeps the
/// default of zero so nothing else pays the rasterisation cost. The grain
/// colour must differ from the gradient underneath it — matching colours
/// compress away to nothing.
class GrainPainter extends CustomPainter {
  const GrainPainter({
    this.points = 0,
    this.color = AppColors.textPrimary,
    this.opacity = 0.11,
    this.strokeWidth = 1.5,
    this.seed = 7,
  });

  final int points;
  final Color color;
  final double opacity;
  final double strokeWidth;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    if (points <= 0 || size.isEmpty) {
      return;
    }
    final Random random = Random(seed);
    final Float32List coords = Float32List(points * 2);
    for (int i = 0; i < points; i++) {
      coords[i * 2] = random.nextDouble() * size.width;
      coords[i * 2 + 1] = random.nextDouble() * size.height;
    }
    final Paint paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawRawPoints(PointMode.points, coords, paint);
  }

  @override
  bool shouldRepaint(covariant GrainPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.color != color ||
        oldDelegate.opacity != opacity ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.seed != seed;
  }
}
