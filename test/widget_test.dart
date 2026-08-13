import 'package:ehealth/app.dart';
import 'package:ehealth/core/di/core_providers.dart';
import 'package:ehealth/core/storage/token_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    await tester.pump();

    expect(find.text('eHealth'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
  });
}
