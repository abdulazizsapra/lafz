import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lafz/main.dart';

void main() {
  testWidgets('app boots to onboarding or the daily game', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const LafzApp());
    await tester.pump();
    expect(find.byType(LafzApp), findsOneWidget);
  });
}
