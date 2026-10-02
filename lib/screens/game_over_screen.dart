import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../game/puzzle_engine.dart';
import '../panels/scheme_select_panel.dart';
import '../theme.dart';
import '../widgets/brutal_button.dart';
import '../widgets/route_board.dart';
import '../widgets/stat_card.dart';

/// Result screen. No background photo — it must read as its own surface next
/// to the game frame.
class GameOverScreen extends StatefulWidget {
  const GameOverScreen({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onPickScheme,
    required this.onMenu,
  });

  final RoundResult result;
  final VoidCallback onPlayAgain;
  final ValueChanged<SchemeId> onPickScheme;
  final VoidCallback onMenu;

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _starScales;
  late final PuzzleEngine _solved;

  @override
  void initState() {
    super.initState();
    _solved = PuzzleEngine.solved(scheme: widget.result.scheme);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _starScales = List<Animation<double>>.generate(
      3,
      (int i) {
        final double begin = i * 0.18;
        return Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(begin, begin + 0.5, curve: Curves.easeOutBack),
          ),
        );
      },
      growable: false,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openSchemePanel() async {
    final SchemeId? picked = await showSchemeSelectPanel(
      context,
      selected: GameConfig.nextScheme(widget.result.scheme.id).id,
    );
    if (picked != null) {
      widget.onPickScheme(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool won = widget.result.won;
    final Color accent = won ? AppColors.accentGreen : AppColors.accentClay;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.65),
                radius: 1.1,
                colors: <Color>[
                  (won ? AppColors.accentGold : AppColors.accentClay)
                      .withValues(alpha: won ? 0.18 : 0.16),
                  AppColors.bgBase,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 44, 20, 18),
            child: Column(
              children: <Widget>[
                _buildStars(),
                const SizedBox(height: 18),
                Text(
                  widget.result.headline,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 36,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'SCHEME ${widget.result.scheme.label} · '
                  '${widget.result.scheme.sizeLabel}',
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(child: _buildMiniMap()),
                const SizedBox(height: 14),
                _buildStatRow(),
                const SizedBox(height: 18),
                BrutalButton(
                  label: 'PLAY AGAIN',
                  icon: Icons.refresh_rounded,
                  height: 60,
                  fontSize: 18,
                  letterSpacing: 1.6,
                  gradient: const <Color>[
                    AppColors.accentGold,
                    AppColors.accentClay,
                  ],
                  backgroundImage: AppAssets.buttonCta,
                  onTap: widget.onPlayAgain,
                ),
                if (won) const SizedBox(height: 10),
                if (won)
                  BrutalSecondaryButton(
                    label: 'NEXT SCHEME',
                    onTap: _openSchemePanel,
                  ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 48,
                  child: TextButton(
                    onPressed: widget.onMenu,
                    child: const Text(
                      'MENU',
                      style: TextStyle(
                        fontSize: 13,
                        height: 24 / 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStars() {
    final List<Widget> stars = <Widget>[];
    for (int i = 0; i < 3; i++) {
      if (i > 0) {
        stars.add(const SizedBox(width: 8));
      }
      stars.add(
        ScaleTransition(
          scale: _starScales[i],
          child: Icon(
            Icons.star_rounded,
            size: 40,
            color: i < widget.result.stars
                ? AppColors.accentGold
                : AppColors.surfaceAlt,
          ),
        ),
      );
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: stars);
  }

  Widget _buildMiniMap() {
    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: RouteBoard(
          engine: _solved,
          tile: 44,
          dimmed: false,
          borderColor: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildStatRow() {
    final List<Widget> cards = <Widget>[
      Expanded(
        child: StatCard(
          value: '${widget.result.movesLeft}',
          label: 'moves left',
          valueColor: AppColors.accentGold,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: StatCard(
          value: '${widget.result.checksLeft}',
          label: 'checks',
          valueColor: AppColors.accentCyan,
        ),
      ),
    ];
    if (widget.result.best > 0) {
      cards.add(const SizedBox(width: 10));
      cards.add(
        Expanded(
          child: StatCard(
            value: '${widget.result.best}',
            label: 'best',
            valueColor: AppColors.accentGreen,
          ),
        ),
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: cards,
      ),
    );
  }
}
