import 'package:flutter/material.dart';
import 'package:lafz/features/statistics/data/statistics_repository.dart';
import 'package:lafz/features/game/presentation/game_controller.dart';

class StatisticsScreen extends StatelessWidget {
  final GameController controller;
  final Statistics stats;

  const StatisticsScreen({super.key, required this.controller, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اعداد و شمار')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildStatRow('کھیلے گئے کھیل', stats.gamesPlayed.toString()),
              _buildStatRow('جیتے گئے کھیل', stats.gamesWon.toString()),
              _buildStatRow('موجودہ سلسلہ', '${stats.currentStreak} 🔥'),
              _buildStatRow('زیادہ سے زیادہ سلسلہ', stats.maxStreak.toString()),
              const SizedBox(height: 30),
              const Text('توجیع', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ...List.generate(6, (i) {
                final count = stats.guessDistribution[i + 1] ?? 0;
                return _buildDistributionRow(i + 1, count);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 18)),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDistributionRow(int guessNum, int count) {
    return Row(
      children: [
        Text('$guessNum ', style: const TextStyle(fontSize: 16)),
        Expanded(
          child: LinearProgressIndicator(
            value: count == 0 ? 0 : (count / 10).clamp(0.0, 1.0),
            backgroundColor: Colors.grey[300],
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 10),
        Text('$count', style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
