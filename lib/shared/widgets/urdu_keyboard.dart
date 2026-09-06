import 'package:flutter/material.dart';
import 'package:lafz/core/constants/keyboard_layout.dart';
import 'package:lafz/shared/models/game_models.dart';
import 'package:lafz/app/theme/app_colors.dart';

class UrduKeyboard extends StatelessWidget {
  final Function(String) onKeyTap;
  final Function onEnter;
  final Function onBackspace;
  final Map<String, TileState> keyStates;

  const UrduKeyboard({
    super.key,
    required this.onKeyTap,
    required this.onEnter,
    required this.onBackspace,
    required this.keyStates,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: UrduKeyboardLayout.rows.map((row) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.map((key) => _buildKey(context, key)).toList(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildKey(BuildContext context, String key) {
    final state = keyStates[key] ?? TileState.empty;
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (state) {
      case TileState.correct:
        backgroundColor = AppColors.correct;
        break;
      case TileState.present:
        backgroundColor = AppColors.present;
        break;
      case TileState.absent:
        backgroundColor = AppColors.absent;
        break;
      default:
        backgroundColor = Theme.of(context).brightness == Brightness.light 
            ? Colors.grey[300]! 
            : Colors.grey[800]!;
        textColor = Theme.of(context).brightness == Brightness.light 
            ? Colors.black 
            : Colors.white;
    }

    return GestureDetector(
      onTap: () => onKeyTap(key),
      child: Container(
        margin: const EdgeInsets.all(4),
        width: MediaQuery.of(context).size.width * 0.09,
        height: 45,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            key,
            style: TextStyle(
              color: textColor, 
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.width * 0.04,
            ),
          ),
        ),
      ),
    );
  }
}
