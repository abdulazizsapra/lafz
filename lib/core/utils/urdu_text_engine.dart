import 'package:characters/characters.dart';
import '../../shared/models/urdu_word_models.dart';

class UrduWordTokenizer {
  List<UrduUnit> tokenize(String text, UrduNormalizer normalizer) {
    final graphemes = text.characters.toList();
    final List<UrduUnit> units = [];

    for (var g in graphemes) {
      final normalized = normalizer.normalize(g);
      units.add(
        UrduUnit(
          display: g,
          normalized: normalized,
          comparisonKey: normalizer.toComparisonKey(normalized),
        ),
      );
    }
    return units;
  }
}

class UrduNormalizer {
  /// Normalizes a single Urdu unit for consistent comparison.
  /// Maps common Arabic-script variants to their Urdu forms so that,
  /// e.g., Arabic Yeh (ي U+064A) and Arabic Kaf (ك U+0643) typed from
  /// any keyboard still match Urdu Yeh (ی U+06CC) / Kaf (ک U+06A9).
  String normalize(String unit) {
    String result = unit;
    result = result.replaceAll('ي', 'ی'); // Arabic Yeh -> Urdu Yeh
    result = result.replaceAll('ك', 'ک'); // Arabic Kaf -> Urdu Kaf
    result = result.replaceAll('أ', 'ا'); // Alef with hamza above -> Alef
    result = result.replaceAll('إ', 'ا'); // Alef with hamza below -> Alef
    return result;
  }

  /// Produces a deterministic key for engine comparison, stripping diacritics if the game rules allow.
  String toComparisonKey(String normalizedUnit) {
    // For Wordle-like games, we typically ignore diacritics (Zabar, Zer, Pesh)
    // to make the game playable and fair.
    return _stripDiacritics(normalizedUnit);
  }

  String _stripDiacritics(String text) {
    // Urdu diacritics range: U+064B to U+0652
    final diacriticsRegex = RegExp(r'[\u064B-\u0652]');
    return text.replaceAll(diacriticsRegex, '');
  }
}
