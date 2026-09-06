import 'package:flutter/material.dart';
import 'package:lafz/shared/widgets/game_layout.dart';

export 'package:lafz/shared/widgets/game_layout.dart';

class PlayWindow extends StatelessWidget {
  final Widget child;

  const PlayWindow({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final window = playWindowSize(media.size);

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: MediaQuery(
          data: media.copyWith(size: window),
          child: SizedBox(
            width: window.width,
            height: window.height,
            child: child,
          ),
        ),
      ),
    );
  }
}
