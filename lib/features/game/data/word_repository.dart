import 'dart:async';
import 'dart:convert';

import 'package:characters/characters.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:lafz/app/app_config.dart';
import 'package:lafz/shared/models/game_models.dart';

/// Source of daily puzzles: bundled word list first, remote endpoint
/// ([AppConfig.remotePuzzleUrl]) when configured and reachable.
class WordRepository {
  static const String _bundledPath = 'assets/words/urdu_5letter.txt';
  static const int wordLength = 5;

  List<String>? _cachedWords;

  /// Bundled 5-letter words, cached after first load.
  Future<List<String>> loadBundledWords() async {
    if (_cachedWords != null) return _cachedWords!;
    final raw = await rootBundle.loadString(_bundledPath);
    final words = raw
        .split('\n')
        .map((w) => w.trim())
        .where((w) => w.characters.length == wordLength)
        .toList();
    if (words.isEmpty) {
      throw StateError('No words in $_bundledPath');
    }
    _cachedWords = words;
    return words;
  }

  /// Deterministic daily pick: day index since epoch modulo list length,
  /// so every player gets the same word each day.
  Puzzle dailyPuzzleFrom(List<String> words, DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final epoch = DateTime(2026, 1, 1);
    final index = day.difference(epoch).inDays % words.length;
    final word = words[index < 0 ? index + words.length : index];
    final id =
        '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    return Puzzle(
      id: id,
      date: day,
      word: word,
      wordLength: word.characters.length,
    );
  }

  /// Remote word, or null when disabled/unreachable/invalid.
  /// Expected JSON: {"word": "...", "id": "..."} (id optional).
  Future<Puzzle?> fetchRemotePuzzle(DateTime date) async {
    final url = AppConfig.remotePuzzleUrl;
    if (url.isEmpty) return null;
    try {
      final res = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final word = (data['word'] as String? ?? '').trim();
      if (word.characters.length != wordLength) return null;
      return Puzzle(
        id: (data['id'] as String?) ?? 'remote',
        date: date,
        word: word,
        wordLength: word.characters.length,
      );
    } catch (_) {
      return null;
    }
  }

  /// Today's puzzle: remote first, bundled daily pick as fallback.
  Future<Puzzle> getTodayPuzzle([DateTime? now]) async {
    final date = now ?? DateTime.now();
    final remote = await fetchRemotePuzzle(date);
    if (remote != null) return remote;
    final words = await loadBundledWords();
    return dailyPuzzleFrom(words, date);
  }
}
