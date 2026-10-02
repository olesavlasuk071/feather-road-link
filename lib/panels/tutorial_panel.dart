import 'package:flutter/material.dart';

import '../theme.dart';

/// First-level coach mark. Rendered inside GameScreen's stack, never as a
/// separate route — it must not add a required screenshot frame.
class TutorialPanel extends StatelessWidget {
  const TutorialPanel({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(
            color: const Color(0xEB171D25),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.accentGold, width: 3),
            boxShadow: hardShadow(dx: 6, dy: 6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'HOW TO LINK',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.8,
                  color: AppColors.accentGold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'TAP A SIGN TO TURN IT 90 DEGREES. LINK EACH CART TO ITS BARN. '
                'THEN PRESS CHECK.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onClose,
                child: Container(
                  height: 48,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.accentGold,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.borderHard, width: 3),
                  ),
                  child: const Text(
                    'GOT IT',
                    style: TextStyle(
                      fontSize: 15,
                      height: 24 / 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: AppColors.bgBase,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
