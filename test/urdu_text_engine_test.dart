import 'package:flutter_test/flutter_test.dart';
import 'package:lafz/core/utils/urdu_text_engine.dart';
import 'package:lafz/shared/models/urdu_word_models.dart';

void main() {
  group('UrduTextEngine Tests', () {
    final tokenizer = UrduWordTokenizer();
    final normalizer = UrduNormalizer();

    test('Tokenizer should correctly split basic Urdu words', () {
      const word = 'کتاب'; // K-T-A-B (4 units)
      final units = tokenizer.tokenize(word, normalizer);
      expect(units.length, 4);
    });

    test('Tokenizer should handle diacritics as part of the unit or separate based on grapheme', () {
      // Example with Zabar: کِتاب (K with Zer)
      const word = 'کِتاب'; 
      final units = tokenizer.tokenize(word, normalizer);
      // In 'characters' package, combining marks are part of the preceding grapheme
      expect(units.length, 4);
    });

    test('ComparisonKey should strip diacritics', () {
      const unitWithDiacritic = 'کِ'; // K with Zer
      final key = normalizer.toComparisonKey(unitWithDiacritic);
      expect(key, 'ک');
    });

    test('Two units with different diacritics but same base should be equal', () {
      final unit1 = UrduUnit(display: 'کَ', normalized: 'کَ', comparisonKey: normalizer.toComparisonKey('کَ'));
      final unit2 = UrduUnit(display: 'کِ', normalized: 'کِ', comparisonKey: normalizer.toComparisonKey('کِ'));
      
      expect(unit1, unit2);
    });
  });
}
