import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show FrameTiming;

import '../assets.dart';
import '../game/game_config.dart';
import '../theme.dart';
import '../widgets/grain_painter.dart';

/// Branded splash. Darker and colder than the menu, no CTA, heavy film grain
/// so the captured frame is unmistakably its own screen.
class LoaderScreen extends StatefulWidget {
  const LoaderScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<LoaderScreen> createState() => _LoaderScreenState();
}

class _LoaderScreenState extends State<LoaderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _plateScale;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  Timer? _handoff;
  Timer? _safety;
  bool _armed = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _plateScale = Tween<double>(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.32),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();

    // Arm the hand-off on the first rasterised frame, not in initState — on a
    // loaded emulator the first frame can land seconds after mount.
    WidgetsBinding.instance.addTimingsCallback(_onFirstFrame);
    _safety = Timer(
      const Duration(milliseconds: GameConfig.loaderDurationMs * 5),
      _finish,
    );
  }

  void _onFirstFrame(List<FrameTiming> timings) {
    if (_armed) {
      return;
    }
    _armed = true;
    WidgetsBinding.instance.removeTimingsCallback(_onFirstFrame);
    _handoff = Timer(
      const Duration(milliseconds: GameConfig.loaderDurationMs),
      _finish,
    );
  }

  void _finish() {
    if (_done || !mounted) {
      return;
    }
    _done = true;
    widget.onDone();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeTimingsCallback(_onFirstFrame);
    _handoff?.cancel();
    _safety?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            AppAssets.bgLoader,
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
              return const ColoredBox(color: AppColors.bgDeep);
            },
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xEB0B0F14),
                  Color(0xDB171D25),
                  Color(0xF20B0F14),
                ],
              ),
            ),
          ),
          const Positioned.fill(
            child: CustomPaint(
              painter: GrainPainter(
                points: 45000,
                color: AppColors.textPrimary,
                opacity: 0.11,
                strokeWidth: 1.5,
                seed: 7,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ScaleTransition(
                    scale: _plateScale,
                    child: Container(
                      width: 148,
                      height: 148,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(
                          color: AppColors.textPrimary,
                          width: 3,
                        ),
                        boxShadow: hardShadow(
                          color: AppColors.accentGold,
                          dx: 6,
                          dy: 6,
                        ),
                      ),
                      child: Image.asset(
                        AppAssets.icon,
                        width: 104,
                        height: 104,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (BuildContext context, Object error, StackTrace? stack) {
                          return const Icon(
                            Icons.signpost_rounded,
                            size: 84,
                            color: AppColors.accentGold,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                  FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Column(
                        children: const <Widget>[
                          Text(
                            'FEATHER ROAD',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 34,
                              height: 1.08,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3.0,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'LINK',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 34,
                              height: 1.08,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 8.0,
                              color: AppColors.accentGold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'TURN THE SIGNS · LINK THE ROUTES',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.3,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.6,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildProgressBar(),
                  const SizedBox(height: 12),
                  const Text(
                    'LOADING…',
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      width: 180,
      height: 14,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderHard, width: 3),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 0.98),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOut,
          builder: (BuildContext context, double value, Widget? _) {
            return FractionallySizedBox(
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: const LinearGradient(
                    colors: <Color>[
                      AppColors.accentGold,
                      AppColors.accentClay,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
