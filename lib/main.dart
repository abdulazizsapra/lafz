import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app/app_config.dart';
import 'app/theme/app_theme.dart';
import 'core/utils/lafz_kv.dart';
import 'features/game/presentation/game_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'shared/widgets/play_window.dart';

Future<bool> seenOnboarding() async {
  try {
    return await LafzKv.getBool('lafz_onboarding_seen')
            .timeout(const Duration(seconds: 2), onTimeout: () => false) ??
        false;
  } catch (_) {
    return false;
  }
}

void main() {
  runApp(const LafzApp());
}

class LafzApp extends StatefulWidget {
  const LafzApp({super.key});

  @override
  State<LafzApp> createState() => _LafzAppState();
}

class _LafzAppState extends State<LafzApp> {
  late final Future<bool> _onboarding = seenOnboarding();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appNameEnglish,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      locale: const Locale('ur', 'PK'),
      supportedLocales: const [
        Locale('ur', 'PK'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => PlayWindow(child: child ?? const SizedBox.shrink()),
      home: FutureBuilder<bool>(
        future: _onboarding,
        builder: (context, snapshot) {
          // Prefer the landing over a spinner so a slow cookie/prefs read
          // cannot look like a stuck load screen.
          if (snapshot.data == true) return const GameScreen();
          return const OnboardingScreen();
        },
      ),
    );
  }
}
