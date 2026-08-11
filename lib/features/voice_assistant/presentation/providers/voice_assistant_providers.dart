import 'package:ehealth/features/voice_assistant/data/datasources/speech_recognition_data_source.dart';
import 'package:ehealth/features/voice_assistant/data/datasources/text_to_speech_data_source.dart';
import 'package:ehealth/features/voice_assistant/data/repositories/voice_repository_impl.dart';
import 'package:ehealth/features/voice_assistant/domain/repositories/voice_repository.dart';
import 'package:ehealth/features/voice_assistant/domain/usecases/initialize_voice_engine.dart';
import 'package:ehealth/features/voice_assistant/domain/usecases/interpret_voice_command.dart';
import 'package:ehealth/features/voice_assistant/domain/usecases/speak_response.dart';
import 'package:ehealth/features/voice_assistant/domain/usecases/start_listening.dart';
import 'package:ehealth/features/voice_assistant/domain/usecases/stop_listening.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final speechRecognitionDataSourceProvider = Provider<SpeechRecognitionDataSource>((ref) {
  return SpeechRecognitionDataSource();
});

final textToSpeechDataSourceProvider = Provider<TextToSpeechDataSource>((ref) {
  return TextToSpeechDataSource();
});

final voiceRepositoryProvider = Provider<VoiceRepository>((ref) {
  return VoiceRepositoryImpl(
    speechDataSource: ref.watch(speechRecognitionDataSourceProvider),
    ttsDataSource: ref.watch(textToSpeechDataSourceProvider),
  );
});

final initializeVoiceEngineProvider = Provider<InitializeVoiceEngine>((ref) {
  return InitializeVoiceEngine(ref.watch(voiceRepositoryProvider));
});

final startListeningProvider = Provider<StartListening>((ref) {
  return StartListening(ref.watch(voiceRepositoryProvider));
});

final stopListeningProvider = Provider<StopListening>((ref) {
  return StopListening(ref.watch(voiceRepositoryProvider));
});

final speakResponseProvider = Provider<SpeakResponse>((ref) {
  return SpeakResponse(ref.watch(voiceRepositoryProvider));
});

final interpretVoiceCommandProvider = Provider<InterpretVoiceCommand>((ref) {
  return const InterpretVoiceCommand();
});
