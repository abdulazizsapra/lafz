import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lafz/shared/widgets/play_window.dart';

void main() {
  test('phone-width viewports keep the full screen', () {
    expect(
      playWindowSize(const Size(390, 844)),
      const Size(390, 844),
    );
  });

  test('wide viewports use a centered column that fills the height', () {
    final size = playWindowSize(const Size(1440, 900));
    expect(size.width, 500);
    expect(size.height, 900);
  });

  test('board tiles stay square with a Wordle-tight gap', () {
    final size = wordleBoardSize(
      maxWidth: 500,
      columns: 5,
      rows: 5,
    );
    expect(size.width, 350);
    expect(size.height, 350);
  });
}
