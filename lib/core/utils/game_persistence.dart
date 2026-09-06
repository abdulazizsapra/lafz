import 'package:shared_preferences/shared_preferences.dart';

import 'package:lafz/core/utils/cookie_store.dart';
import 'package:lafz/features/game/data/saved_game.dart';

/// Persists the in-progress daily game.
/// Web writes a cookie (`lafz_game`) so progress survives reloads;
/// SharedPreferences is the fallback on every platform.
class GamePersistenceService {
  static const String storageKey = 'lafz_game';

  Future<void> saveGame(SavedGame game) async {
    final encoded = game.encode();
    writeCookie(storageKey, encoded);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, encoded);
  }

  Future<SavedGame?> loadGame() async {
    final fromCookie = readCookie(storageKey);
    if (fromCookie != null && fromCookie.isNotEmpty) {
      try {
        return SavedGame.decode(fromCookie);
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return SavedGame.decode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearGame() async {
    deleteCookie(storageKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
    await prefs.remove('lafz_current_game');
    await prefs.remove('lafz_row');
  }
}
