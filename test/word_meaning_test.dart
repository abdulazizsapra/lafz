import 'package:flutter_test/flutter_test.dart';
import 'package:lafz/features/game/data/word_meaning.dart';

void main() {
  test('prefers the Urdu entry and strips HTML from glosses', () {
    const json = '''
{
  "fa": [{"partOfSpeech":"Noun","language":"Persian","definitions":[{"definition":"<a>existence</a>"}]}],
  "ur": [{"partOfSpeech":"Noun","language":"Urdu","definitions":[
    {"definition":"<a rel=\\"mw:WikiLink\\" href=\\"/wiki/life\\" title=\\"life\\">life</a>"},
    {"definition":"<a>lifetime</a>"}
  ]}]
}
''';

    final meaning = WordMeaning.fromWiktionaryJson(json);

    expect(meaning, isNotNull);
    expect(meaning!.partOfSpeech, 'Noun');
    expect(meaning.gloss, 'life؛ lifetime');
    expect(meaning.gloss.contains('<'), isFalse);
  });

  test('returns null when no definitions exist', () {
    expect(WordMeaning.fromWiktionaryJson('{}'), isNull);
    expect(WordMeaning.fromWiktionaryJson('not-json'), isNull);
  });
}
