import 'package:flutter_test/flutter_test.dart';
import 'package:lafz/features/game/domain/game_engine.dart';
import 'package:lafz/features/game/presentation/game_controller.dart';
import 'package:lafz/features/statistics/data/statistics_repository.dart';
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

  test('reset starts a new word with an empty board and no extra loss',
      () async {
    final controller = GameController(
      puzzle(),
      validWords: const ['زندگی', 'روشنی', 'آفتاب'],
    );
    await controller.submitGuess(word('روشنی'));
    expect(controller.state.currentRow, 1);

    final next = Puzzle(
      id: 'practice-آفتاب',
      date: DateTime(2026, 9, 6),
      word: 'آفتاب',
      wordLength: 5,
    );
    await controller.startNewPuzzle(next);

    expect(controller.state.puzzle.word, 'آفتاب');
    expect(controller.state.currentRow, 0);
    expect(controller.state.guesses, isEmpty);
    expect(controller.state.evaluations, isEmpty);
    expect(controller.state.isGameOver, isFalse);
    expect(controller.state.hintsLeft, 3);

    final restored = GameController(puzzle());
    await restored.loadSavedGame();
    expect(restored.state.guesses, isEmpty);

    final stats = await StatisticsRepository().getStats();
    expect(stats.gamesPlayed, 0);
  });

  test('unknown word does not consume a row', () async {
    final controller = GameController(
      puzzle(),
      validWords: const ['زندگی', 'روشنی'],
    );

    final result = await controller.submitGuess(word('ابابا'));

    expect(result, GuessSubmitResult.notInWordList);
    expect(controller.state.currentRow, 0);
    expect(controller.state.guesses, isEmpty);
    expect(controller.state.isGameOver, isFalse);
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
