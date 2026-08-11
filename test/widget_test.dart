import 'package:ehealth/app.dart';
import 'package:ehealth/core/di/core_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App boots to the splash screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)],
        child: const App(),
      ),
    );

    expect(find.text('eHealth'), findsOneWidget);

    // Let the splash screen's navigation timer fire before the test ends.
    await tester.pump(const Duration(seconds: 1));
  });
}
