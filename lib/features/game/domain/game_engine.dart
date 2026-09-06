import 'package:lafz/shared/models/game_models.dart';
import 'package:lafz/shared/models/urdu_word_models.dart';
import 'package:lafz/core/utils/urdu_text_engine.dart';

class GameEngine {
  final UrduWordTokenizer tokenizer = UrduWordTokenizer();
  final UrduNormalizer normalizer = UrduNormalizer();

  GuessEvaluation evaluateGuess(UrduWord target, UrduWord guess) {
    if (target.length != guess.length) {
      throw ArgumentError('Target and guess words must have the same length');
    }
    final int length = target.length;
    final List<TileState> states = List.filled(length, TileState.absent);
    final List<bool> targetUsed = List.filled(length, false);
    final List<bool> guessUsed = List.filled(length, false);

    // Pass 1: Mark exact matches (Correct)
    for (int i = 0; i < length; i++) {
      if (target.units[i].comparisonKey == guess.units[i].comparisonKey) {
        states[i] = TileState.correct;
        targetUsed[i] = true;
        guessUsed[i] = true;
      }
    }

    // Pass 2: Mark present but wrong position (Present)
    for (int i = 0; i < length; i++) {
      if (guessUsed[i]) continue;

      for (int j = 0; j < length; j++) {
        if (!targetUsed[j] && 
            target.units[j].comparisonKey == guess.units[i].comparisonKey) {
          states[i] = TileState.present;
          targetUsed[j] = true;
          guessUsed[i] = true;
          break;
        }
      }
    }

    bool isCorrect = states.every((state) => state == TileState.correct);

    return GuessEvaluation(
      states: states,
      isCorrect: isCorrect,
    );
  }
}
