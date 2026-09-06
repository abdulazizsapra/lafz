import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lafz/shared/models/game_models.dart';
import 'package:lafz/shared/models/urdu_word_models.dart';
import 'package:lafz/features/game/domain/game_engine.dart';
import 'package:lafz/features/statistics/data/statistics_repository.dart';
import 'package:lafz/core/utils/game_persistence.dart';
import 'package:lafz/features/game/data/saved_game.dart';

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

enum GuessSubmitResult {
  accepted,
  notInWordList,
  ignored,
}

class GameController {
  final GameEngine _engine = GameEngine();
  final StatisticsRepository _statsRepo = StatisticsRepository();
  final GamePersistenceService _persistence = GamePersistenceService();
  final int maxAttempts = 5;
  final Set<String> _validKeys;

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

  GameController(Puzzle puzzle, {Iterable<String> validWords = const []})
      : _validKeys = {},
        _state = GameState(
          puzzle: puzzle,
          guesses: [],
          evaluations: [],
          currentRow: 0,
          isGameOver: false,
          isWon: false,
        ) {
    for (final word in validWords) {
      _validKeys.add(_keyFor(word));
    }
    stateNotifier.value = _state;
  }

  String _keyFor(String text) {
    return text.characters
        .map((g) => _engine.normalizer.toComparisonKey(_engine.normalizer.normalize(g)))
        .join();
  }

  bool _isKnownWord(UrduWord guess) {
    if (_validKeys.isEmpty) return true;
    return _validKeys.contains(
      guess.units.map((u) => u.comparisonKey).join(),
    );
  }

  GameState get state => _state;

  Future<void> startNewPuzzle(Puzzle puzzle) async {
    await _persistence.clearGame();
    _state = GameState(
      puzzle: puzzle,
      guesses: [],
      evaluations: [],
      currentRow: 0,
      isGameOver: false,
      isWon: false,
    );
    stateNotifier.value = _state;
  }

  Future<void> loadSavedGame() async {
    final saved = await _persistence.loadGame();
    if (saved == null || saved.puzzleId != _state.puzzle.id) return;

    final target = UrduWord(
      original: _state.puzzle.word,
      units: _engine.tokenizer.tokenize(_state.puzzle.word, _engine.normalizer),
    );

    final guesses = <List<UrduUnit>>[];
    final evaluations = <GuessEvaluation>[];
    for (final row in saved.guesses) {
      final guess = UrduWord(
        original: row.join(),
        units: row
            .map(
              (letter) => _engine.tokenizer
                  .tokenize(letter, _engine.normalizer)
                  .first,
            )
            .toList(),
      );
      if (guess.length != target.length) continue;
      guesses.add(guess.units);
      evaluations.add(_engine.evaluateGuess(target, guess));
    }

    final isWon = evaluations.isNotEmpty && evaluations.last.isCorrect;
    final isGameOver = isWon || guesses.length >= maxAttempts;

    _state = _state.copyWith(
      guesses: guesses,
      evaluations: evaluations,
      currentRow: guesses.length,
      isGameOver: isGameOver,
      isWon: isWon,
      hintsLeft: saved.hintsLeft,
      hintedPositions: saved.hintedPositions,
    );
    stateNotifier.value = _state;
  }

  Future<void> _persist() async {
    if (_state.isGameOver) {
      await _persistence.clearGame();
      return;
    }
    await _persistence.saveGame(
      SavedGame(
        puzzleId: _state.puzzle.id,
        guesses: _state.guesses
            .map((row) => row.map((u) => u.display).toList())
            .toList(),
        currentRow: _state.currentRow,
        hintsLeft: _state.hintsLeft,
        hintedPositions: _state.hintedPositions,
      ),
    );
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
    _persist();

    return HintResult(
      position: pos,
      letter: target[pos].display,
      hintsLeft: _state.hintsLeft,
    );
  }

  Future<GuessSubmitResult> submitGuess(UrduWord guess) async {
    if (_state.isGameOver) return GuessSubmitResult.ignored;
    if (!_isKnownWord(guess)) return GuessSubmitResult.notInWordList;

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

    await _persist();

    if (isGameOver) {
      await _updateStatistics(isWon, evaluation.states.length);
    }
    return GuessSubmitResult.accepted;
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
