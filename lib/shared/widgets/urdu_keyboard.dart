import 'package:flutter/material.dart';
import 'package:lafz/app/typography.dart';
import 'package:lafz/core/constants/keyboard_layout.dart';
import 'package:lafz/shared/models/game_models.dart';
import 'package:lafz/app/theme/app_colors.dart';

class UrduKeyboard extends StatelessWidget {
  final Function(String) onKeyTap;
  final VoidCallback onEnter;
  final VoidCallback onBackspace;
  final Map<String, TileState> keyStates;
  final double? keyHeight;

  const UrduKeyboard({
    super.key,
    required this.onKeyTap,
    required this.onEnter,
    required this.onBackspace,
    required this.keyStates,
    this.keyHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const gap = 6.0;
            final keyWidth =
                ((constraints.maxWidth - gap * 9) / 10).clamp(18.0, 44.0);
            final keyHeight = this.keyHeight ??
                (constraints.maxWidth >= 420 ? 56.0 : 48.0);
            return Column(
              children: [
                ...UrduKeyboardLayout.rows.map((row) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: row
                          .map(
                            (key) => _letterKey(
                              context,
                              key,
                              keyWidth,
                              keyHeight,
                              gap,
                            ),
                          )
                          .toList(),
                    ),
                  );
                }),
                Row(
                  children: [
                    Expanded(
                      child: _actionKey(
                        context,
                        label: UrduKeyboardLayout.backspaceLabel,
                        onTap: onBackspace,
                        height: keyHeight,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 2,
                      child: _actionKey(
                        context,
                        label: UrduKeyboardLayout.enterLabel,
                        onTap: onEnter,
                        height: keyHeight,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _letterKey(
    BuildContext context,
    String key,
    double width,
    double height,
    double gap,
  ) {
    final colors = _keyColors(context, keyStates[key] ?? TileState.empty);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: gap / 2),
      child: Material(
        color: colors.$1,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: () => onKeyTap(key),
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            width: width - gap,
            height: height,
            child: Center(
              child: Text(
                key,
                style: TextStyle(
                  color: colors.$2,
                  fontWeight: FontWeight.bold,
                  fontSize: (height * 0.36).clamp(12.0, 18.0),
                  fontFamily: AppTypography.urduFontFamily,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionKey(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    required double height,
  }) {
    final colors = _keyColors(context, TileState.empty);
    return Material(
      color: colors.$1,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: height,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: colors.$2,
                fontWeight: FontWeight.bold,
                fontSize: (height * 0.32).clamp(11.0, 16.0),
                fontFamily: AppTypography.urduFontFamily,
              ),
            ),
          ),
        ),
      ),
    );
  }

  (Color, Color) _keyColors(BuildContext context, TileState state) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    switch (state) {
      case TileState.correct:
        return (AppColors.correct, Colors.white);
      case TileState.present:
        return (AppColors.present, Colors.white);
      case TileState.absent:
        return (AppColors.absent, Colors.white);
      default:
        return (
          dark ? AppColors.darkKey : AppColors.lightKey,
          dark ? AppColors.darkText : AppColors.lightText,
        );
    }
  }
}
