import 'package:flutter/material.dart';

import '../game/puzzle_engine.dart';
import '../theme.dart';
import 'route_tile.dart';

/// Board frame = inner padding (6) + hard border (3). The tile size is derived
/// from the frame so the grid can never overflow its container.
const double kBoardPad = 6;
const double kBoardBorder = 3;
const double kBoardFrame = kBoardPad + kBoardBorder;

/// Largest tile that fits both the available width and height.
double boardTileSize({
  required double maxWidth,
  required double maxHeight,
  required int cols,
  required int rows,
}) {
  final double byWidth = (maxWidth - 2 * kBoardFrame) / cols;
  final double byHeight = (maxHeight - 2 * kBoardFrame) / rows;
  final double tile = byWidth < byHeight ? byWidth : byHeight;
  final double floored = tile.floorToDouble();
  return floored < 18 ? 18 : floored;
}

class RouteBoard extends StatelessWidget {
  const RouteBoard({
    super.key,
    required this.engine,
    required this.tile,
    this.onTapCell,
    this.dimmed = false,
    this.borderColor = AppColors.textPrimary,
    this.showSprites = true,
  });

  final PuzzleEngine engine;
  final double tile;
  final void Function(int index)? onTapCell;
  final bool dimmed;
  final Color borderColor;
  final bool showSprites;

  double get boardWidth => tile * engine.cols + 2 * kBoardFrame;

  double get boardHeight => tile * engine.rows + 2 * kBoardFrame;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: boardWidth,
      height: boardHeight,
      padding: const EdgeInsets.all(kBoardPad),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: kBoardBorder),
        boxShadow: hardShadow(dx: 8, dy: 8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.generate(engine.rows, (int row) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List<Widget>.generate(engine.cols, (int col) {
              final int index = row * engine.cols + col;
              final Cell cell = engine.cells[index];
              final Widget child = RouteTile(
                cell: cell,
                size: tile,
                dimmed: dimmed,
                showSprites: showSprites,
              );
              if (onTapCell == null) {
                return child;
              }
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTapCell!(index),
                child: child,
              );
            }),
          );
        }),
      ),
    );
  }
}
