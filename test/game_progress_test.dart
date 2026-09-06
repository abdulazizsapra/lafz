import 'package:flutter_test/flutter_test.dart';
import 'package:lafz/features/game/domain/game_engine.dart';
import 'package:lafz/features/game/presentation/game_controller.dart';
import 'package:lafz/shared/models/game_models.dart';
import 'package:lafz/shared/models/urdu_word_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final engine = GameEngine();

  UrduWord word(String text) {
    return UrduWord(
      original: text,
      units: engine.tokenizer.tokenize(text, engine.normalizer),
    );
  }

  Puzzle puzzle() => Puzzle(
        id: '2026-09-06',
        date: DateTime(2026, 9, 6),
        word: 'زندگی',
        wordLength: 5,
      );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('reload restores submitted guesses and evaluations for the same puzzle',
      () async {
    final first = GameController(puzzle());
    await first.submitGuess(word('روشنی'));

    final second = GameController(puzzle());
    await second.loadSavedGame();

    expect(second.state.currentRow, 1);
    expect(second.state.guesses, hasLength(1));
    expect(second.state.guesses.first.map((u) => u.display).join(), 'روشنی');
    expect(second.state.evaluations, hasLength(1));
    expect(second.state.evaluations.first.isCorrect, isFalse);
    expect(second.state.evaluations.first.states, isNotEmpty);
  });

  test('reload ignores a save from a different puzzle day', () async {
    final first = GameController(puzzle());
    await first.submitGuess(word('روشنی'));

    final tomorrow = Puzzle(
      id: '2026-09-07',
      date: DateTime(2026, 9, 7),
      word: 'آفتاب',
      wordLength: 5,
    );
    final second = GameController(tomorrow);
    await second.loadSavedGame();

    expect(second.state.currentRow, 0);
    expect(second.state.guesses, isEmpty);
  });
}
