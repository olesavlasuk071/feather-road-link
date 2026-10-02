import 'package:flutter/material.dart';

import '../theme.dart';

class SchemeChip extends StatelessWidget {
  const SchemeChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.accentGold : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: active ? AppColors.borderHard : AppColors.surface,
            width: 3,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            height: 1.2,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            color: active ? AppColors.bgBase : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
