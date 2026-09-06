import 'package:flutter/material.dart';
import 'package:lafz/shared/models/game_models.dart';

class ResultDialog extends StatelessWidget {
  final bool isWon;
  final String targetWord;
  final int attempts;
  final VoidCallback onShare;
  final VoidCallback onClose;

  const ResultDialog({
    super.key,
    required this.isWon,
    required this.targetWord,
    required this.attempts,
    required this.onShare,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isWon ? 'شاباش!' : 'افسوس!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isWon 
              ? 'آپ نے $attempts کوششوں میں لفظ حل کر لیا' 
              : 'آج کا لفظ تھا: $targetWord',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: onClose, child: const Text('بند کریں')),
        if (isWon)
          ElevatedButton(onPressed: onShare, child: const Text('شیئر کریں')),
      ],
    );
  }
}
