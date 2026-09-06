import 'dart:convert';

/// Serializable mid-game progress for one daily puzzle.
class SavedGame {
  final String puzzleId;
  final List<List<String>> guesses;
  final int currentRow;
  final int hintsLeft;
  final List<int> hintedPositions;

  const SavedGame({
    required this.puzzleId,
    required this.guesses,
    required this.currentRow,
    this.hintsLeft = 3,
    this.hintedPositions = const [],
  });

  Map<String, dynamic> toJson() => {
        'puzzleId': puzzleId,
        'guesses': guesses,
        'currentRow': currentRow,
        'hintsLeft': hintsLeft,
        'hintedPositions': hintedPositions,
      };

  factory SavedGame.fromJson(Map<String, dynamic> json) {
    final rawGuesses = json['guesses'] as List<dynamic>? ?? const [];
    return SavedGame(
      puzzleId: (json['puzzleId'] as String?) ?? '',
      guesses: rawGuesses
          .map((row) => (row as List<dynamic>).map((c) => c.toString()).toList())
          .toList(),
      currentRow: json['currentRow'] as int? ?? 0,
      hintsLeft: json['hintsLeft'] as int? ?? 3,
      hintedPositions: (json['hintedPositions'] as List<dynamic>? ?? const [])
          .map((e) => (e as num).toInt())
          .toList(),
    );
  }

  String encode() => jsonEncode(toJson());

  factory SavedGame.decode(String raw) {
    return SavedGame.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
