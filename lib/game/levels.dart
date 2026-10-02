import 'game_config.dart';
import 'puzzle_engine.dart';

/// A single authored route: an orthogonal chain of grid points. The first point
/// is the cart, the last is the barn, everything between becomes a turnable
/// sign. Rotations are derived from the geometry, so a scheme can never be
/// authored into an unsolvable state.
class RoutePath {
  const RoutePath(this.route, this.points);

  final RouteColorId route;
  final List<List<int>> points;
}

class LevelCatalog {
  const LevelCatalog._();

  static const Map<SchemeId, List<RoutePath>> _paths =
      <SchemeId, List<RoutePath>>{
    SchemeId.easy: <RoutePath>[
      RoutePath(RouteColorId.gold, <List<int>>[
        <int>[0, 0],
        <int>[1, 0],
        <int>[1, 1],
        <int>[2, 1],
        <int>[3, 1],
      ]),
      RoutePath(RouteColorId.cyan, <List<int>>[
        <int>[0, 2],
        <int>[1, 2],
        <int>[2, 2],
        <int>[2, 3],
        <int>[2, 4],
      ]),
      RoutePath(RouteColorId.green, <List<int>>[
        <int>[4, 4],
        <int>[3, 4],
        <int>[3, 3],
        <int>[4, 3],
        <int>[4, 2],
      ]),
    ],
    SchemeId.farm: <RoutePath>[
      RoutePath(RouteColorId.gold, <List<int>>[
        <int>[0, 0],
        <int>[1, 0],
        <int>[2, 0],
        <int>[2, 1],
        <int>[3, 1],
        <int>[4, 1],
      ]),
      RoutePath(RouteColorId.cyan, <List<int>>[
        <int>[0, 2],
        <int>[1, 2],
        <int>[1, 3],
        <int>[2, 3],
        <int>[3, 3],
        <int>[4, 3],
      ]),
      RoutePath(RouteColorId.green, <List<int>>[
        <int>[0, 5],
        <int>[1, 5],
        <int>[2, 5],
        <int>[3, 5],
        <int>[3, 4],
        <int>[4, 4],
      ]),
    ],
    SchemeId.hard: <RoutePath>[
      RoutePath(RouteColorId.gold, <List<int>>[
        <int>[0, 0],
        <int>[1, 0],
        <int>[2, 0],
        <int>[3, 0],
        <int>[3, 1],
        <int>[4, 1],
        <int>[5, 1],
      ]),
      RoutePath(RouteColorId.cyan, <List<int>>[
        <int>[0, 3],
        <int>[1, 3],
        <int>[1, 2],
        <int>[2, 2],
        <int>[3, 2],
        <int>[4, 2],
        <int>[5, 2],
      ]),
      RoutePath(RouteColorId.green, <List<int>>[
        <int>[0, 6],
        <int>[1, 6],
        <int>[2, 6],
        <int>[2, 5],
        <int>[3, 5],
        <int>[4, 5],
        <int>[5, 5],
      ]),
    ],
  };

  static List<RoutePath> pathsFor(SchemeId id) => _paths[id]!;

  /// Builds the solved board, then returns it. Scrambling is the engine's job.
  static List<Cell> buildSolvedCells(SchemeDef scheme) {
    final List<Cell> cells = List<Cell>.generate(
      scheme.cols * scheme.rows,
      (int _) => Cell.empty(),
      growable: false,
    );

    for (final RoutePath path in pathsFor(scheme.id)) {
      final List<List<int>> pts = path.points;
      for (int i = 0; i < pts.length; i++) {
        final int idx = pts[i][1] * scheme.cols + pts[i][0];
        if (i == 0) {
          cells[idx] = Cell(
            kind: CellKind.cart,
            shape: SignShape.straight,
            route: path.route,
            solutionRot: _dirBetween(pts[i], pts[i + 1]),
          );
        } else if (i == pts.length - 1) {
          cells[idx] = Cell(
            kind: CellKind.barn,
            shape: SignShape.straight,
            route: path.route,
            solutionRot: _dirBetween(pts[i], pts[i - 1]),
          );
        } else {
          final int dIn = _dirBetween(pts[i], pts[i - 1]);
          final int dOut = _dirBetween(pts[i], pts[i + 1]);
          final bool straight = (dIn + 2) % 4 == dOut;
          cells[idx] = Cell(
            kind: CellKind.sign,
            shape: straight ? SignShape.straight : SignShape.corner,
            route: path.route,
            solutionRot:
                straight ? _straightRot(dIn) : _cornerRot(dIn, dOut),
          );
        }
      }
    }
    return cells;
  }

  /// 0 = up, 1 = right, 2 = down, 3 = left.
  static int _dirBetween(List<int> from, List<int> to) {
    if (to[0] > from[0]) {
      return 1;
    }
    if (to[0] < from[0]) {
      return 3;
    }
    if (to[1] > from[1]) {
      return 2;
    }
    return 0;
  }

  /// Straight base geometry (rot 0) links left-right.
  static int _straightRot(int dir) => dir.isOdd ? 0 : 1;

  /// Corner base geometry (rot 0) links right-down.
  static int _cornerRot(int dIn, int dOut) {
    for (int r = 0; r < 4; r++) {
      final int a = (1 + r) % 4;
      final int b = (2 + r) % 4;
      if ((a == dIn && b == dOut) || (a == dOut && b == dIn)) {
        return r;
      }
    }
    return 0;
  }
}
