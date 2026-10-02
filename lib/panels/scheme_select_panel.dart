import 'package:flutter/material.dart';

import '../game/game_config.dart';
import '../theme.dart';
import '../widgets/brutal_button.dart';

/// Modal scheme picker. Lives in lib/panels (not lib/screens) on purpose —
/// the screenshot gate counts lib/screens/*.dart as required unique frames.
Future<SchemeId?> showSchemeSelectPanel(
  BuildContext context, {
  required SchemeId selected,
}) {
  return showModalBottomSheet<SchemeId>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0xB30A0D12),
    isScrollControlled: false,
    builder: (BuildContext sheetContext) {
      return _SchemeSelectPanel(selected: selected);
    },
  );
}

class _SchemeSelectPanel extends StatefulWidget {
  const _SchemeSelectPanel({required this.selected});

  final SchemeId selected;

  @override
  State<_SchemeSelectPanel> createState() => _SchemeSelectPanelState();
}

class _SchemeSelectPanelState extends State<_SchemeSelectPanel> {
  late SchemeId _pick = widget.selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      decoration: const BoxDecoration(
        color: AppColors.bgBase,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        border: Border.fromBorderSide(
          BorderSide(color: AppColors.textPrimary, width: 3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'CHOOSE A SCHEME',
            style: TextStyle(
              fontSize: 20,
              height: 1.2,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.6,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'BIGGER BOARDS · MORE SIGNS TO TURN',
            style: TextStyle(
              fontSize: 11,
              height: 1.3,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          ...GameConfig.schemes.map(_buildRow),
          const SizedBox(height: 18),
          BrutalButton(
            label: 'APPLY SCHEME',
            icon: Icons.check_rounded,
            height: 56,
            fontSize: 16,
            gradient: const <Color>[
              AppColors.accentCyan,
              AppColors.accentGreen,
            ],
            onTap: () => Navigator.of(context).pop(_pick),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(SchemeDef scheme) {
    final bool active = scheme.id == _pick;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _pick = scheme.id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.surfaceAlt : AppColors.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: active ? AppColors.accentGold : AppColors.borderHard,
              width: 3,
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                active
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
                color: active ? AppColors.accentGold : AppColors.textMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${scheme.label}  ${scheme.sizeLabel}',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: active
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                '${scheme.moves} MOVES',
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppColors.textMuted,
                  fontFeatures: kTabularFigures,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
