import 'package:flutter/material.dart';
import 'package:lafz/app/app_config.dart';
import 'package:lafz/app/theme/app_colors.dart';
import 'package:lafz/features/game/presentation/game_controller.dart';
import 'package:lafz/shared/models/game_models.dart';
import 'package:lafz/shared/models/urdu_word_models.dart';
import 'package:lafz/shared/widgets/game_tile.dart';
import 'package:lafz/shared/widgets/play_window.dart';
import 'package:lafz/shared/widgets/urdu_keyboard.dart';
import 'package:lafz/shared/widgets/wordle_header.dart';
import 'package:lafz/core/utils/urdu_text_engine.dart';
import 'package:lafz/features/game/presentation/help_screen.dart';
import 'package:lafz/features/game/presentation/result_dialog.dart';
import 'package:lafz/features/statistics/presentation/statistics_screen.dart';
import 'package:lafz/features/sharing/services/share_result_service.dart';
import 'package:lafz/features/statistics/data/statistics_repository.dart';
import 'package:lafz/features/game/data/word_repository.dart';
import 'package:lafz/features/game/data/word_meaning.dart';

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
  final WordMeaningLookup _meanings = WordMeaningLookup();
  Future<WordMeaning?>? _meaningFuture;

  @override
  void initState() {
    super.initState();
    _loadPuzzle();
  }

  Future<void> _loadPuzzle() async {
    try {
      final words = await _words.loadBundledWords();
      final puzzle = await _words.getTodayPuzzle();
      if (!mounted) return;
      final controller = GameController(puzzle, validWords: words);
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
      setState(
        () => _controller = GameController(
          fallback,
          validWords: const ['زندگی'],
        ),
      );
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

  Future<void> _handleEnter() async {
    if (_c.state.isGameOver) return;
    if (_currentGuess.characters.length == _c.state.puzzle.wordLength) {
      final guessWord = UrduWord(
        original: _currentGuess,
        units: _tokenizer.tokenize(_currentGuess, _normalizer),
      );
      final result = await _c.submitGuess(guessWord);
      if (!mounted) return;
      if (result == GuessSubmitResult.notInWordList) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('یہ لفظ فہرست میں نہیں')),
        );
        return;
      }
      setState(() => _currentGuess = '');
      if (_c.state.isGameOver) {
        _meaningFuture ??= _meanings.lookup(_c.state.puzzle.word);
        _showResultDialog();
      }
    }
  }

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('نیا لفظ؟'),
        content: const Text('موجودہ بورڈ صاف ہو کر ایک نیا لفظ آئے گا۔'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('منسوخ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ہاں'),
          ),
        ],
      ),
    );
    if (ok == true) await _resetWithNewWord();
  }

  Future<void> _resetWithNewWord() async {
    final words = await _words.loadBundledWords();
    final next = _words.randomPuzzleFrom(
      words,
      excludeWord: _c.state.puzzle.word,
    );
    await _c.startNewPuzzle(next);
    if (!mounted) return;
    setState(() {
      _currentGuess = '';
      _meaningFuture = null;
    });
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
        meaningFuture: _meaningFuture,
        onShare: () {
          Navigator.pop(context);
          _shareResult();
        },
        onNewWord: () {
          Navigator.pop(context);
          _resetWithNewWord();
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

  Future<void> _openStats() async {
    final stats = await _statsRepo.getStats();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => StatisticsScreen(controller: _c, stats: stats),
      ),
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

  Widget _tileAt(int index, int cols) {
    final row = index ~/ cols;
    final col = index % cols;

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

    if (row == _c.state.currentRow && !_c.state.isGameOver) {
      final chars = _currentGuess.characters.toList();
      final letter = col < chars.length ? chars[col] : '';
      return GameTile(
        letter: letter,
        state: letter.isNotEmpty ? TileState.filled : TileState.empty,
        isCurrent: col == chars.length,
      );
    }

    return const GameTile(letter: '', state: TileState.empty);
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            WordleHeader(
              title: AppConfig.appName,
              leading: [
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  tooltip: 'کیسے کھیلیں',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const HelpScreen()),
                  ),
                ),
              ],
              trailing: [
                IconButton(
                  icon: Badge(
                    isLabelVisible: _c.state.hintsLeft > 0,
                    backgroundColor: AppColors.absent,
                    label: Text('${_c.state.hintsLeft}'),
                    child: const Icon(Icons.lightbulb_outline),
                  ),
                  tooltip: 'اشارہ',
                  onPressed: _c.state.hintsLeft > 0 ? _useHint : null,
                ),
                IconButton(
                  icon: const Icon(Icons.bar_chart),
                  tooltip: 'اعداد و شمار',
                  onPressed: _openStats,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'نیا لفظ',
                  onPressed: _confirmReset,
                ),
              ],
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cols = _c.state.puzzle.wordLength;
                  const rows = 5;
                  final layout = layoutGame(
                    Size(constraints.maxWidth, constraints.maxHeight),
                    columns: cols,
                    rows: rows,
                  );
                  return Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: SizedBox(
                            width: layout.board.width,
                            height: layout.board.height,
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                                mainAxisSpacing: kWordleTileGap,
                                crossAxisSpacing: kWordleTileGap,
                              ),
                              itemCount: rows * cols,
                              itemBuilder: (context, index) {
                                return _tileAt(index, cols);
                              },
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                        child: UrduKeyboard(
                          onKeyTap: _handleKeyTap,
                          onEnter: _handleEnter,
                          onBackspace: _handleBackspace,
                          keyStates: _keyStates,
                          keyHeight: layout.keyHeight,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
