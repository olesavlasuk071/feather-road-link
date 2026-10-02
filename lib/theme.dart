import 'package:flutter/material.dart';

/// Canonical visual preset for this build. The `name` must stay one of the ten
/// canonical presets — accent colours below are overridden per brief, the name
/// is not.
class PresetMeta {
  const PresetMeta({required this.name});

  final String name;
}

const PresetMeta kPreset = PresetMeta(name: 'RETRO_NEON');

/// BRUTALISM surface language on a RETRO_NEON palette.
class AppColors {
  const AppColors._();

  static const Color bgDeep = Color(0xFF0B0F14);
  static const Color bgBase = Color(0xFF171D25);
  static const Color surface = Color(0xFF1F2733);
  static const Color surfaceAlt = Color(0xFF28313F);
  static const Color borderHard = Color(0xFF0A0D12);

  static const Color accentGold = Color(0xFFF1C447);
  static const Color accentClay = Color(0xFFE9643F);
  static const Color accentCyan = Color(0xFF4CB8C8);
  static const Color accentGreen = Color(0xFF7AC858);

  static const Color textPrimary = Color(0xFFFFF1D6);
  static const Color textSecondary = Color(0xFFB9C2CF);
  static const Color textMuted = Color(0xFF7E8A99);
}

/// Hard brutalist drop shadow — pure offset, zero blur.
List<BoxShadow> hardShadow({
  Color color = AppColors.borderHard,
  double dx = 6,
  double dy = 6,
}) {
  return <BoxShadow>[
    BoxShadow(color: color, offset: Offset(dx, dy)),
  ];
}

const List<FontFeature> kTabularFigures = <FontFeature>[
  FontFeature.tabularFigures(),
];

ThemeData buildAppTheme() {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: AppColors.accentGold,
    brightness: Brightness.dark,
  ).copyWith(
    primary: AppColors.accentGold,
    onPrimary: AppColors.bgBase,
    secondary: AppColors.accentCyan,
    onSecondary: AppColors.bgBase,
    tertiary: AppColors.accentGreen,
    error: AppColors.accentClay,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
  );

  const TextTheme text = TextTheme(
    displayLarge: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w900,
      letterSpacing: 2.0,
      color: AppColors.textPrimary,
      height: 1.1,
    ),
    headlineMedium: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.4,
      color: AppColors.textPrimary,
      height: 1.12,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.6,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: AppColors.textSecondary,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.4,
      color: AppColors.textMuted,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bgBase,
    textTheme: text,
    splashFactory: InkRipple.splashFactory,
  );
}
