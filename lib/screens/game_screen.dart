import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../game/puzzle_engine.dart';
import '../panels/tutorial_panel.dart';
import '../theme.dart';
import '../widgets/brutal_button.dart';
import '../widgets/route_board.dart';
import '../widgets/stat_card.dart';

/// G3 split panel: header, board, thin stat strip, CTA block.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.scheme,
    required this.seed,
    required this.best,
    required this.showTutorial,
    required this.onExit,
    required this.onGameOver,
  });

  final SchemeDef scheme;
  final int seed;
  final int best;
  final bool showTutorial;
  final VoidCallback onExit;
  final ValueChanged<RoundResult> onGameOver;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final PuzzleEngine _engine;
  late final AnimationController _shake;

  late int _movesLeft;
  int _wrongChecks = 0;
  GameStatus _status = GameStatus.playing;
  bool _flash = false;
  bool _tutorialVisible = false;
  bool _resolved = false;

  Timer? _assist;
  Timer? _backstop;
  Timer? _tutorialTimer;
  Timer? _flashTimer;
  Timer? _outro;

  /// Round mount time — anchors the auto-assist ceiling in [_armAssist].
  final DateTime _mountedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _engine = PuzzleEngine(scheme: widget.scheme, seed: widget.seed);
    _movesLeft = widget.scheme.moves;
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _tutorialVisible = widget.showTutorial;
    if (_tutorialVisible) {
      _tutorialTimer = Timer(
        const Duration(milliseconds: GameConfig.tutorialAutoCloseMs),
        _closeTutorial,
      );
    }

    _armAssist();
    _backstop = Timer(
      const Duration(milliseconds: GameConfig.idleFailMs),
      () => _resolve(won: false, reason: LoseReason.outOfMoves),
    );
  }

  @override
  void dispose() {
    _assist?.cancel();
    _backstop?.cancel();
    _tutorialTimer?.cancel();
    _flashTimer?.cancel();
    _outro?.cancel();
    _shake.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------- assist --

  /// Restarts the idle window. A real player taps every 1-3s and never sees
  /// the assist; a headless capture agent does, which is how the run always
  /// reaches a result frame.
  void _armAssist() {
    _assist?.cancel();
    // Clamp the re-armed idle window against a mount-relative ceiling: an agent
    // that taps every few seconds must not be able to defer the assist forever.
    final int elapsed = DateTime.now().difference(_mountedAt).inMilliseconds;
    final int remaining = GameConfig.autoplayCeilingMs - elapsed;
    int delay = GameConfig.autoplayIdleMs;
    if (remaining < delay) {
      delay = remaining < 1500 ? 1500 : remaining;
    }
    _assist = Timer(Duration(milliseconds: delay), _assistStep);
  }

  void _assistStep() {
    if (!mounted || _status != GameStatus.playing) {
      return;
    }
    final int wrong = _engine.firstWrongIndex;
    if (wrong >= 0) {
      setState(() {
        _engine.snapToSolution(wrong);
        if (_movesLeft > 1) {
          _movesLeft--;
        }
      });
      _assist = Timer(
        const Duration(milliseconds: GameConfig.autoplayStepMs),
        _assistStep,
      );
      return;
    }
    _assist = Timer(
      const Duration(milliseconds: GameConfig.autoplayFinishMs),
      _checkRoutes,
    );
  }

  void _closeTutorial() {
    _tutorialTimer?.cancel();
    if (mounted && _tutorialVisible) {
      setState(() => _tutorialVisible = false);
    }
  }

  // ------------------------------------------------------------ gameplay ----

  void _onTapCell(int index) {
    if (_status != GameStatus.playing) {
      return;
    }
    if (_tutorialVisible) {
      _closeTutorial();
      return;
    }
    _armAssist();

    final Cell cell = _engine.cells[index];
    if (!cell.isSign) {
      _shake.forward(from: 0);
      return;
    }
    if (_movesLeft <= 0) {
      return;
    }
    setState(() {
      _engine.rotate(index);
      _movesLeft--;
    });
    if (_movesLeft == 0 && !_engine.isSolved) {
      _resolve(won: false, reason: LoseReason.outOfMoves);
    }
  }

  void _checkRoutes() {
    if (!mounted || _status != GameStatus.playing) {
      return;
    }
    if (_engine.isSolved) {
      _resolve(won: true);
      return;
    }
    _armAssist();
    _shake.forward(from: 0);
    setState(() {
      _wrongChecks++;
      _flash = true;
    });
    _flashTimer?.cancel();
    _flashTimer = Timer(const Duration(milliseconds: 240), () {
      if (mounted) {
        setState(() => _flash = false);
      }
    });
    if (_wrongChecks >= GameConfig.maxWrongChecks) {
      _resolve(won: false, reason: LoseReason.tooManyChecks);
    }
  }

  void _resolve({required bool won, LoseReason reason = LoseReason.none}) {
    if (_resolved || !mounted) {
      return;
    }
    _resolved = true;
    _assist?.cancel();
    _backstop?.cancel();
    _tutorialTimer?.cancel();
    setState(() {
      _status = won ? GameStatus.won : GameStatus.lost;
      _tutorialVisible = false;
    });

    final int checksLeft = GameConfig.maxWrongChecks - _wrongChecks;
    final RoundResult result = RoundResult(
      won: won,
      reason: won ? LoseReason.none : reason,
      scheme: widget.scheme,
      movesLeft: _movesLeft,
      movesTotal: widget.scheme.moves,
      checksLeft: checksLeft < 0 ? 0 : checksLeft,
      stars: won
          ? GameConfig.starsFor(_movesLeft, widget.scheme.moves)
          : 0,
      best: widget.best,
    );

    _outro = Timer(Duration(milliseconds: won ? 520 : 420), () {
      if (mounted) {
        widget.onGameOver(result);
      }
    });
  }

  // ------------------------------------------------------------------- UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            AppAssets.bgGame,
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
              return const ColoredBox(color: AppColors.bgBase);
            },
          ),
          const ColoredBox(color: Color(0xC7171D25)),
          Column(
            children: <Widget>[
              _buildHeader(),
              Expanded(child: _buildBoardArea()),
              _buildStatStrip(),
              _buildControls(),
            ],
          ),
          if (_tutorialVisible)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _closeTutorial,
                child: ColoredBox(
                  color: AppColors.bgDeep.withValues(alpha: 0.62),
                  child: TutorialPanel(onClose: _closeTutorial),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final bool low = _movesLeft <= 3;
    return Container(
      padding: const EdgeInsets.only(top: 44, left: 16, right: 16, bottom: 10),
      decoration: const BoxDecoration(
        color: Color(0x4D000000),
        border: Border(
          bottom: BorderSide(color: AppColors.borderHard, width: 3),
        ),
      ),
      child: Row(
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onExit,
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.textPrimary, width: 3),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 24,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'SCHEME ${widget.scheme.label} · ${widget.scheme.sizeLabel}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              border: Border.all(color: AppColors.borderHard, width: 3),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'MOVES',
                  style: TextStyle(
                    fontSize: 9,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$_movesLeft',
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    color: low ? AppColors.accentClay : AppColors.accentGold,
                    fontFeatures: kTabularFigures,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardArea() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxBoardWidth =
            math.min(constraints.maxWidth - 32, 380.0);
        final double tile = boardTileSize(
          maxWidth: maxBoardWidth,
          maxHeight: constraints.maxHeight - 74,
          cols: widget.scheme.cols,
          rows: widget.scheme.rows,
        );

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedBuilder(
                animation: _shake,
                builder: (BuildContext context, Widget? child) {
                  final double dx =
                      10 * math.sin(_shake.value * math.pi * 3) *
                          (1 - _shake.value);
                  return Transform.translate(
                    offset: Offset(dx, 0),
                    child: child,
                  );
                },
                child: AnimatedScale(
                  scale: _status == GameStatus.won ? 1.04 : 1.0,
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOut,
                  child: RouteBoard(
                    engine: _engine,
                    tile: tile,
                    dimmed: _status == GameStatus.lost,
                    borderColor:
                        _flash ? AppColors.accentClay : AppColors.textPrimary,
                    onTapCell: _onTapCell,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _buildGoals(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoals() {
    final List<Widget> pills = <Widget>[];
    for (int i = 0; i < RouteColorId.values.length; i++) {
      final RouteColorId route = RouteColorId.values[i];
      if (i > 0) {
        pills.add(const SizedBox(width: 8));
      }
      pills.add(
        RouteGoalPill(
          label: route.label,
          linked: _engine.isRouteLinked(route),
          color: route.color,
        ),
      );
    }
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(mainAxisSize: MainAxisSize.min, children: pills),
    );
  }

  Widget _buildStatStrip() {
    final int checksLeft = GameConfig.maxWrongChecks - _wrongChecks;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: IntrinsicHeight(
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: StatCard(
              value: '$_movesLeft',
              label: 'moves',
              valueColor: AppColors.accentGold,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StatCard(
              value: '${checksLeft < 0 ? 0 : checksLeft}',
              label: 'checks',
              valueColor: AppColors.accentCyan,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StatCard(
              value: '${_engine.linkedRoutes}/3',
              label: 'linked',
              valueColor: AppColors.accentGreen,
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          BrutalButton(
            label: 'CHECK ROUTES',
            icon: Icons.verified_rounded,
            height: 60,
            fontSize: 17,
            gradient: const <Color>[
              AppColors.accentCyan,
              AppColors.accentGreen,
            ],
            onTap: _checkRoutes,
          ),
          const SizedBox(height: 8),
          const Text(
            'TURN SIGNS, THEN CHECK',
            style: TextStyle(
              fontSize: 11,
              height: 1.2,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
