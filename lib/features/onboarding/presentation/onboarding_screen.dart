import 'package:flutter/material.dart';
import 'package:lafz/core/utils/lafz_kv.dart';
import 'package:lafz/app/app_config.dart';
import 'package:lafz/app/theme/app_colors.dart';
import 'package:lafz/app/typography.dart';
import 'package:lafz/shared/models/game_models.dart';
import 'package:lafz/shared/widgets/game_tile.dart';
import 'package:lafz/features/game/presentation/game_screen.dart';

/// First-launch onboarding. Shown once, then replaced by [GameScreen].
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pages = PageController();
  int _index = 0;
  static const int _count = 3;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await LafzKv.setBool('lafz_onboarding_seen', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  void _next() {
    if (_index == _count - 1) {
      _finish();
    } else {
      _pages.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLanding = _index == 0;
    return Scaffold(
      backgroundColor: const Color(0xFFE3E3E3),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    'چھوڑیں',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkMutedText
                          : AppColors.lightMutedText,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pages,
                  onPageChanged: (i) => setState(() => _index = i),
                  children: [
                    _LandingPage(onPlay: _finish, onHowTo: _next),
                    const _HowToPlayPage(),
                    const _HintsPage(),
                  ],
                ),
              ),
              if (!isLanding) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _count - 1,
                    (i) => Container(
                      margin: const EdgeInsets.all(4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _index - 1
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _next,
                      child: Text(
                        _index == _count - 1 ? 'کھیل شروع کریں' : 'اگلا',
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LandingPage extends StatelessWidget {
  final VoidCallback onPlay;
  final VoidCallback onHowTo;

  const _LandingPage({required this.onPlay, required this.onHowTo});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return LayoutBuilder(
      builder: (context, constraints) {
        final titleSize = (constraints.maxWidth * 0.16).clamp(36.0, 56.0);
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _WordleLogo(),
                const SizedBox(height: 24),
                Text(
                  AppConfig.appName,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    fontFamily: AppTypography.urduFontFamily,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'پانچ موقع تاکہ ایک پانچ حرفی لفظ معلوم ہو۔',
                  style: TextStyle(fontSize: 18, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 220,
                  child: ElevatedButton(
                    onPressed: onPlay,
                    child: const Text('کھیلیں'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onHowTo,
                  child: const Text('کیسے کھیلیں'),
                ),
                const SizedBox(height: 24),
                Text(
                  '${now.day} / ${now.month} / ${now.year}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkMutedText
                        : AppColors.lightMutedText,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WordleLogo extends StatelessWidget {
  const _WordleLogo();

  static const _pattern = [
    [TileState.correct, TileState.empty, TileState.present],
    [TileState.empty, TileState.correct, TileState.empty],
    [TileState.present, TileState.empty, TileState.correct],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in _pattern)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < row.length; i++) ...[
                  if (i > 0) const SizedBox(width: 3),
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: GameTile(letter: '', state: row[i]),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _HowToPlayPage extends StatelessWidget {
  const _HowToPlayPage();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(28, 8, 28, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'کیسے کھیلیں',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 16),
          Text(
            'پانچ حرفی لفظ لکھ کر جمع کریں دبائیں۔ صرف فہرست کے الفاظ قبول ہوں گے۔ رنگ بتائیں گے آپ کتنے قریب ہیں:',
            style: TextStyle(fontSize: 17, height: 1.5),
          ),
          SizedBox(height: 24),
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
          SizedBox(height: 18),
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
          SizedBox(height: 18),
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
    );
  }
}

class _HintsPage extends StatelessWidget {
  const _HintsPage();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اشارے',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 16),
          Text(
            'پھنس گئے؟ اوپر بلب دبائیں۔ ہر کھیل میں 3 اشارے ملتے ہیں — ہر اشارہ ایک درست حرف اور اس کی جگہ بتاتا ہے۔',
            style: TextStyle(fontSize: 17, height: 1.55),
          ),
        ],
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
          height: 44,
          child: Row(
            children: [
              for (var i = 0; i < letters.length; i++) ...[
                if (i > 0) const SizedBox(width: 5),
                SizedBox(
                  width: 44,
                  child: GameTile(letter: letters[i], state: states[i]),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(caption, style: const TextStyle(fontSize: 15, height: 1.4)),
      ],
    );
  }
}
