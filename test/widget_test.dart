import 'package:ehealth/app.dart';
import 'package:ehealth/core/di/core_providers.dart';
import 'package:ehealth/core/storage/token_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// No platform channel is registered for `flutter_secure_storage` in a
/// widget test, so the auth bootstrap this app runs on every route change
/// needs an in-memory stand-in instead of the real secure storage.
class _FakeTokenStorage extends TokenStorage {
  final Map<String, String> _values = {};

  @override
  Future<String?> getToken() async => _values['auth_token'];

  @override
  Future<void> saveToken(String token) async => _values['auth_token'] = token;

  @override
  Future<Map<String, dynamic>?> getUser() async => null;

  @override
  Future<void> saveUser(Map<String, dynamic> json) async {}

  @override
  Future<void> clear() async => _values.clear();
}

void main() {
  testWidgets('App boots to the splash screen', (WidgetTester tester) async {
    dotenv.testLoad(
      fileInput: 'API_BASE_URL=https://api.pico.support/testButImportant/users',
    );
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
        ],
        child: const App(),
      ),
    );
    // The router's auth redirect resolves asynchronously (even for the
    // splash route itself), so give it a frame before asserting on content.
    await tester.pump();

    expect(find.text('eHealth'), findsOneWidget);

    // Let the splash screen's navigation timer fire before the test ends.
    await tester.pump(const Duration(seconds: 1));
  });
}
