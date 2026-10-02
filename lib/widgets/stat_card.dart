import 'package:flutter/material.dart';

import '../theme.dart';

/// One stat pill. Identical on GameScreen and GameOverScreen — no raster art
/// inside, so three of them in a row always line up.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: valueColor.withValues(alpha: 0.55), width: 3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: valueColor, shape: BoxShape.circle),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            style: TextStyle(
              fontSize: 20,
              height: 1.0,
              fontWeight: FontWeight.w900,
              color: valueColor,
              fontFeatures: kTabularFigures,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              height: 1.1,
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

/// Thin route-progress pill used under the board (GOLD 0/1 etc.).
class RouteGoalPill extends StatelessWidget {
  const RouteGoalPill({
    super.key,
    required this.label,
    required this.linked,
    required this.color,
  });

  final String label;
  final bool linked;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: linked ? color : AppColors.borderHard,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: linked ? color : AppColors.textMuted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$label ${linked ? 1 : 0}/1',
            style: TextStyle(
              fontSize: 10,
              height: 1.2,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: linked ? color : AppColors.textMuted,
              fontFeatures: kTabularFigures,
            ),
          ),
        ],
      ),
    );
  }
}
