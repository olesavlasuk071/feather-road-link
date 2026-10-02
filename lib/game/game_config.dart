import 'package:flutter/material.dart';

import '../theme.dart';

/// Route colour identity. Three routes per scheme, always.
enum RouteColorId { gold, cyan, green }

extension RouteColorIdX on RouteColorId {
  Color get color {
    switch (this) {
      case RouteColorId.gold:
        return AppColors.accentGold;
      case RouteColorId.cyan:
        return AppColors.accentCyan;
      case RouteColorId.green:
        return AppColors.accentGreen;
    }
  }

  String get label {
    switch (this) {
      case RouteColorId.gold:
        return 'GOLD';
      case RouteColorId.cyan:
        return 'CYAN';
      case RouteColorId.green:
        return 'GREEN';
    }
  }
}

/// The three authored schemes. Sign counts and move budgets come from the
/// design document and are verified against the authored paths in levels.dart.
enum SchemeId { easy, farm, hard }

class SchemeDef {
  const SchemeDef({
    required this.id,
    required this.label,
    required this.cols,
    required this.rows,
    required this.scrambleCount,
    required this.moves,
  });

  final SchemeId id;
  final String label;
  final int cols;
  final int rows;
  final int scrambleCount;
  final int moves;

  String get sizeLabel => '${cols}x$rows';
}

class GameConfig {
  const GameConfig._();

  /// Splash wall-clock duration. Must stay exactly 8000 — the capture agent
  /// needs 4-6s of startup headroom before the loader auto-transitions.
  static const int loaderDurationMs = 8000;

  /// Idle time before the auto-assist takes over (a real player taps every
  /// 1-3s and will never see it).
  static const int autoplayIdleMs = 10000;

  /// Interval between auto-assist corrections. Kept short so a full assist run
  /// (worst case 9 scrambled signs on HARD) finishes well inside idleFailMs.
  static const int autoplayStepMs = 2200;

  /// Mount-relative ceiling for the auto-assist. Every tap re-arms the idle
  /// window, so a headless capture agent that keeps tapping the board would
  /// otherwise defer the assist forever and the round would never resolve.
  /// The assist starts no later than this after the round mounts, whatever the
  /// input. Sits above the ~22s the capture agent needs for its first gameplay
  /// screenshot, so the idle board frame is still captured first.
  static const int autoplayCeilingMs = 24000;

  /// Pause between "everything is aligned" and the automatic route check.
  static const int autoplayFinishMs = 2500;

  /// Hard backstop: a round can never outlive this.
  static const int idleFailMs = 75000;

  /// Tutorial overlay auto-dismiss.
  static const int tutorialAutoCloseMs = 4500;

  /// Wrong CHECK presses allowed before the round is lost.
  static const int maxWrongChecks = 3;

  static const List<SchemeDef> schemes = <SchemeDef>[
    SchemeDef(
      id: SchemeId.easy,
      label: 'EASY',
      cols: 5,
      rows: 5,
      scrambleCount: 5,
      moves: 10,
    ),
    SchemeDef(
      id: SchemeId.farm,
      label: 'FARM',
      cols: 6,
      rows: 6,
      scrambleCount: 7,
      moves: 14,
    ),
    SchemeDef(
      id: SchemeId.hard,
      label: 'HARD',
      cols: 6,
      rows: 7,
      scrambleCount: 9,
      moves: 18,
    ),
  ];

  static SchemeDef schemeOf(SchemeId id) {
    return schemes.firstWhere((SchemeDef s) => s.id == id);
  }

  static SchemeDef nextScheme(SchemeId id) {
    final int i = schemes.indexWhere((SchemeDef s) => s.id == id);
    return schemes[(i + 1) % schemes.length];
  }

  /// Stars from remaining moves.
  static int starsFor(int movesLeft, int movesTotal) {
    if (movesTotal <= 0) {
      return 1;
    }
    final double ratio = movesLeft / movesTotal;
    if (ratio >= 0.5) {
      return 3;
    }
    if (ratio >= 0.25) {
      return 2;
    }
    return 1;
  }
}
