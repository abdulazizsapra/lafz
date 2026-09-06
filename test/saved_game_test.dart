import 'package:flutter_test/flutter_test.dart';
import 'package:lafz/features/game/data/saved_game.dart';

void main() {
  test('SavedGame survives a JSON roundtrip', () {
    final original = SavedGame(
      puzzleId: '2026-09-06',
      guesses: const [
        ['ز', 'ن', 'د', 'گ', 'ی'],
        ['ر', 'و', 'ش', 'ن', 'ی'],
      ],
      currentRow: 2,
      hintsLeft: 1,
      hintedPositions: const [0, 2],
    );

    final restored = SavedGame.decode(original.encode());

    expect(restored.puzzleId, original.puzzleId);
    expect(restored.guesses, original.guesses);
    expect(restored.currentRow, 2);
    expect(restored.hintsLeft, 1);
    expect(restored.hintedPositions, [0, 2]);
  });
}
