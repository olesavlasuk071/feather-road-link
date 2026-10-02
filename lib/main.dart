import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'game/game_config.dart';
import 'game/puzzle_engine.dart';
import 'screens/game_over_screen.dart';
import 'screens/game_screen.dart';
import 'screens/loader_screen.dart';
import 'screens/menu_screen.dart';
import 'theme.dart';

/// Kept alive for the whole process so the accessibility tree stays populated —
/// the headless capture agent navigates by text node.
SemanticsHandle? semanticsHandle;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  semanticsHandle = SemanticsBinding.instance.ensureSemantics();
  runApp(const FeatherRoadLinkApp());
}

enum Screen { loader, menu, game, gameover }

class FeatherRoadLinkApp extends StatelessWidget {
  const FeatherRoadLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feather Road Link',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  Screen _screen = Screen.loader;
  SchemeId _selected = SchemeId.easy;
  int _stars = 12;
  int _best = 0;
  int _seed = 1;
  bool _tutorialPending = true;
  RoundResult? _result;

  void _goMenu() {
    if (!mounted) {
      return;
    }
    setState(() => _screen = Screen.menu);
  }

  void _startGame(SchemeId scheme) {
    setState(() {
      _selected = scheme;
      _seed++;
      _screen = Screen.game;
    });
  }

  void _onGameOver(RoundResult result) {
    setState(() {
      _result = result;
      _tutorialPending = false;
      _stars += result.stars;
      if (result.won && result.movesLeft > _best) {
        _best = result.movesLeft;
      }
      _screen = Screen.gameover;
    });
  }

  void _handleBack() {
    switch (_screen) {
      case Screen.loader:
        break;
      case Screen.menu:
        break;
      case Screen.game:
      case Screen.gameover:
        _goMenu();
        break;
    }
  }

  Widget _buildScreen() {
    switch (_screen) {
      case Screen.loader:
        return LoaderScreen(key: const ValueKey<String>('loader'), onDone: _goMenu);
      case Screen.menu:
        return MenuScreen(
          key: const ValueKey<String>('menu'),
          selected: _selected,
          stars: _stars,
          onSelectScheme: (SchemeId id) => setState(() => _selected = id),
          onStart: _startGame,
        );
      case Screen.game:
        return GameScreen(
          key: ValueKey<String>('game-$_seed'),
          scheme: GameConfig.schemeOf(_selected),
          seed: _seed,
          best: _best,
          showTutorial: _tutorialPending,
          onExit: _goMenu,
          onGameOver: _onGameOver,
        );
      case Screen.gameover:
        final RoundResult? result = _result;
        if (result == null) {
          return MenuScreen(
            key: const ValueKey<String>('menu-fallback'),
            selected: _selected,
            stars: _stars,
            onSelectScheme: (SchemeId id) => setState(() => _selected = id),
            onStart: _startGame,
          );
        }
        return GameOverScreen(
          key: ValueKey<String>('gameover-$_seed'),
          result: result,
          onPlayAgain: () => _startGame(_selected),
          onPickScheme: _startGame,
          onMenu: _goMenu,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _buildScreen(),
      ),
    );
  }
}
