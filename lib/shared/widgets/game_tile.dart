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
        borderColor = AppColors.lightBorder;
        textColor = AppColors.lightText;
        break;
      case TileState.empty:
        backgroundColor = Colors.transparent;
        borderColor = isCurrent ? AppColors.accent : AppColors.lightBorder;
        textColor = AppColors.lightText;
        break;
    }

    // Adjust for dark theme
    if (Theme.of(context).brightness == Brightness.dark) {
      if (state == TileState.filled) {
        borderColor = AppColors.darkBorder;
        textColor = AppColors.darkText;
      } else if (state == TileState.empty) {
        borderColor = isCurrent ? AppColors.accent : AppColors.darkBorder;
        textColor = AppColors.darkText;
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: MediaQuery.of(context).size.width * 0.15,
      height: MediaQuery.of(context).size.width * 0.15,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.06,
            fontWeight: FontWeight.bold,
            color: textColor,
            fontFamily: AppTypography.urduFontFamily,
          ),
        ),
      ),
    );
  }

}
