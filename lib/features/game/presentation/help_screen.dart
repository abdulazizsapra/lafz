import 'package:flutter/material.dart';
import 'package:lafz/shared/models/game_models.dart';
import 'package:lafz/shared/widgets/game_tile.dart';
import 'package:lafz/shared/widgets/wordle_header.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              WordleHeader(
                title: 'کیسے کھیلیں',
                leading: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'پانچ حرفی لفظ لکھ کر جمع کریں دبائیں۔ رنگ بتائیں گے آپ کتنے قریب ہیں:',
                        style: TextStyle(fontSize: 17, height: 1.5),
                      ),
                      SizedBox(height: 28),
                      _ExampleRow(
                        letters: ['ز', 'ن', 'د', 'گ', 'ی'],
                        states: [
                          TileState.correct,
                          TileState.empty,
                          TileState.empty,
                          TileState.empty,
                          TileState.empty,
                        ],
                        caption: 'ز درست حرف ہے اور درست جگہ پر ہے۔',
                      ),
                      SizedBox(height: 22),
                      _ExampleRow(
                        letters: ['ہ', 'م', 'ر', 'ا', 'ہ'],
                        states: [
                          TileState.empty,
                          TileState.present,
                          TileState.empty,
                          TileState.empty,
                          TileState.empty,
                        ],
                        caption: 'م لفظ میں ہے مگر جگہ غلط ہے۔',
                      ),
                      SizedBox(height: 22),
                      _ExampleRow(
                        letters: ['ک', 'ت', 'ا', 'ب', 'ی'],
                        states: [
                          TileState.empty,
                          TileState.empty,
                          TileState.empty,
                          TileState.absent,
                          TileState.empty,
                        ],
                        caption: 'ب لفظ میں موجود نہیں۔',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExampleRow extends StatelessWidget {
  final List<String> letters;
  final List<TileState> states;
  final String caption;

  const _ExampleRow({
    required this.letters,
    required this.states,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 48,
          child: Row(
            children: [
              for (var i = 0; i < letters.length; i++) ...[
                if (i > 0) const SizedBox(width: 5),
                SizedBox(
                  width: 48,
                  child: GameTile(letter: letters[i], state: states[i]),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(caption, style: const TextStyle(fontSize: 16, height: 1.4)),
      ],
    );
  }
}
