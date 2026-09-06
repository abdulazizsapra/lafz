import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lafz/features/game/data/word_meaning.dart';
import 'package:lafz/features/game/presentation/result_dialog.dart';

void main() {
  testWidgets('win dialog teaches the meaning of the solved word', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ResultDialog(
          isWon: true,
          targetWord: 'زندگی',
          attempts: 2,
          meaning: const WordMeaning(gloss: 'life؛ lifetime', partOfSpeech: 'Noun'),
          onShare: () {},
          onClose: () {},
        ),
      ),
    );

    expect(find.text('زندگی'), findsOneWidget);
    expect(find.text('معنی'), findsOneWidget);
    expect(find.text('Noun — life؛ lifetime'), findsOneWidget);
  });
}
