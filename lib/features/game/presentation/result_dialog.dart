import 'package:flutter/material.dart';
import 'package:lafz/app/theme/app_colors.dart';
import 'package:lafz/app/typography.dart';
import 'package:lafz/features/game/data/word_meaning.dart';

class ResultDialog extends StatelessWidget {
  final bool isWon;
  final String targetWord;
  final int attempts;
  final WordMeaning? meaning;
  final Future<WordMeaning?>? meaningFuture;
  final VoidCallback onShare;
  final VoidCallback onClose;
  final VoidCallback? onNewWord;

  const ResultDialog({
    super.key,
    required this.isWon,
    required this.targetWord,
    required this.attempts,
    required this.onShare,
    required this.onClose,
    this.onNewWord,
    this.meaning,
    this.meaningFuture,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(
        isWon ? 'شاباش!' : 'افسوس!',
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isWon
                ? 'آپ نے $attempts کوششوں میں یہ لفظ حل کر لیا'
                : 'لفظ تھا',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text(
            targetWord,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: AppTypography.urduFontFamily,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'معنی',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkMutedText
                    : AppColors.lightMutedText,
              ),
            ),
          ),
          const SizedBox(height: 6),
          if (meaning != null)
            _MeaningText(meaning: meaning!)
          else if (meaningFuture != null)
            FutureBuilder<WordMeaning?>(
              future: meaningFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                final found = snapshot.data;
                if (found == null) {
                  return const _MeaningUnavailable();
                }
                return _MeaningText(meaning: found);
              },
            )
          else
            const _MeaningUnavailable(),
        ],
      ),
      actions: [
        TextButton(onPressed: onClose, child: const Text('بند کریں')),
        if (onNewWord != null)
          TextButton(onPressed: onNewWord, child: const Text('نیا لفظ')),
        if (isWon)
          ElevatedButton(onPressed: onShare, child: const Text('شیئر کریں')),
      ],
    );
  }
}

class _MeaningText extends StatelessWidget {
  final WordMeaning meaning;

  const _MeaningText({required this.meaning});

  @override
  Widget build(BuildContext context) {
    return Text(
      meaning.display,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 18, height: 1.5),
    );
  }
}

class _MeaningUnavailable extends StatelessWidget {
  const _MeaningUnavailable();

  @override
  Widget build(BuildContext context) {
    return Text(
      'معنی دستیاب نہیں',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 15,
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkMutedText
            : AppColors.lightMutedText,
      ),
    );
  }
}
