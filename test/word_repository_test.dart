import 'package:flutter_test/flutter_test.dart';
import 'package:lafz/features/game/data/word_repository.dart';

void main() {
  test('random puzzle skips the excluded word', () {
    final repo = WordRepository();
    const words = ['زندگی', 'روشنی', 'آفتاب'];

    for (var seed = 0; seed < 20; seed++) {
      final puzzle = repo.randomPuzzleFrom(
        words,
        excludeWord: 'زندگی',
        seed: seed,
      );
      expect(puzzle.word, isNot('زندگی'));
      expect(words, contains(puzzle.word));
      expect(puzzle.id, startsWith('practice-'));
    }
  });
}
