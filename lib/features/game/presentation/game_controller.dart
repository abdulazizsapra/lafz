import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lafz/shared/models/game_models.dart';
import 'package:lafz/shared/models/urdu_word_models.dart';
import 'package:lafz/features/game/domain/game_engine.dart';
import 'package:lafz/features/statistics/data/statistics_repository.dart';
import 'package:lafz/core/utils/game_persistence.dart';

class HintResult {
  final int position; // 0-based index into the target word
  final String letter; // display grapheme at that position
  final int hintsLeft;

  HintResult({
    required this.position,
    required this.letter,
    required this.hintsLeft,
  });
}

class GameState {
  final Puzzle puzzle;
  final List<List<UrduUnit>> guesses;
  final List<GuessEvaluation> evaluations;
  final int currentRow;
  final bool isGameOver;
  final bool isWon;
  final int hintsLeft;
  final List<int> hintedPositions;

  GameState({
    required this.puzzle,
    required this.guesses,
    required this.evaluations,
    required this.currentRow,
    required this.isGameOver,
    required this.isWon,
    this.hintsLeft = 3,
    this.hintedPositions = const [],
  });

  GameState copyWith({
    List<List<UrduUnit>>? guesses,
    List<GuessEvaluation>? evaluations,
    int? currentRow,
    bool? isGameOver,
    bool? isWon,
    int? hintsLeft,
    List<int>? hintedPositions,
  }) {
    return GameState(
      puzzle: puzzle,
      guesses: guesses ?? this.guesses,
      evaluations: evaluations ?? this.evaluations,
      currentRow: currentRow ?? this.currentRow,
      isGameOver: isGameOver ?? this.isGameOver,
      isWon: isWon ?? this.isWon,
      hintsLeft: hintsLeft ?? this.hintsLeft,
      hintedPositions: hintedPositions ?? this.hintedPositions,
    );
  }
}

class GameController {
  final GameEngine _engine = GameEngine();
  final StatisticsRepository _statsRepo = StatisticsRepository();
  final GamePersistenceService _persistence = GamePersistenceService();
  final int maxAttempts = 5;

  GameState _state;
  final ValueNotifier<GameState> stateNotifier = ValueNotifier(
    GameState(
      puzzle: Puzzle(id: '1', date: DateTime.now(), word: 'زندگی', wordLength: 5),
      guesses: [],
      evaluations: [],
      currentRow: 0,
      isGameOver: false,
      isWon: false,
    )
  );

  GameController(Puzzle puzzle) : _state = GameState(
    puzzle: puzzle,
    guesses: [],
    evaluations: [],
    currentRow: 0,
    isGameOver: false,
    isWon: false,
  ) {
    stateNotifier.value = _state;
  }

  GameState get state => _state;

  Future<void> loadSavedGame() async {
    final saved = await _persistence.loadGame();
    if (saved == null) return;

    // TODO: persist/restore guess units properly (currently saved as
    // toString, unparseable). Until then, never restore a currentRow
    // beyond the guesses actually in memory - otherwise the grid
    // indexes empty lists and throws RangeError on startup.
    final savedRow = saved['currentRow'] as int? ?? 0;
    final safeRow = savedRow.clamp(0, _state.guesses.length);
    _state = _state.copyWith(
      currentRow: safeRow,
    );
    stateNotifier.value = _state;
  }

  /// Reveals the leftmost not-yet-hinted target letter. Returns null
  /// when the game is over or no hints remain.
  HintResult? useHint() {
    if (_state.isGameOver || _state.hintsLeft <= 0) return null;

    final target = _engine.tokenizer.tokenize(
      _state.puzzle.word,
      _engine.normalizer,
    );
    int? pos;
    for (var i = 0; i < target.length; i++) {
      if (!_state.hintedPositions.contains(i)) {
        pos = i;
        break;
      }
    }
    if (pos == null) return null;

    _state = _state.copyWith(
      hintsLeft: _state.hintsLeft - 1,
      hintedPositions: [..._state.hintedPositions, pos],
    );
    stateNotifier.value = _state;

    return HintResult(
      position: pos,
      letter: target[pos].display,
      hintsLeft: _state.hintsLeft,
    );
  }

  Future<void> submitGuess(UrduWord guess) async {
    if (_state.isGameOver) return;

    final target = UrduWord(
      original: _state.puzzle.word,
      units: _engine.tokenizer.tokenize(_state.puzzle.word, _engine.normalizer),
    );

    final evaluation = _engine.evaluateGuess(target, guess);
    
    final newGuesses = List<List<UrduUnit>>.from(_state.guesses);
    newGuesses.add(guess.units);

    final newEvaluations = List<GuessEvaluation>.from(_state.evaluations);
    newEvaluations.add(evaluation);

    final nextRow = _state.currentRow + 1;
    final isGameOver = nextRow >= maxAttempts || evaluation.isCorrect;
    final isWon = evaluation.isCorrect;

    _state = _state.copyWith(
      guesses: newGuesses,
      evaluations: newEvaluations,
      currentRow: nextRow,
      isGameOver: isGameOver,
      isWon: isWon,
    );
    
    stateNotifier.value = _state;

    // Persistence: Save current progress
    await _persistence.saveGame(
      _state.puzzle, 
      newGuesses.map((g) => g.map((u) => u.display).toList()).toList(), 
      _state.currentRow
    );

    if (isGameOver) {
      await _updateStatistics(isWon, evaluation.states.length);
      await _persistence.clearGame();
    }
  }

  Future<void> _updateStatistics(bool won, int attempts) async {
    final stats = await _statsRepo.getStats();
    
    int newPlayed = stats.gamesPlayed + 1;
    int newWon = won ? stats.gamesWon + 1 : stats.gamesWon;
    int newStreak = won ? stats.currentStreak + 1 : 0;
    int newMaxStreak = newStreak > stats.maxStreak ? newStreak : stats.maxStreak;
    
    Map<int, int> newDist = Map<int, int>.from(stats.guessDistribution);
    newDist[attempts] = (newDist[attempts] ?? 0) + 1;

    await _statsRepo.saveStats(stats.copyWith(
      gamesPlayed: newPlayed,
      gamesWon: newWon,
      currentStreak: newStreak,
      maxStreak: newMaxStreak,
      guessDistribution: newDist,
    ));
  }
}
