import 'package:flutter/material.dart';
import 'package:lafz/app/theme/app_colors.dart';
import 'package:lafz/app/typography.dart';
import 'package:lafz/shared/models/game_models.dart';

class GameTile extends StatelessWidget {
  final String letter;
  final TileState state;
  final bool isCurrent;

  const GameTile({
    super.key,
    required this.letter,
    required this.state,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    switch (state) {
      case TileState.correct:
        backgroundColor = AppColors.correct;
        borderColor = AppColors.correct;
        textColor = Colors.white;
        break;
      case TileState.present:
        backgroundColor = AppColors.present;
        borderColor = AppColors.present;
        textColor = Colors.white;
        break;
      case TileState.absent:
        backgroundColor = AppColors.absent;
        borderColor = AppColors.absent;
        textColor = Colors.white;
        break;
      case TileState.filled:
        backgroundColor = Colors.transparent;
        borderColor = dark ? AppColors.darkFilledBorder : AppColors.lightFilledBorder;
        textColor = dark ? AppColors.darkText : AppColors.lightText;
        break;
      case TileState.empty:
        backgroundColor = Colors.transparent;
        borderColor = isCurrent
            ? (dark ? AppColors.darkFilledBorder : AppColors.lightFilledBorder)
            : (dark ? AppColors.darkBorder : AppColors.lightBorder);
        textColor = dark ? AppColors.darkText : AppColors.lightText;
        break;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : 62.0;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: side,
          height: side,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                fontSize: (side * 0.48).clamp(18.0, 34.0),
                fontWeight: FontWeight.w800,
                color: textColor,
                fontFamily: AppTypography.urduFontFamily,
                height: 1,
              ),
            ),
          ),
        );
      },
    );
  }
}
