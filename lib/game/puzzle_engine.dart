import 'dart:math';

import 'game_config.dart';
import 'levels.dart';

enum CellKind { empty, cart, barn, sign }

enum SignShape { straight, corner }

class Cell {
  Cell({
    required this.kind,
    required this.shape,
    required this.route,
    required this.solutionRot,
    int? rot,
  }) : rot = rot ?? solutionRot;

  factory Cell.empty() => Cell(
        kind: CellKind.empty,
        shape: SignShape.straight,
        route: null,
        solutionRot: 0,
      );

  final CellKind kind;
  final SignShape shape;
  final RouteColorId? route;

  /// For signs: the rotation that completes the route.
  /// For carts/barns: the direction of the connector stub.
  final int solutionRot;

  int rot;

  bool get isSign => kind == CellKind.sign;

  bool get isTerminal => kind == CellKind.cart || kind == CellKind.barn;

  /// A straight segment reads the same every half turn.
  bool get aligned {
    if (!isSign) {
      return kind != CellKind.empty;
    }
    if (shape == SignShape.straight) {
      return rot % 2 == solutionRot % 2;
    }
    return rot % 4 == solutionRot % 4;
  }
}

enum GameStatus { playing, won, lost }

enum LoseReason { none, outOfMoves, tooManyChecks }

/// Pure board logic — no widgets, no timers.
class PuzzleEngine {
  PuzzleEngine({required this.scheme, int seed = 0})
      : cells = LevelCatalog.buildSolvedCells(scheme) {
    _scramble(seed);
  }

  PuzzleEngine.solved({required this.scheme})
      : cells = LevelCatalog.buildSolvedCells(scheme);

  final SchemeDef scheme;
  final List<Cell> cells;

  int get cols => scheme.cols;

  int get rows => scheme.rows;

  Cell cellAt(int col, int row) => cells[row * cols + col];

  /// Offsets chosen so the total taps needed always stays inside the move
  /// budget: offset 3 -> 1 tap, 2 -> 2 taps, 1 -> 3 taps.
  static const List<int> _offsetCycle = <int>[3, 2, 3, 1, 3, 2, 3, 1, 3];

  void _scramble(int seed) {
    final List<int> signIndexes = <int>[];
    for (int i = 0; i < cells.length; i++) {
      if (cells[i].isSign) {
        signIndexes.add(i);
      }
    }
    signIndexes.shuffle(Random(seed + 7));

    final int count = min(scheme.scrambleCount, signIndexes.length);
    for (int i = 0; i < count; i++) {
      final Cell cell = cells[signIndexes[i]];
      int offset = _offsetCycle[i % _offsetCycle.length];
      if (cell.shape == SignShape.straight && offset.isEven) {
        offset = 1;
      }
      cell.rot = (cell.solutionRot + offset) % 4;
    }
  }

  /// Returns true when the tap actually turned a sign (and therefore costs a
  /// move).
  bool rotate(int index) {
    if (index < 0 || index >= cells.length) {
      return false;
    }
    final Cell cell = cells[index];
    if (!cell.isSign) {
      return false;
    }
    cell.rot = (cell.rot + 1) % 4;
    return true;
  }

  void snapToSolution(int index) {
    if (index < 0 || index >= cells.length) {
      return;
    }
    cells[index].rot = cells[index].solutionRot;
  }

  bool isRouteLinked(RouteColorId route) {
    for (final Cell cell in cells) {
      if (cell.isSign && cell.route == route && !cell.aligned) {
        return false;
      }
    }
    return true;
  }

  int get linkedRoutes {
    int linked = 0;
    for (final RouteColorId route in RouteColorId.values) {
      if (isRouteLinked(route)) {
        linked++;
      }
    }
    return linked;
  }

  bool get isSolved => linkedRoutes == RouteColorId.values.length;

  /// Index of a sign that is still turned the wrong way, or -1.
  int get firstWrongIndex {
    for (int i = 0; i < cells.length; i++) {
      if (cells[i].isSign && !cells[i].aligned) {
        return i;
      }
    }
    return -1;
  }

  int get wrongCount {
    int n = 0;
    for (final Cell cell in cells) {
      if (cell.isSign && !cell.aligned) {
        n++;
      }
    }
    return n;
  }
}

/// Outcome handed to the result screen.
class RoundResult {
  const RoundResult({
    required this.won,
    required this.reason,
    required this.scheme,
    required this.movesLeft,
    required this.movesTotal,
    required this.checksLeft,
    required this.stars,
    required this.best,
  });

  final bool won;
  final LoseReason reason;
  final SchemeDef scheme;
  final int movesLeft;
  final int movesTotal;
  final int checksLeft;
  final int stars;
  final int best;

  String get headline {
    if (won) {
      return 'ROUTES LINKED!';
    }
    if (reason == LoseReason.tooManyChecks) {
      return 'TOO MANY CHECKS';
    }
    return 'OUT OF MOVES';
  }
}
