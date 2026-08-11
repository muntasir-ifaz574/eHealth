import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Typed access to the values loaded from `.env` by [DotEnv].
///
/// Call [Env.load] once in `main()` before `runApp`.
abstract final class Env {
  static Future<void> load() => dotenv.load(fileName: '.env');

  static String get googleMapsApiKey => dotenv.get('GOOGLE_MAPS_API_KEY', fallback: '');

  static String get googlePlacesApiKey => dotenv.get('GOOGLE_PLACES_API_KEY', fallback: '');

  static int get zegoAppId => int.tryParse(dotenv.get('ZEGO_APP_ID', fallback: '0')) ?? 0;

  static String get zegoAppSign => dotenv.get('ZEGO_APP_SIGN', fallback: '');

  static String get apiBaseUrl => dotenv.get('API_BASE_URL', fallback: 'https://api.example.com');
}
