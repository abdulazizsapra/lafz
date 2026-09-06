import 'package:flutter/material.dart';
import 'package:lafz/app/app_config.dart';
import 'package:lafz/features/game/presentation/game_controller.dart';
import 'package:lafz/features/game/domain/game_engine.dart';
import 'package:lafz/shared/models/game_models.dart';
import 'package:lafz/shared/models/urdu_word_models.dart';
import 'package:lafz/shared/widgets/game_tile.dart';
import 'package:lafz/shared/widgets/urdu_keyboard.dart';
import 'package:lafz/core/utils/urdu_text_engine.dart';
import 'package:lafz/features/game/presentation/help_screen.dart';
import 'package:lafz/features/game/presentation/result_dialog.dart';
import 'package:lafz/features/statistics/presentation/statistics_screen.dart';
import 'package:lafz/features/sharing/services/share_result_service.dart';
import 'package:lafz/features/statistics/data/statistics_repository.dart';
import 'package:lafz/features/game/data/word_repository.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameController? _controller;
  GameController get _c => _controller!;
  final WordRepository _words = WordRepository();
  String _currentGuess = '';
  final UrduWordTokenizer _tokenizer = UrduWordTokenizer();
  final UrduNormalizer _normalizer = UrduNormalizer();
  final StatisticsRepository _statsRepo = StatisticsRepository();

  @override
  void initState() {
    super.initState();
    _loadPuzzle();
  }

  Future<void> _loadPuzzle() async {
    try {
      final puzzle = await _words.getTodayPuzzle();
      if (!mounted) return;
      final controller = GameController(puzzle);
      await controller.loadSavedGame();
      if (!mounted) return;
      setState(() => _controller = controller);
    } catch (_) {
      if (!mounted) return;
      // Last-resort fallback so the game is always playable offline.
      final fallback = Puzzle(
        id: 'fallback',
        date: DateTime.now(),
        word: 'زندگی',
        wordLength: 5,
      );
      setState(() => _controller = GameController(fallback));
    }
  }

  void _handleKeyTap(String key) {
    if (_c.state.isGameOver) return;
    if (_currentGuess.characters.length < _c.state.puzzle.wordLength) {
      setState(() {
        _currentGuess += key;
      });
    }
  }

  void _handleBackspace() {
    if (_c.state.isGameOver) return;
    if (_currentGuess.isNotEmpty) {
      setState(() {
        _currentGuess = _currentGuess.substring(0, _currentGuess.length - 1);
      });
    }
  }

  void _handleEnter() {
    if (_c.state.isGameOver) return;
    if (_currentGuess.characters.length == _c.state.puzzle.wordLength) {
      final guessWord = UrduWord(
        original: _currentGuess,
        units: _tokenizer.tokenize(_currentGuess, _normalizer),
      );
      setState(() {
        _c.submitGuess(guessWord);
        _currentGuess = '';
      });

      if (_c.state.isGameOver) {
        _showResultDialog();
      }
    }
  }

  void _useHint() {
    final hint = _c.useHint();
    if (hint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اشارے ختم ہو گئے!')),
      );
      return;
    }
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('اشارہ: حرف نمبر ${hint.position + 1} ہے "${hint.letter}"'),
      ),
    );
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (context) => ResultDialog(
        isWon: _c.state.isWon,
        targetWord: _c.state.puzzle.word,
        attempts: _c.state.currentRow,
        onShare: () {
          Navigator.pop(context);
          _shareResult();
        },
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _shareResult() {
    final history = _c.state.evaluations.map((e) => e.states).toList();
    final text = ShareResultService.formatResult(
      _c.state.puzzle,
      _c.state.currentRow,
      history,
      _c.maxAttempts,
    );
    ShareResultService.share(text);
  }

  void _openStats() async {
    final stats = await _statsRepo.getStats();
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (c) => StatisticsScreen(controller: _c, stats: stats))
    );
  }

  /// Best-known state per keyboard letter across submitted guesses.
  /// Priority: correct > present > absent (never downgrades a letter).
  Map<String, TileState> get _keyStates {
    final Map<String, TileState> states = {};
    final guesses = _c.state.guesses;
    final evaluations = _c.state.evaluations;
    final rows = guesses.length < evaluations.length ? guesses.length : evaluations.length;
    for (var r = 0; r < rows; r++) {
      final guess = guesses[r];
      final eval = evaluations[r];
      final cols = guess.length < eval.states.length ? guess.length : eval.states.length;
      for (var c = 0; c < cols; c++) {
        final key = guess[c].display;
        final next = eval.states[c];
        final prev = states[key];
        if (prev == TileState.correct) continue;
        if (prev == TileState.present && next != TileState.correct) continue;
        states[key] = next;
      }
    }
    return states;
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConfig.appName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Badge(
              label: Text('${_c.state.hintsLeft}'),
              child: const Icon(Icons.lightbulb_outline),
            ),
            tooltip: 'اشارہ',
            onPressed: _c.state.hintsLeft > 0 ? _useHint : null,
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _openStats,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const HelpScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Builder(
                builder: (context) {
                  final cols = _c.state.puzzle.wordLength;
                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: 5 * cols,
                    itemBuilder: (context, index) {
                      final row = index ~/ cols;
                      final col = index % cols;

                      // Submitted rows: show evaluated guess units.
                      // Guarded: saved currentRow can exceed restored guesses
                      // (persistence is MVP), so never index out of range.
                      if (row < _c.state.currentRow &&
                          row < _c.state.guesses.length &&
                          row < _c.state.evaluations.length) {
                        final guess = _c.state.guesses[row];
                        final eval = _c.state.evaluations[row];
                        if (col < guess.length && col < eval.states.length) {
                          return GameTile(
                            letter: guess[col].display,
                            state: eval.states[col],
                          );
                        }
                        return const GameTile(letter: '', state: TileState.empty);
                      }

                      // Active row: show in-progress guess only here.
                      if (row == _c.state.currentRow && !_c.state.isGameOver) {
                        final chars = _currentGuess.characters.toList();
                        final letter = col < chars.length ? chars[col] : '';
                        return GameTile(
                          letter: letter,
                          state: letter.isNotEmpty ? TileState.filled : TileState.empty,
                          isCurrent: col == chars.length,
                        );
                      }

                      // Future rows stay empty.
                      return const GameTile(letter: '', state: TileState.empty);
                    },
                  );
                },
              ),
            ),
            if (_c.state.isGameOver)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      _c.state.isWon ? 'شاباش!' : 'آج کا لفظ تھا: ${_c.state.puzzle.word}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(onPressed: _shareResult, child: const Text('نتیجۂ شیئر کریں')),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  UrduKeyboard(
                    onKeyTap: _handleKeyTap,
                    onEnter: _handleEnter,
                    onBackspace: _handleBackspace,
                    keyStates: _keyStates, 
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(onPressed: _handleBackspace, child: const Text('Backspace')),
                      ElevatedButton(onPressed: _handleEnter, child: const Text('Enter')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
