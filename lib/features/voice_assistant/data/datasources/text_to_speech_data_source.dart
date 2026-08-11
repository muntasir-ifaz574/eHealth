import 'package:flutter_tts/flutter_tts.dart';

/// Thin wrapper over the `flutter_tts` plugin.
class TextToSpeechDataSource {
  TextToSpeechDataSource({FlutterTts? flutterTts}) : _tts = flutterTts ?? FlutterTts() {
    _tts.setSpeechRate(0.48);
    _tts.setPitch(1.0);
  }

  final FlutterTts _tts;

  Future<void> speak(String message) async {
    await _tts.stop();
    await _tts.speak(message);
  }

  Future<void> stop() => _tts.stop();
}
