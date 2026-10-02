import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:feather_road_link/game/game_config.dart';
import 'package:feather_road_link/game/puzzle_engine.dart';
import 'package:feather_road_link/screens/game_over_screen.dart';
import 'package:feather_road_link/screens/game_screen.dart';
import 'package:feather_road_link/screens/menu_screen.dart';
import 'package:feather_road_link/theme.dart';

/// Renders a screen on a 1080x2400 @3x surface — the emulator the pipeline
/// captures on — and fails on any RenderFlex overflow.
Future<void> _pumpOnPhone(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(1080, 2400),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(theme: buildAppTheme(), home: child),
  );
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  testWidgets('MenuScreen lays out without overflow', (WidgetTester t) async {
    await _pumpOnPhone(
      t,
      MenuScreen(
        selected: SchemeId.easy,
        stars: 12,
        onSelectScheme: (SchemeId _) {},
        onStart: (SchemeId _) {},
      ),
    );
    expect(find.text('START ROUTES'), findsOneWidget);
  });

  for (final SchemeDef scheme in GameConfig.schemes) {
    testWidgets('GameScreen ${scheme.label} lays out without overflow',
        (WidgetTester t) async {
      await _pumpOnPhone(
        t,
        GameScreen(
          scheme: scheme,
          seed: 3,
          best: 0,
          showTutorial: false,
          onExit: () {},
          onGameOver: (RoundResult _) {},
        ),
      );
      expect(find.text('CHECK ROUTES'), findsOneWidget);

      // Drain the assist / backstop timers before the tree is torn down.
      await t.pumpWidget(const SizedBox.shrink());
      await t.pump();
    });
  }

  testWidgets('GameScreen with the tutorial overlay fits a short phone',
      (WidgetTester t) async {
    await _pumpOnPhone(
      t,
      GameScreen(
        scheme: GameConfig.schemeOf(SchemeId.hard),
        seed: 5,
        best: 0,
        showTutorial: true,
        onExit: () {},
        onGameOver: (RoundResult _) {},
      ),
      size: const Size(1080, 1920),
    );
    expect(find.text('GOT IT'), findsOneWidget);

    await t.pumpWidget(const SizedBox.shrink());
    await t.pump();
  });

  testWidgets('GameOverScreen lays out without overflow',
      (WidgetTester t) async {
    final SchemeDef scheme = GameConfig.schemeOf(SchemeId.hard);
    await _pumpOnPhone(
      t,
      GameOverScreen(
        result: RoundResult(
          won: true,
          reason: LoseReason.none,
          scheme: scheme,
          movesLeft: 12,
          movesTotal: scheme.moves,
          checksLeft: 3,
          stars: 3,
          best: 12,
        ),
        onPlayAgain: () {},
        onPickScheme: (SchemeId _) {},
        onMenu: () {},
      ),
    );
    expect(find.text('PLAY AGAIN'), findsOneWidget);
    expect(find.text('ROUTES LINKED!'), findsOneWidget);
  });
}
