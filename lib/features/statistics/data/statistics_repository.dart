import 'dart:convert';
import 'package:lafz/core/utils/lafz_kv.dart';

class Statistics {
  final int gamesPlayed;
  final int gamesWon;
  final int currentStreak;
  final int maxStreak;
  final Map<int, int> guessDistribution;

  Statistics({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.guessDistribution = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'currentStreak': currentStreak,
      'maxStreak': maxStreak,
      'guessDistribution': guessDistribution,
    };
  }

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      gamesPlayed: json['gamesPlayed'] ?? 0,
      gamesWon: json['gamesWon'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      maxStreak: json['maxStreak'] ?? 0,
      guessDistribution: {
        for (final entry
            in (json['guessDistribution'] as Map? ?? {}).entries)
          int.parse(entry.key.toString()): (entry.value as num).toInt(),
      },
    );
  }

  Statistics copyWith({
    int? gamesPlayed,
    int? gamesWon,
    int? currentStreak,
    int? maxStreak,
    Map<int, int>? guessDistribution,
  }) {
    return Statistics(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      guessDistribution: guessDistribution ?? this.guessDistribution,
    );
  }
}

class StatisticsRepository {
  static const String _key = 'lafz_stats';

  Future<Statistics> getStats() async {
    final data = await LafzKv.getString(_key);
    if (data == null) return Statistics();
    try {
      return Statistics.fromJson(jsonDecode(data));
    } catch (_) {
      return Statistics();
    }
  }

  Future<void> saveStats(Statistics stats) async {
    await LafzKv.setString(_key, jsonEncode(stats.toJson()));
  }
}
