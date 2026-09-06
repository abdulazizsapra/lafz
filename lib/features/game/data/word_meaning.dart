import 'dart:convert';

import 'package:http/http.dart' as http;

class WordMeaning {
  final String gloss;
  final String? partOfSpeech;

  const WordMeaning({required this.gloss, this.partOfSpeech});

  String get display {
    if (partOfSpeech == null || partOfSpeech!.isEmpty) return gloss;
    return '$partOfSpeech — $gloss';
  }

  static final _htmlTag = RegExp(r'<[^>]+>');
  static final _whitespace = RegExp(r'\s+');

  static String _stripHtml(String raw) {
    return raw
        .replaceAll(_htmlTag, '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(_whitespace, ' ')
        .trim();
  }

  /// First few Urdu (then any-language) glosses from a Wiktionary
  /// REST `/page/definition/{term}` body.
  static WordMeaning? fromWiktionaryJson(String raw) {
    try {
      final data = jsonDecode(raw);
      if (data is! Map<String, dynamic> || data.isEmpty) return null;

      final ur = data['ur'];
      final block = ur is List && ur.isNotEmpty
          ? ur
          : data.values.firstWhere(
              (v) => v is List && v.isNotEmpty,
              orElse: () => null,
            );
      if (block is! List || block.isEmpty) return null;

      final entry = block.first;
      if (entry is! Map<String, dynamic>) return null;
      final defs = entry['definitions'];
      if (defs is! List) return null;

      final glosses = <String>[];
      for (final def in defs) {
        if (def is! Map) continue;
        final text = _stripHtml((def['definition'] as String?) ?? '');
        if (text.isEmpty) continue;
        glosses.add(text);
        if (glosses.length == 3) break;
      }
      if (glosses.isEmpty) return null;

      final pos = (entry['partOfSpeech'] as String?)?.trim();
      return WordMeaning(
        gloss: glosses.join('؛ '),
        partOfSpeech: (pos == null || pos.isEmpty) ? null : pos,
      );
    } catch (_) {
      return null;
    }
  }
}

class WordMeaningLookup {
  static const _endpoint =
      'https://en.wiktionary.org/api/rest_v1/page/definition';

  Future<WordMeaning?> lookup(String word) async {
    final trimmed = word.trim();
    if (trimmed.isEmpty) return null;
    try {
      final uri = Uri.parse('$_endpoint/${Uri.encodeComponent(trimmed)}');
      final res = await http.get(
        uri,
        headers: const {
          'Accept': 'application/json',
          'Api-User-Agent': 'Lafz/1.0 (https://github.com/abdulazizsapra/lafz)',
        },
      ).timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return null;
      return WordMeaning.fromWiktionaryJson(res.body);
    } catch (_) {
      return null;
    }
  }
}
