import 'package:flutter_test/flutter_test.dart';

import 'package:feather_road_link/game/game_config.dart';
import 'package:feather_road_link/game/levels.dart';
import 'package:feather_road_link/game/puzzle_engine.dart';

/// Counts the taps a player needs to bring every scrambled sign back to its
/// solution rotation (one tap = +90 degrees).
int tapsToSolve(PuzzleEngine engine) {
  int taps = 0;
  for (final Cell cell in engine.cells) {
    if (!cell.isSign || cell.aligned) {
      continue;
    }
    if (cell.shape == SignShape.straight) {
      taps += 1;
    } else {
      taps += (cell.solutionRot - cell.rot + 4) % 4;
    }
  }
  return taps;
}

void main() {
  for (final SchemeDef scheme in GameConfig.schemes) {
    group('${scheme.label} ${scheme.sizeLabel}', () {
      test('authored board is solved as built', () {
        final PuzzleEngine solved = PuzzleEngine.solved(scheme: scheme);
        expect(solved.isSolved, isTrue);
        expect(solved.linkedRoutes, 3);
        expect(solved.wrongCount, 0);
      });

      test('every route has a cart and a barn on the grid', () {
        final PuzzleEngine solved = PuzzleEngine.solved(scheme: scheme);
        for (final RouteColorId route in RouteColorId.values) {
          final Iterable<Cell> mine =
              solved.cells.where((Cell c) => c.route == route);
          expect(mine.where((Cell c) => c.kind == CellKind.cart).length, 1);
          expect(mine.where((Cell c) => c.kind == CellKind.barn).length, 1);
        }
      });

      test('authored paths never overlap', () {
        final List<List<int>> occupied = <List<int>>[];
        for (final RoutePath path in LevelCatalog.pathsFor(scheme.id)) {
          occupied.addAll(path.points);
        }
        final Set<String> seen = occupied
            .map((List<int> p) => '${p[0]},${p[1]}')
            .toSet();
        expect(seen.length, occupied.length);
      });

      test('scramble is solvable inside the move budget', () {
        for (int seed = 1; seed <= 12; seed++) {
          final PuzzleEngine engine =
              PuzzleEngine(scheme: scheme, seed: seed);
          expect(engine.isSolved, isFalse, reason: 'seed $seed');
          expect(engine.wrongCount, scheme.scrambleCount, reason: 'seed $seed');
          expect(
            tapsToSolve(engine),
            lessThanOrEqualTo(scheme.moves),
            reason: 'seed $seed needs more taps than the move budget',
          );

          // Rotating each wrong sign to its solution always wins the round.
          int guard = 0;
          while (engine.firstWrongIndex >= 0 && guard < 200) {
            engine.snapToSolution(engine.firstWrongIndex);
            guard++;
          }
          expect(engine.isSolved, isTrue, reason: 'seed $seed');
          expect(guard, scheme.scrambleCount, reason: 'seed $seed');
        }
      });

      test('auto-assist reaches the result inside the idle backstop', () {
        final int assistMs = GameConfig.autoplayIdleMs +
            scheme.scrambleCount * GameConfig.autoplayStepMs +
            GameConfig.autoplayFinishMs;
        expect(assistMs, lessThan(GameConfig.idleFailMs));
      });
    });
  }

  test('loader duration is pinned at 8000ms', () {
    expect(GameConfig.loaderDurationMs, 8000);
  });
}
