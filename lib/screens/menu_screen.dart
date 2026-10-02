import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../panels/scheme_select_panel.dart';
import '../theme.dart';
import '../widgets/brutal_button.dart';
import '../widgets/scheme_chip.dart';

/// M2 bottom-sheet menu: full-bleed hero art on top, opaque brutalist sheet
/// carrying the scheme chips and the single primary CTA.
class MenuScreen extends StatefulWidget {
  const MenuScreen({
    super.key,
    required this.selected,
    required this.stars,
    required this.onSelectScheme,
    required this.onStart,
  });

  final SchemeId selected;
  final int stars;
  final ValueChanged<SchemeId> onSelectScheme;
  final ValueChanged<SchemeId> onStart;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _sheetFade;
  late final Animation<Offset> _sheetSlide;
  late final List<Animation<double>> _chipFades;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _sheetFade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _sheetSlide = Tween<Offset>(
      begin: const Offset(0, 0.16),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _chipFades = List<Animation<double>>.generate(
      GameConfig.schemes.length,
      (int i) {
        final double begin = i * 0.12;
        return CurvedAnimation(
          parent: _controller,
          curve: Interval(begin, begin + 0.6, curve: Curves.easeOut),
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
      selected: widget.selected,
    );
    if (picked != null) {
      widget.onSelectScheme(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            AppAssets.bgMenu,
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
              return const ColoredBox(color: AppColors.bgBase);
            },
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0x33171D25),
                  Color(0x8C171D25),
                  Color(0xDB171D25),
                ],
              ),
            ),
          ),
          Column(
            children: <Widget>[
              _buildTopRow(),
              Expanded(child: _buildHeroArea()),
              FadeTransition(
                opacity: _sheetFade,
                child: SlideTransition(
                  position: _sheetSlide,
                  child: _buildSheet(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 44, left: 18, right: 18, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xD9171D25),
              border: Border.all(color: AppColors.textPrimary, width: 3),
              boxShadow: hardShadow(color: AppColors.accentGold, dx: 4, dy: 4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.star_rounded,
                  size: 20,
                  color: AppColors.accentGold,
                ),
                const SizedBox(width: 6),
                Text(
                  '${widget.stars}',
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    fontFeatures: kTabularFigures,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _openSchemePanel,
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xD9171D25),
                border: Border.all(color: AppColors.textPrimary, width: 3),
              ),
              child: const Icon(
                Icons.tune_rounded,
                size: 24,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroArea() {
    return Align(
      alignment: const Alignment(0.62, 0.1),
      child: Transform.rotate(
        angle: -0.12,
        child: Image.asset(
          AppAssets.signpost,
          width: 86,
          height: 86,
          fit: BoxFit.contain,
          errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
            return const Icon(
              Icons.signpost_rounded,
              size: 72,
              color: AppColors.accentGold,
            );
          },
        ),
      ),
    );
  }

  Widget _buildSheet() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
      decoration: const BoxDecoration(
        color: AppColors.bgBase,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        border: Border.fromBorderSide(
          BorderSide(color: AppColors.textPrimary, width: 3),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(color: AppColors.bgDeep, offset: Offset(0, -6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            'FEATHER\nROAD LINK',
            style: TextStyle(
              fontSize: 30,
              height: 1.08,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ROTATE SIGNS · LINK CARTS TO BARNS',
            style: TextStyle(
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildChipRow(),
          const SizedBox(height: 18),
          const Text(
            'TAP A SIGN TO TURN IT',
            style: TextStyle(
              fontSize: 11,
              height: 1.2,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          BrutalButton(
            label: 'START ROUTES',
            icon: Icons.play_arrow_rounded,
            height: 64,
            fontSize: 18,
            letterSpacing: 1.6,
            gradient: const <Color>[
              AppColors.accentGold,
              AppColors.accentClay,
            ],
            backgroundImage: AppAssets.buttonCta,
            onTap: () => widget.onStart(widget.selected),
          ),
        ],
      ),
    );
  }

  Widget _buildChipRow() {
    final List<Widget> chips = <Widget>[];
    for (int i = 0; i < GameConfig.schemes.length; i++) {
      final SchemeDef scheme = GameConfig.schemes[i];
      chips.add(
        Expanded(
          child: FadeTransition(
            opacity: _chipFades[i],
            child: SchemeChip(
              label: '${scheme.label} ${scheme.sizeLabel}',
              active: scheme.id == widget.selected,
              onTap: () => widget.onSelectScheme(scheme.id),
            ),
          ),
        ),
      );
      if (i != GameConfig.schemes.length - 1) {
        chips.add(const SizedBox(width: 10));
      }
    }
    return Row(children: chips);
  }
}
