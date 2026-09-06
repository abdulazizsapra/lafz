import 'dart:math' as math;

import 'package:flutter/material.dart';

const double kPlayWindowMaxWidth = 500;
const double kPlayWindowPhoneBreakpoint = 500;
const double kWordleBoardMaxWidth = 350;
const double kWordleTileGap = 5;
const double kMinTileSize = 28;
const double kMaxTileSize = 66;
const double kMinKeyHeight = 32;
const double kMaxKeyHeight = 56;
const double kKeyGap = 6;
const int kLetterKeyRows = 4;

/// Full-bleed on a phone. On a wide screen, a centered column the
/// full viewport height — same flat page as Wordle, not a device frame.
Size playWindowSize(Size viewport) {
  if (viewport.width <= kPlayWindowPhoneBreakpoint) {
    return viewport;
  }
  return Size(
    math.min(kPlayWindowMaxWidth, viewport.width),
    viewport.height,
  );
}

/// Square tiles that shrink to the leftover height as well as width.
Size wordleBoardSize({
  required double maxWidth,
  required int columns,
  required int rows,
  double maxHeight = double.infinity,
  double gap = kWordleTileGap,
  double maxBoard = kWordleBoardMaxWidth,
}) {
  final widthBudget = math.min(maxBoard, math.max(0, maxWidth));
  final tileFromWidth = columns == 0
      ? 0.0
      : (widthBudget - gap * (columns - 1)) / columns;
  final tileFromHeight = !maxHeight.isFinite || rows == 0
      ? tileFromWidth
      : (math.max(0, maxHeight) - gap * (rows - 1)) / rows;
  final budget = math.min(tileFromWidth, tileFromHeight);
  // Stay inside the leftover box even if that means a tiny tile.
  final tile = budget.clamp(0.0, kMaxTileSize);
  return Size(
    tile * columns + gap * (columns - 1),
    tile * rows + gap * (rows - 1),
  );
}

class GameLayout {
  final Size board;
  final double keyHeight;

  const GameLayout({required this.board, required this.keyHeight});

  double get tileSize =>
      (board.width - kWordleTileGap * 4) / 5;

  double get keyboardHeight =>
      kLetterKeyRows * (keyHeight + kKeyGap) + keyHeight + 14;
}

/// Split [area] between a square board and the 4-row Urdu keyboard
/// so neither overflows a short phone or a landscape window.
GameLayout layoutGame(
  Size area, {
  int columns = 5,
  int rows = 5,
}) {
  double keyboardHeight(double keyH) =>
      kLetterKeyRows * (keyH + kKeyGap) + keyH + 14;

  Size boardFor(double keyH) => wordleBoardSize(
        maxWidth: math.max(0, area.width - 16),
        maxHeight: math.max(0, area.height - keyboardHeight(keyH)),
        columns: columns,
        rows: rows,
      );

  var keyHeight = (area.width >= 420 ? 52.0 : 44.0)
      .clamp(kMinKeyHeight, kMaxKeyHeight);
  if (keyboardHeight(keyHeight) > area.height * 0.5) {
    keyHeight = math.max(
      18.0,
      (area.height * 0.45 - 14 - kKeyGap * kLetterKeyRows) /
          (kLetterKeyRows + 1),
    );
  }
  var board = boardFor(keyHeight);
  final total = board.height + keyboardHeight(keyHeight);
  if (total > area.height && total > 0) {
    final scale = area.height / total;
    keyHeight = math.max(18.0, keyHeight * scale);
    board = boardFor(keyHeight);
  }
  return GameLayout(board: board, keyHeight: keyHeight);
}
