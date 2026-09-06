import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lafz/shared/models/game_models.dart';

class ShareResultService {
  static String formatResult(Puzzle puzzle, int attempts, List<List<TileState>> history, int maxAttempts) {
    String result = 'لفظ #${puzzle.id} — $attempts/$maxAttempts\n';
    for (var row in history) {
      String rowStr = '';
      for (var state in row) {
        if (state == TileState.correct) rowStr += '🟩';
        else if (state == TileState.present) rowStr += '🟨';
        else rowStr += '⬜';
      }
      result += '$rowStr\n';
    }
    result += '"روز کا لفظ"';
    return result;
  }

  static void share(String text) {
    Share.share(text);
  }
}
