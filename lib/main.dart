import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app/app_config.dart';
import 'app/theme/app_theme.dart';
import 'features/game/presentation/game_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> _seenOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('lafz_onboarding_seen') ?? false;
}

void main() {
  runApp(const LafzApp());
}

class LafzApp extends StatelessWidget {
  const LafzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appNameEnglish,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
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
      home: FutureBuilder<bool>(
        future: _seenOnboarding(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data! ? const GameScreen() : const OnboardingScreen();
        },
      ),
    );
  }
}
