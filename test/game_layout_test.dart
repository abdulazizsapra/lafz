import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lafz/shared/widgets/game_layout.dart';

void main() {
  test('board shrinks to the leftover height instead of overflowing', () {
    final size = wordleBoardSize(
      maxWidth: 500,
      maxHeight: 180,
      columns: 5,
      rows: 5,
    );
    expect(size.height, lessThanOrEqualTo(180));
    expect(size.width, size.height);
  });

  test('a short phone keeps board plus keyboard inside the play area', () {
    final layout = layoutGame(const Size(375, 520));
    expect(
      layout.board.height + layout.keyboardHeight,
      lessThanOrEqualTo(520 + 0.5),
    );
    expect(layout.tileSize, greaterThanOrEqualTo(kMinTileSize));
    expect(layout.keyHeight, greaterThanOrEqualTo(kMinKeyHeight));
  });

  test('a landscape phone still fits without overflow', () {
    final layout = layoutGame(const Size(844, 280));
    expect(
      layout.board.height + layout.keyboardHeight,
      lessThanOrEqualTo(280 + 0.5),
    );
    expect(layout.board.width, lessThanOrEqualTo(844));
  });

  test('a wide desktop keeps a compact centered board', () {
    final layout = layoutGame(const Size(500, 780));
    expect(layout.board.width, lessThanOrEqualTo(kWordleBoardMaxWidth));
    expect(layout.board.height, layout.board.width);
  });
}
