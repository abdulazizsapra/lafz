enum TileState {
  empty,
  filled,
  correct,
  present,
  absent,
}

class GuessEvaluation {
  final List<TileState> states;
  final bool isCorrect;

  GuessEvaluation({
    required this.states,
    required this.isCorrect,
  });
}

class Puzzle {
  final String id;
  final DateTime date;
  final String word;
  final int wordLength;
  final String? meaning;

  Puzzle({
    required this.id,
    required this.date,
    required this.word,
    required this.wordLength,
    this.meaning,
  });
}
