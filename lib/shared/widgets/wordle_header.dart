import 'package:flutter/material.dart';
import 'package:lafz/app/typography.dart';

/// Thin Wordle-style chrome: icons on the sides, title locked to center.
class WordleHeader extends StatelessWidget {
  final String title;
  final List<Widget> leading;
  final List<Widget> trailing;

  const WordleHeader({
    super.key,
    required this.title,
    this.leading = const [],
    this.trailing = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 54,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    ...leading,
                    const Spacer(),
                    ...trailing,
                  ],
                ),
              ),
              IgnorePointer(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTypography.urduFontFamily,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor),
      ],
    );
  }
}
