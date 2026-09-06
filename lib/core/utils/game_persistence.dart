import 'package:shared_preferences/shared_preferences.dart';
import 'package:lafz/shared/models/game_models.dart';

class GamePersistenceService {
  static const String _gameStateKey = 'lafz_current_game';

  Future<void> saveGame(Puzzle puzzle, List<List<String>> guesses, int currentRow) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'puzzleId': puzzle.id,
      'guesses': guesses,
      'currentRow': currentRow,
      'timestamp': DateTime.now().toIso8601String(),
    };
    // Simplified for MVP: store as strings
    await prefs.setString(_gameStateKey, guesses.toString());
    await prefs.setInt('lafz_row', currentRow);
  }

  Future<Map<String, dynamic>?> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_gameStateKey)) return null;
    
    return {
      'guesses': prefs.getString(_gameStateKey),
      'currentRow': prefs.getInt('lafz_row') ?? 0,
    };
  }

  Future<void> clearGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gameStateKey);
    await prefs.remove('lafz_row');
  }
}
