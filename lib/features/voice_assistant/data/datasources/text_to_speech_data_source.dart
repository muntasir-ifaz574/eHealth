import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechDataSource {
  TextToSpeechDataSource({FlutterTts? flutterTts})
    : _tts = flutterTts ?? FlutterTts() {
    _tts.setSpeechRate(0.48);
    _tts.setPitch(1.0);
    _tts.awaitSpeakCompletion(true);
  }

  final FlutterTts _tts;

  Future<void> speak(String message) async {
    await _tts.stop();
    await _tts.speak(message);
  }

  Future<void> stop() => _tts.stop();
}
