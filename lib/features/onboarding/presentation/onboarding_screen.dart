import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lafz/app/app_config.dart';
import 'package:lafz/shared/models/game_models.dart';
import 'package:lafz/shared/widgets/game_tile.dart';
import 'package:lafz/features/game/presentation/game_screen.dart';

/// First-launch onboarding. Shown once (flag in SharedPreferences),
/// then replaced by [GameScreen].
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pages = PageController();
  int _index = 0;
  static const int _count = 4;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lafz_onboarding_seen', true);
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
    return Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('چھوڑیں'),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pages,
                  onPageChanged: (i) => setState(() => _index = i),
                  children: const [
                    _WelcomePage(),
                    _HowToPlayPage(),
                    _KeyboardPage(),
                    _HintsPage(),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _count,
                  (i) => Container(
                    margin: const EdgeInsets.all(4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _index
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[400],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _next,
                    child: Text(
                      _index == _count - 1 ? 'کھیل شروع کریں' : 'اگلا',
                      style: const TextStyle(fontSize: 18),
                    ),
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

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppConfig.appName,
            style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'روزانہ اردو لفظ کی پہیلی',
            style: TextStyle(fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'پانچ حرفی لفظ، پانچ کوششیں',
            style: TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _HowToPlayPage extends StatelessWidget {
  const _HowToPlayPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'کیسے کھیلیں',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'پانچ حرفی لفظ لکھ کر Enter دبائیں۔ رنگ بتائیں گے آپ کتنے قریب ہیں:',
            style: TextStyle(fontSize: 17),
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GameTile(letter: 'ز', state: TileState.correct),
              SizedBox(width: 6),
              GameTile(letter: 'ن', state: TileState.present),
              SizedBox(width: 6),
              GameTile(letter: 'د', state: TileState.absent),
            ],
          ),
          const SizedBox(height: 20),
          const _Rule('🟩', 'درست حرف، درست جگہ'),
          const _Rule('🟨', 'حرف موجود ہے، جگہ غلط ہے'),
          const _Rule('⬜', 'حرف لفظ میں موجود نہیں'),
        ],
      ),
    );
  }
}

class _KeyboardPage extends StatelessWidget {
  const _KeyboardPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'کی بورڈ',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'آزمائے گئے حروف کی بورڈ پر رنگدار ہو جاتے ہیں، تاکہ آپ کو یاد رہے کون سے حروف باقی ہیں۔',
            style: TextStyle(fontSize: 17),
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GameTile(letter: 'م', state: TileState.correct),
              SizedBox(width: 6),
              GameTile(letter: 'ح', state: TileState.present),
              SizedBox(width: 6),
              GameTile(letter: 'ب', state: TileState.absent),
            ],
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
      padding: EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اشارے',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'پھنس گئے؟ اوپر 💡 بٹن دبائیں۔ ہر کھیل میں 3 اشارے ملتے ہیں — ہر اشارہ ایک درست حرف اور اس کی جگہ بتاتا ہے۔',
            style: TextStyle(fontSize: 17),
          ),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  final String emoji;
  final String text;

  const _Rule(this.emoji, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 17))),
        ],
      ),
    );
  }
}
