import 'package:flutter/material.dart';

import '../theme.dart';

/// Flat brutalist CTA: 3px hard border, zero-blur offset shadow, optional
/// AI-rendered backing plate under a translucent gradient.
class BrutalButton extends StatefulWidget {
  const BrutalButton({
    super.key,
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
    this.height = 60,
    this.fontSize = 17,
    this.letterSpacing = 1.4,
    this.foreground = AppColors.bgBase,
    this.borderColor = AppColors.borderHard,
    this.backgroundImage,
  });

  final String label;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;
  final double height;
  final double fontSize;
  final double letterSpacing;
  final Color foreground;
  final Color borderColor;
  final String? backgroundImage;

  @override
  State<BrutalButton> createState() => _BrutalButtonState();
}

class _BrutalButtonState extends State<BrutalButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value && mounted) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage = widget.backgroundImage != null;
    final double overlayAlpha = hasImage ? 0.88 : 1.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (TapDownDetails _) => _setPressed(true),
      onTapUp: (TapUpDetails _) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutCubic,
        child: Container(
          height: widget.height,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: widget.gradient.first,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: widget.borderColor, width: 3),
            boxShadow: hardShadow(dx: 0, dy: 6),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (hasImage)
                Image.asset(
                  widget.backgroundImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
                    return const SizedBox.shrink();
                  },
                ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: widget.gradient
                        .map((Color c) => c.withValues(alpha: overlayAlpha))
                        .toList(growable: false),
                  ),
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(widget.icon, size: 24, color: widget.foreground),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: widget.fontSize,
                          height: 24 / widget.fontSize,
                          fontWeight: FontWeight.w900,
                          letterSpacing: widget.letterSpacing,
                          color: widget.foreground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Flat secondary action — same geometry language, no gradient plate.
class BrutalSecondaryButton extends StatelessWidget {
  const BrutalSecondaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.height = 48,
  });

  final String label;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.textPrimary, width: 3),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            height: 24 / 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.6,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
