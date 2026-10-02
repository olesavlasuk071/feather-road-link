import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../game/puzzle_engine.dart';
import '../theme.dart';

/// A single board cell: the turnable sign segment, or a cart / barn terminal
/// with its AI-rendered sprite.
class RouteTile extends StatelessWidget {
  const RouteTile({
    super.key,
    required this.cell,
    required this.size,
    this.dimmed = false,
    this.showSprites = true,
  });

  final Cell cell;
  final double size;
  final bool dimmed;
  final bool showSprites;

  Color get _segmentColor {
    if (dimmed) {
      return AppColors.textMuted;
    }
    if (cell.isSign && !cell.aligned) {
      return AppColors.textMuted;
    }
    return cell.route?.color ?? AppColors.textMuted;
  }

  static String _terminalAsset(Cell cell) {
    final RouteColorId route = cell.route ?? RouteColorId.gold;
    if (cell.kind == CellKind.cart) {
      switch (route) {
        case RouteColorId.gold:
          return AppAssets.cartGold;
        case RouteColorId.cyan:
          return AppAssets.cartCyan;
        case RouteColorId.green:
          return AppAssets.cartGreen;
      }
    }
    switch (route) {
      case RouteColorId.gold:
        return AppAssets.barnGold;
      case RouteColorId.cyan:
        return AppAssets.barnCyan;
      case RouteColorId.green:
        return AppAssets.barnGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool glow = !dimmed && cell.isSign && cell.aligned;

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cell.kind == CellKind.empty
              ? AppColors.surface
              : AppColors.surfaceAlt,
          border: Border.all(color: AppColors.bgBase, width: 1),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (cell.isSign)
              AnimatedRotation(
                turns: cell.rot / 4,
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutBack,
                child: CustomPaint(
                  painter: _SegmentPainter(
                    shape: cell.shape,
                    color: _segmentColor,
                    glow: glow,
                    thickness: size * 0.22,
                  ),
                ),
              ),
            if (cell.isTerminal)
              CustomPaint(
                painter: _StubPainter(
                  dir: cell.solutionRot,
                  color: dimmed
                      ? AppColors.textMuted
                      : (cell.route?.color ?? AppColors.textMuted),
                  thickness: size * 0.22,
                ),
              ),
            if (cell.isTerminal && showSprites)
              Center(
                child: Image.asset(
                  _terminalAsset(cell),
                  width: size * 0.72,
                  height: size * 0.72,
                  fit: BoxFit.contain,
                  errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
                    return Icon(
                      cell.kind == CellKind.cart
                          ? Icons.local_shipping_rounded
                          : Icons.home_work_rounded,
                      size: size * 0.52,
                      color: cell.route?.color ?? AppColors.textPrimary,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SegmentPainter extends CustomPainter {
  const _SegmentPainter({
    required this.shape,
    required this.color,
    required this.glow,
    required this.thickness,
  });

  final SignShape shape;
  final Color color;
  final bool glow;
  final double thickness;

  Path _buildPath(Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final Path path = Path();
    if (shape == SignShape.straight) {
      path.moveTo(0, cy);
      path.lineTo(size.width, cy);
    } else {
      path.moveTo(size.width, cy);
      path.lineTo(cx, cy);
      path.lineTo(cx, size.height);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = _buildPath(size);
    if (glow) {
      final Paint halo = Paint()
        ..color = color.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness + 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, halo);
    }
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _SegmentPainter oldDelegate) {
    return oldDelegate.shape != shape ||
        oldDelegate.color != color ||
        oldDelegate.glow != glow ||
        oldDelegate.thickness != thickness;
  }
}

/// The short connector that leaves a cart / barn toward its neighbour.
class _StubPainter extends CustomPainter {
  const _StubPainter({
    required this.dir,
    required this.color,
    required this.thickness,
  });

  final int dir;
  final Color color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    late final Offset end;
    switch (dir % 4) {
      case 0:
        end = Offset(cx, 0);
        break;
      case 1:
        end = Offset(size.width, cy);
        break;
      case 2:
        end = Offset(cx, size.height);
        break;
      default:
        end = Offset(0, cy);
        break;
    }
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy), end, stroke);
  }

  @override
  bool shouldRepaint(covariant _StubPainter oldDelegate) {
    return oldDelegate.dir != dir ||
        oldDelegate.color != color ||
        oldDelegate.thickness != thickness;
  }
}
