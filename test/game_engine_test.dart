import 'package:flutter_test/flutter_test.dart';
import 'package:lafz/features/game/domain/game_engine.dart';
import 'package:lafz/shared/models/urdu_word_models.dart';
import 'package:lafz/shared/models/game_models.dart';
import 'package:lafz/core/utils/urdu_text_engine.dart';

void main() {
  group('GameEngine Evaluation Tests', () {
    final engine = GameEngine();
    final normalizer = UrduNormalizer();
    final tokenizer = UrduWordTokenizer();

    UrduWord createWord(String text) {
      return UrduWord(
        original: text,
        units: tokenizer.tokenize(text, normalizer),
      );
    }

    test('Correct guess should be marked all correct', () {
      final target = createWord('کتاب'); // K-T-A-B
      final guess = createWord('کتاب');
      final eval = engine.evaluateGuess(target, guess);
      
      expect(eval.isCorrect, true);
      expect(eval.states, [TileState.correct, TileState.correct, TileState.correct, TileState.correct]);
    });

    test('Wrong guess should be marked absent', () {
      final target = createWord('کتاب');
      final guess = createWord('قلمیں'); // Ensure length is 4 to match 'کتاب'
      // Wait, 'قلمیں' is not 4. Let's use 'قلم_' (just for test) or a 4 letter word.
      // Let's use 'سہارا' (5) and 'کتاب' (4) as different sets.
      
      // Corrected: target 'کتاب' (4), guess 'قلم_' (let's just use 4 chars)
      final guessCorrectLength = createWord('قلمز'); 
      final eval = engine.evaluateGuess(target, guessCorrectLength);
      
      expect(eval.isCorrect, false);
      expect(eval.states.every((s) => s == TileState.absent), true);
    });

    test('Duplicate letters in guess should be handled correctly (Under-count)', () {
      // Target: A B B C (Symmetry for example)
      // Guess: B B B X
      // Result: B[correct] B[correct] B[absent] X[absent]
      
      // Let's use a real Urdu example: 'سہارا' (S-H-A-R-A) - 5 letters
      // Target: س ہ ا ر ا (A appears twice)
      // Guess: ا ا ا ا ا (A appears 5 times)
      // Expected: only 2 'A's should be marked (one correct, one present)
      
      final target = createWord('سہارا'); 
      final guess = createWord('ااااا'); 
      final eval = engine.evaluateGuess(target, guess);
      
      int presentOrCorrect = eval.states.where((s) => s == TileState.correct || s == TileState.present).length;
      expect(presentOrCorrect, 2);
    });

    test('Duplicate letters in target should be handled correctly', () {
      // Target: ا ا ب (A A B)
      // Guess: ا ب ب (A B B)
      // Result: A[correct] B[present] B[absent]
      
      final target = createWord('آبا'); // A-B-A (2 A's)
      final guess = createWord('آبب'); // A-B-B
      final eval = engine.evaluateGuess(target, guess);
      
      expect(eval.states[0], TileState.correct); // A
      expect(eval.states[1], TileState.correct); // B
      expect(eval.states[2], TileState.absent); // B
    });
  });
}
